import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

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
    this.apiName = "OpenRouter Vision API",
  });
}

/// Service that interfaces with Open-Source AI Vision APIs (e.g., Llama-Vision, Qwen-VL, Ollama, OpenRouter)
/// to extract timing, day, subject, and venue from timetable images and schedule classes automatically.
class AiTimetableService {
  // Configurable OpenRouter API Parameters
  static const String apiKey = "xyz";
  static const String apiEndpoint =
      "https://openrouter.ai/api/v1/chat/completions";
  static const String modelName =
      "openai/gpt-4o";

  /// System prompt supplied to the open-source AI vision model for timetable extraction
  static const String _visionPrompt = '''
You are an expert OCR Timetable Extraction AI. Analyze the uploaded timetable image and extract all schedule entries.
The timetable typically contains a main schedule grid (days vs. time slots) and a lookup table mapping subject codes to subject names and faculty names.
Please correlate the main schedule grid with the lookup table to provide complete information for each class session.

For each entry, extract:
1. dayOfWeek (e.g., "Monday")
2. courseCode (e.g., "TCS 502")
3. courseTitle (Subject Name from the lookup table, e.g., "Operating Systems")
4. startTime (e.g., "12:00 PM")
5. endTime (e.g., "12:55 PM")
6. venueCode (e.g., "224 (LT)")
7. building (e.g., "Tech Block A" or leave empty if not specified)
8. level (e.g., 2 or leave as 1 if not specified)
9. instructor (Faculty Name from the lookup table, e.g., "Ms. Himadri Vaidya")

Return ONLY a structured JSON array containing these objects without extra markdown.
''';

  /// Sends the image to the Open-Source AI Vision API (OpenRouter) and extracts schedule items.
  static Future<AiAnalysisResult> analyzeTimetableImage({
    required String imageName,
    Uint8List? imageBytes,
    String? imagePath,
  }) async {
    // Check if real API endpoint is supplied (or if placeholder "API HERE" is used)
    final bool isPlaceholderApi =
    (apiEndpoint == "API HERE" || apiKey == "API HERE" || apiKey.isEmpty);

    if (!isPlaceholderApi) {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 60);
        final uri = Uri.parse(apiEndpoint);
        final request = await client.postUrl(uri);

        request.headers.set('Content-Type', 'application/json');
        request.headers.set('Authorization', 'Bearer $apiKey');
        request.headers.set('HTTP-Referer', 'https://smartvenue.app');
        request.headers.set('X-Title', 'SmartVenue AI Analyser');

        final base64Image = imageBytes != null ? base64Encode(imageBytes) : "";

        final payload = jsonEncode({
          "model": modelName,
          "messages": [
            {
              "role": "user",
              "content": [
                {"type": "text", "text": _visionPrompt},
                if (base64Image.isNotEmpty)
                  {
                    "type": "image_url",
                    "image_url": {"url": "data:image/jpeg;base64,$base64Image"},
                  },
              ],
            },
          ],
          "temperature": 0.2,
          "max_tokens": 3927,
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
            'Successfully extracted ${extractedList.length} classes via OpenRouter API ($modelName).',
            recommendedClass: recommended,
            rawResponse: responseBody,
            apiName: "OpenRouter Vision API",
          );
        } else {
          return AiAnalysisResult(
            extractedSchedule: [],
            summary: 'OpenRouter API returned a response, but no classes were extracted.',
            recommendedClass: null,
            rawResponse: responseBody,
            apiName: "OpenRouter Vision API",
          );
        }
      } catch (e) {
        debugPrint("OpenRouter Vision API call note: $e.");
        String userFriendlyError = "Cannot scan image. The AI engine encountered an error.";

        if (e.toString().contains("credit") || e.toString().contains("tokens")) {
          userFriendlyError = "Cannot scan image. API token limit reached or free credits exhausted.";
        } else if (e.toString().contains("Unterminated") || e.toString().contains("Unexpected end")) {
          userFriendlyError = "Cannot scan image. The timetable is too large for the current API tier.";
        } else if (e.toString().contains("SocketException") || e.toString().contains("TimeoutException")) {
          userFriendlyError = "Cannot scan image. Network connection to AI server timed out.";
        }

        return AiAnalysisResult(
          extractedSchedule: [],
          summary: userFriendlyError,
          recommendedClass: null,
          rawResponse: '{"status": "error", "message": "$e"}',
          apiName: "OpenRouter Vision API",
        );
      }
    }

    // FALLBACK IF API FAILS
    // Simulates AI parsing delay and extracts timing, day, and subject from timetable image.
    await Future.delayed(const Duration(milliseconds: 1800));

    return AiAnalysisResult(
      extractedSchedule: [],
      summary:
      'OpenRouter Engine failed to parse "$imageName" or no API key provided.',
      recommendedClass: null,
      rawResponse: '{"status": "error", "message": "API key missing or failed to parse"}',
      apiName: "OpenRouter Vision API",
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