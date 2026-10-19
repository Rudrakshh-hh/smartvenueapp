import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/timetable_item.dart';

/// Result wrapper returned after parsing a timetable image via the Open-Source AI Vision API.
class AiAnalysisResult {
  final List<TimetableItem> extractedSchedule;
  final String summary;
  final TimetableItem? recommendedClass;
  final String rawResponse;
  final String apiName;

  const AiAnalysisResult({
    required this.extractedSchedule,
    required this.summary,
    this.recommendedClass,
    required this.rawResponse,
    this.apiName = "DeepSeek AI",
  });
}

/// Service that interfaces with Ollama / Open-Source AI Vision APIs
/// to extract timing, day, subject, and venue from timetable images and schedule classes automatically.
class AiTimetableService {
  // Configurable Ollama API Parameters
  static String customApiKey = "xyz";
  static String customApiEndpoint = "";
  static String customModelName = "gemma4:31b-cloud";

  static String get apiKey {
    if (customApiKey.isNotEmpty) return customApiKey;
    return const String.fromEnvironment('OLLAMA_API_KEY', defaultValue: '');
  }

  static String get apiEndpoint {
    if (customApiEndpoint.isNotEmpty) return customApiEndpoint;
    return const String.fromEnvironment(
      'OLLAMA_ENDPOINT',
      defaultValue: 'http://localhost:11434/v1/chat/completions',
    );
  }

  static String get modelName {
    if (customModelName.isNotEmpty) return customModelName;
    return const String.fromEnvironment(
      'OLLAMA_MODEL',
      defaultValue: 'gemma4:31b-cloud',
    );
  }

  static const String apiName = "Ollama AI";

  /// High-precision system prompt for timetable OCR extraction
  static const String _visionPrompt = '''
You are an expert, zero-error OCR and Document Parsing AI specializing in academic schedule extraction.
Your task is to transcribe the timetable image with 100% character-level accuracy for all text, numbers, codes, and instructor names.

CRITICAL PARSING GUIDELINES:
1. READ LOOKUP LEGEND: First scan the subject lookup table/legend (usually at the bottom or side of the timetable) to map each Subject Code (e.g. "TCS 502") to its exact full Subject Name (e.g. "Operating Systems") and Instructor Name (e.g. "Ms. Himadri Vaidya").
2. SPELLING & NAMES: Transcribe instructor names and subject titles verbatim from the legend. Do NOT guess, alter, abridge, or misspell any names or titles. Include honorifics (Dr., Prof., Mr., Ms.) exactly as written.
3. GRID CORRELATION: Examine every day row (Monday-Saturday) and time slot column. For each scheduled class session, create an entry.
4. CODES & ROOMS: Transcribe venue codes (e.g. "224 (LT)", "LH-102") and course codes (e.g. "TCS-502") character-by-character as shown in the image.
5. EXACT TIME SLOT MAPPING:
   - Carefully read the column headers at the top of the schedule grid defining period time slots 
   - Extract the EXACT startTime and endTime corresponding to the specific column header above each class cell.
   - CRITICAL: See the class starting time - ending time and how long the class is been conduct.

OUTPUT FORMAT REQUIREMENTS:
Return ONLY a valid, raw JSON array of objects. Do NOT include markdown codeblocks, explanations, or text before or after the JSON.

Each object must contain these exact keys:
- "courseCode": String (e.g. "TCS 502")
- "courseTitle": String (Full subject title from lookup legend)
- "venueCode": String (e.g. "224 (LT)")
- "building": String (Building name or "Main Block")
- "level": Integer (Floor/Level number, default 1)
- "dayOfWeek": String ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
- "startTime": String (e.g. "09:00 AM")
- "endTime": String (e.g. "09:55 AM")
- "instructor": String (Exact full instructor name from lookup legend)
- "aiRecommendation": String (Short arrival note, e.g. "Class in Venue 224")
''';

  /// Performs local high-precision Google ML Kit OCR on the timetable image.
  static Future<String> _performLocalMlKitOcr(String? path, Uint8List? bytes) async {
    try {
      String? localFilePath = path;
      File? tempFile;

      if ((localFilePath == null || localFilePath.isEmpty) && bytes != null && bytes.isNotEmpty) {
        tempFile = File('${Directory.systemTemp.path}/temp_timetable_ocr.jpg');
        await tempFile.writeAsBytes(bytes);
        localFilePath = tempFile.path;
      }

      if (localFilePath == null || localFilePath.isEmpty) return "";

      final inputImage = InputImage.fromFilePath(localFilePath);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }

      final String extracted = recognizedText.text.trim();
      debugPrint("Google ML Kit Extracted Text:\n$extracted");
      return extracted;
    } catch (e) {
      debugPrint("Local ML Kit OCR Note: $e");
      return "";
    }
  }

  /// Sends the image to the AI Vision API and extracts schedule items.
  static Future<AiAnalysisResult> analyzeTimetableImage({
    required String imageName,
    Uint8List? imageBytes,
    String? imagePath,
  }) async {
    // Check if real API endpoint is supplied (or if placeholder "API HERE" is used)
    final bool isPlaceholderApi =
        (apiEndpoint == "API HERE" || apiEndpoint.isEmpty);

    if (!isPlaceholderApi) {
      try {
        // Step 1: Perform native Google ML Kit OCR at 100% full image resolution
        final String ocrText = await _performLocalMlKitOcr(imagePath, imageBytes);

        // Step 2: Combine base vision prompt with ML Kit's verbatim OCR text
        final String combinedPrompt = ocrText.isNotEmpty
            ? '$_visionPrompt\n\nEXACT HIGH-PRECISION OCR TEXT EXTRACTED FROM IMAGE BY GOOGLE ML KIT (Use this for 100% verbatim spelling of instructor names, course codes, and titles):\n"""\n$ocrText\n"""'
            : _visionPrompt;

        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 180);
        final uri = Uri.parse(apiEndpoint);
        final request = await client.postUrl(uri);

        request.headers.set('Content-Type', 'application/json');
        if (apiKey.isNotEmpty) {
          request.headers.set('Authorization', 'Bearer $apiKey');
        }
        request.headers.set('HTTP-Referer', 'https://smartvenue.app');
        request.headers.set('X-Title', 'SmartVenue AI Analyser');

        final base64Image = imageBytes != null ? base64Encode(imageBytes) : "";

        final payload = jsonEncode({
          "model": modelName,
          "messages": [
            {
              "role": "user",
              "content": [
                {"type": "text", "text": combinedPrompt},
                if (base64Image.isNotEmpty)
                  {
                    "type": "image_url",
                    "image_url": {"url": "data:image/jpeg;base64,$base64Image"},
                  },
              ],
            },
          ],
          "temperature": 0.0,
          "top_p": 0.1,
          "max_tokens": 4096,
        });

        request.write(payload);
        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();
        client.close();

        // Parse JSON response from AI Vision API
        final parsedJson = jsonDecode(responseBody);
        final List<TimetableItem> extractedList = [];

        debugPrint("Full API Response: $responseBody");

        if (parsedJson is Map && parsedJson.containsKey('choices')) {
          var contentRaw = parsedJson['choices'][0]['message']['content'];
          var contentText = contentRaw?.toString().trim() ?? '';

          debugPrint("Raw AI Response: $contentText");

          if (contentText.contains('```')) {
            contentText = contentText
                .replaceAll(RegExp(r'```json\s*'), '')
                .replaceAll(RegExp(r'```\s*'), '')
                .trim();
          }

          // Sometimes AI adds text before the JSON array. Find the array brackets.
          final startIndex = contentText.indexOf('[');
          final endIndex = contentText.lastIndexOf(']');

          if (startIndex != -1 && endIndex != -1 && endIndex >= startIndex) {
            contentText = contentText.substring(startIndex, endIndex + 1);
          }

          if (contentText.isEmpty || contentText == 'null') {
            throw Exception("AI returned empty or null content.");
          }

          try {
            final dynamic decoded = jsonDecode(contentText);
            if (decoded is List) {
              for (var i = 0; i < decoded.length; i++) {
                extractedList.add(TimetableItem.fromJson(decoded[i], id: 'ai_$i'));
              }
            } else {
              throw Exception("AI did not return a JSON array as requested.");
            }
          } catch (e) {
            // Check if the error is just an unterminated string (AI cut off early)
            if (e.toString().contains("Unterminated string") || e.toString().contains("Unexpected end of input")) {
              throw Exception("AI output was too long and cut off. Please upgrade your API key limit or scan a smaller image.");
            }
            throw Exception("Failed to parse AI JSON: $e");
          }
        } else if (parsedJson is Map && parsedJson.containsKey('error')) {
          final errorMsg =
              parsedJson['error']['message'] ?? parsedJson['error'].toString();
          throw Exception("API Error: $errorMsg");
        }

        if (extractedList.isNotEmpty) {
          final recommended = getNextScheduledClass(extractedList);
          return AiAnalysisResult(
            extractedSchedule: extractedList,
            summary:
            'Successfully extracted ${extractedList.length} classes via Ollama AI ($modelName).',
            recommendedClass: recommended,
            rawResponse: responseBody,
            apiName: apiName,
          );
        } else {
          return AiAnalysisResult(
            extractedSchedule: [],
            summary: 'Ollama AI returned a response, but no classes were extracted.',
            recommendedClass: null,
            rawResponse: responseBody,
            apiName: apiName,
          );
        }
      } catch (e) {
        debugPrint("Ollama AI call note: $e.");
        String userFriendlyError = "Cannot scan image. The AI engine encountered an error.";

        if (e.toString().contains("SocketException") ||
            e.toString().contains("TimeoutException") ||
            e.toString().contains("Connection refused")) {
          userFriendlyError =
              "Cannot connect to Ollama at $apiEndpoint. Make sure Ollama server is running (e.g. `ollama serve`).";
        } else if (e.toString().contains("404")) {
          userFriendlyError = "Model '$modelName' not found on Ollama. Run `ollama pull $modelName` first.";
        }

        return AiAnalysisResult(
          extractedSchedule: [],
          summary: userFriendlyError,
          recommendedClass: null,
          rawResponse: '{"status": "error", "message": "$e"}',
          apiName: apiName,
        );
      }
    }

    // FALLBACK IF API FAILS
    // Simulates AI parsing delay and extracts timing, day, and subject from timetable image.
    await Future.delayed(const Duration(milliseconds: 1800));

    return AiAnalysisResult(
      extractedSchedule: [],
      summary:
      'Ollama Endpoint missing or unreachable at $apiEndpoint.',
      recommendedClass: null,
      rawResponse: '{"status": "error", "message": "Ollama endpoint missing"}',
      apiName: apiName,
    );
  }

  /// Automatically calculates which class the user needs to attend at a particular time or day.
  static TimetableItem? getNextScheduledClass(
      List<TimetableItem> items, {
        DateTime? currentTime,
      }) {
    if (items.isEmpty) return null;

    final now = currentTime ?? DateTime.now();
    final currentDayStr = _getDayName(now.weekday);

    // 1. Try to find class on today's schedule that is happening right now or coming up next
    final todayClasses = items
        .where((i) => i.dayOfWeek.toLowerCase() == currentDayStr.toLowerCase())
        .toList();

    for (final item in todayClasses) {
      if (item.isNextClass) return item;
    }

    if (todayClasses.isNotEmpty) {
      return todayClasses.first;
    }

    // 2. Fallback to first class marked as nextClass or first item in list
    final markedNext = items.where((i) => i.isNextClass).toList();
    if (markedNext.isNotEmpty) return markedNext.first;

    return items.first;
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }
}