import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../services/ai_timetable_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/navigation_modal.dart';
import '../../models/timetable_item.dart';

class TimetableAnalyserScreen extends StatefulWidget {
  const TimetableAnalyserScreen({super.key});

  @override
  State<TimetableAnalyserScreen> createState() =>
      _TimetableAnalyserScreenState();
}

class _TimetableAnalyserScreenState extends State<TimetableAnalyserScreen> {
  String _selectedDay = 'Monday';
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto(AppState appState) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 3840,
        maxHeight: 3840,
        imageQuality: 100,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        await appState.selectAndAnalyzeTimetableImage(
          photo.name,
          imageBytes: bytes,
          imagePath: photo.path,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Camera Photo Captured (${photo.name})! Analyzing via ${AiTimetableService.apiName}...',
              ),
              backgroundColor: AppTheme.purpleAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera access note: $e. Simulating camera scan.'),
            backgroundColor: AppTheme.amberWarning,
          ),
        );
      }
      // No default filename for simulated camera scan
      // appState.selectAndAnalyzeTimetableImage('');
    }
  }

  Future<void> _pickImageFromGallery(AppState appState) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 3840,
        maxHeight: 3840,
        imageQuality: 100,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        await appState.selectAndAnalyzeTimetableImage(
          image.name,
          imageBytes: bytes,
          imagePath: image.path,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image Loaded (${image.name})! Analyzing via ${AiTimetableService.apiName}...',
              ),
              backgroundColor: AppTheme.cyanPrimary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gallery pick note: $e. Simulating document upload.'),
            backgroundColor: AppTheme.amberWarning,
          ),
        );
      }
      // Do not use a hardcoded default file
      // Instead, we can show an error or a generic placeholder if needed, but no default document string
      // appState.selectAndAnalyzeTimetableImage('');
    }
  }

  void _showAddClassDialog(
    BuildContext context,
    AppState appState,
    bool isDark,
  ) {
    final codeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final venueCtrl = TextEditingController();
    final timeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.cyan(isDark)),
        ),
        title: Text(
          'Add Course Schedule',
          style: TextStyle(
            color: AppTheme.textPrimary(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtrl,
              style: TextStyle(color: AppTheme.textPrimary(isDark)),
              decoration: const InputDecoration(
                labelText: 'Course Code (e.g. CS-101)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleCtrl,
              style: TextStyle(color: AppTheme.textPrimary(isDark)),
              decoration: const InputDecoration(
                labelText: 'Course Title / Subject',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: venueCtrl,
              style: TextStyle(color: AppTheme.textPrimary(isDark)),
              decoration: const InputDecoration(
                labelText: 'Venue Code (e.g. LH-201)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeCtrl,
              style: TextStyle(color: AppTheme.textPrimary(isDark)),
              decoration: const InputDecoration(
                labelText: 'Start Time (e.g. 10:00 AM)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMuted(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeCtrl.text.isNotEmpty) {
                appState.addCustomClass(
                  TimetableItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    courseCode: codeCtrl.text,
                    courseTitle: titleCtrl.text.isEmpty
                        ? 'Custom Class'
                        : titleCtrl.text,
                    venueCode: venueCtrl.text,
                    building: 'Tech Block A',
                    level: 2,
                    dayOfWeek: _selectedDay,
                    startTime: timeCtrl.text,
                    endTime: '11:30 AM',
                    instructor: 'Faculty Member',
                    aiRecommendation:
                        'AI mapped venue. Scheduled via Open-Source AI Engine.',
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cyan(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Add Class',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApiConfigDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.purple(isDark)),
        ),
        title: Row(
          children: [
            Icon(Icons.api_rounded, color: AppTheme.purple(isDark)),
            const SizedBox(width: 8),
            Text(
              'Open-Source AI API Config',
              style: TextStyle(
                color: AppTheme.textPrimary(isDark),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Configured API:',
              style: TextStyle(
                color: AppTheme.textSecondary(isDark),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.grey.shade200)
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.purple(isDark).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Provider: ${AiTimetableService.apiName}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AiTimetableService.apiKey.isNotEmpty
                        ? '• API Key: ${AiTimetableService.apiKey.substring(0, AiTimetableService.apiKey.length > 12 ? 12 : AiTimetableService.apiKey.length)}... (Configured)'
                        : '• API Key: Local / Not required',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppTheme.emeraldSuccess,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Endpoint: ${AiTimetableService.apiEndpoint}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Model: ${AiTimetableService.modelName}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ollama Endpoint defaults to http://localhost:11434/v1/chat/completions (use http://10.0.2.2:11434/v1/chat/completions for Android emulator).\nSet via: --dart-define=OLLAMA_ENDPOINT=...',
              style: TextStyle(color: AppTheme.textMuted(isDark), fontSize: 11),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.purple(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final dayClasses = appState.timetable
        .where((t) => t.dayOfWeek.toLowerCase().startsWith(_selectedDay.toLowerCase().substring(0, 3)))
        .toList();
    final TimetableItem? activeClass = appState.nextClass;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Open-Source AI API Tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: AppTheme.neonGlowDecoration(
                  color: AppTheme.purple(isDark),
                  borderRadius: 16,
                  isDark: isDark,
                ),
                child: Icon(
                  Icons.center_focus_strong_rounded,
                  color: AppTheme.purple(isDark),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'OPEN-SOURCE AI ENGINE',
                          style: TextStyle(
                            color: AppTheme.purple(isDark),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _showApiConfigDialog(context, isDark),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.purple(isDark)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppTheme.purple(isDark),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              AiTimetableService.apiName.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Timetable Image Analyser',
                      style: TextStyle(
                        color: AppTheme.textPrimary(isDark),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // AUTOMATIC SCHEDULE LOCATOR / WHERE TO GO NOW CARD
          if (activeClass != null) ...[
            GlassContainer(
              borderRadius: 22,
              borderColor: AppTheme.cyan(isDark),
              gradientColors: [
                AppTheme.cyan(isDark).withValues(alpha: isDark ? 0.2 : 0.15),
                AppTheme.purple(isDark).withValues(alpha: isDark ? 0.12 : 0.08),
              ],
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.emerald(isDark),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'CURRENT SCHEDULED CLASS LOCATOR',
                            style: TextStyle(
                              color: AppTheme.cyan(isDark),
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.amber(isDark),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          activeClass.dayOfWeek.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Subject Title & Code
                  Text(
                    '${activeClass.courseCode} • ${activeClass.courseTitle}',
                    style: TextStyle(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Extracted Day, Time, Venue Details
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        color: AppTheme.cyan(isDark),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${activeClass.startTime} - ${activeClass.endTime}',
                        style: TextStyle(
                          color: AppTheme.cyan(isDark),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.room_rounded,
                        color: AppTheme.purple(isDark),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${activeClass.venueCode} (${activeClass.building})',
                          style: TextStyle(
                            color: AppTheme.textSecondary(isDark),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Navigate Button
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final venue = appState.venues.firstWhere(
                          (v) => v.code == activeClass.venueCode,
                          orElse: () => appState.venues.first,
                        );
                        appState.startNavigation(venue);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const NavigationModal(),
                        );
                      },
                      icon: const Icon(
                        Icons.navigation_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        'NAVIGATE TO SCHEDULED CLASS NOW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyan(isDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // UPLOAD TIMETABLE IMAGE CONTAINER
          GlassContainer(
            borderRadius: 24,
            borderColor: AppTheme.purple(isDark).withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          color: AppTheme.cyan(isDark),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'UPLOAD TIMETABLE IMAGE',
                          style: TextStyle(
                            color: AppTheme.cyan(isDark),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'API: OpenRouter Vision',
                      style: TextStyle(
                        color: AppTheme.purple(isDark),
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Selected Image Preview Card Box
                Container(
                  width: double.infinity,
                  height: 130,
                  decoration: BoxDecoration(
                    color: (isDark ? AppTheme.darkBg : AppTheme.lightSurface)
                        .withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.purple(isDark).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.purple(isDark)
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.image_search_rounded,
                                color: AppTheme.purple(isDark),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              appState.selectedTimetableImageName ??
                                  'No Image Selected',
                              style: TextStyle(
                                color: AppTheme.textPrimary(isDark),
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Target Model: ${AiTimetableService.modelName} (${AiTimetableService.apiName})',
                              style: TextStyle(
                                color: AppTheme.textMuted(isDark),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.emerald(isDark)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.emerald(isDark)),
                          ),
                          child: Text(
                            'IMAGE READY',
                            style: TextStyle(
                              color: AppTheme.emerald(isDark),
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Image Upload Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _takePhoto(appState),
                        icon: Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: AppTheme.purple(isDark),
                        ),
                        label: Text(
                          'Take Photo',
                          style: TextStyle(
                            color: AppTheme.purple(isDark),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.purple(isDark)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImageFromGallery(appState),
                        icon: Icon(
                          Icons.photo_library_rounded,
                          size: 16,
                          color: AppTheme.cyan(isDark),
                        ),
                        label: Text(
                          'Upload File',
                          style: TextStyle(
                            color: AppTheme.cyan(isDark),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.cyan(isDark)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Analyze Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed:
                        appState.isAnalyzingTimetable ||
                            appState.selectedTimetableImageName == null
                        ? null
                        : () => appState.selectAndAnalyzeTimetableImage(
                            appState.selectedTimetableImageName!,
                          ),
                    icon: appState.isAnalyzingTimetable
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.psychology_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                    label: Text(
                      appState.isAnalyzingTimetable
                          ? 'EXTRACTING SCHEDULE VIA API...'
                          : 'RUN AI VISION OCR SCAN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.6,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.purple(isDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                      shadowColor: AppTheme.purple(isDark)
                          .withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // AI ANALYSIS RESULT SUMMARY CARD
          GlassContainer(
            borderRadius: 20,
            gradientColors: [
              AppTheme.purple(isDark).withValues(alpha: isDark ? 0.15 : 0.12),
              AppTheme.cyan(isDark).withValues(alpha: isDark ? 0.1 : 0.08),
            ],
            borderColor: AppTheme.purple(isDark),
            child: Row(
              children: [
                Icon(
                  Icons.smart_toy_rounded,
                  color: AppTheme.purple(isDark),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OPEN-SOURCE AI API EXTRACTION OUTPUT',
                        style: TextStyle(
                          color: AppTheme.purple(isDark),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appState.aiAnalysisSummary,
                        style: TextStyle(
                          color: AppTheme.textPrimary(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // SCHEDULE TIMELINE BY DAY
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXTRACTED WEEKLY SCHEDULE',
                style: TextStyle(
                  color: AppTheme.cyan(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () => _showAddClassDialog(context, appState, isDark),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppTheme.cyan(isDark),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Add Class',
                      style: TextStyle(
                        color: AppTheme.cyan(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Day Chips Switcher
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                  .map((day) {
                    final isSel = _selectedDay == day;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = day),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppTheme.cyan(isDark)
                              : (isDark
                                    ? AppTheme.darkSurface
                                    : AppTheme.lightSurface),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel
                                ? AppTheme.cyan(isDark)
                                : AppTheme.cyan(isDark).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          day,
                          style: TextStyle(
                            color: isSel
                                ? Colors.white
                                : AppTheme.textPrimary(isDark),
                            fontWeight: isSel
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Timeline Class Items
          if (dayClasses.isEmpty)
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No classes scheduled for $_selectedDay.',
                  style: TextStyle(color: AppTheme.textMuted(isDark)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dayClasses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = dayClasses[index];
                return _buildTimelineCard(context, appState, item, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(
    BuildContext context,
    AppState appState,
    TimetableItem item,
    bool isDark,
  ) {
    return GlassContainer(
      borderRadius: 20,
      borderColor: item.isNextClass ? AppTheme.cyan(isDark) : null,
      gradientColors: item.isNextClass
          ? [
              AppTheme.cyan(isDark).withValues(alpha: 0.15),
              (isDark ? AppTheme.darkCard : AppTheme.lightSurface).withValues(
                alpha: 0.8,
              ),
            ]
          : null,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cyan(isDark).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.startTime} - ${item.endTime}',
                  style: TextStyle(
                    color: AppTheme.cyan(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.purple(isDark).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.dayOfWeek,
                      style: TextStyle(
                        color: AppTheme.purple(isDark),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (item.isNextClass)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.amber(isDark),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NEXT CLASS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            '${item.courseCode} • ${item.courseTitle}',
            style: TextStyle(
              color: AppTheme.textPrimary(isDark),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppTheme.textSecondary(isDark),
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${item.venueCode} (${item.building}, Level ${item.level})',
                  style: TextStyle(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.person_outline_rounded,
                color: AppTheme.textMuted(isDark),
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.instructor,
                  style: TextStyle(
                    color: AppTheme.textMuted(isDark),
                    fontSize: 11.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // AI Recommendation Note
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkBg : AppTheme.lightSurface)
                  .withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.purple(isDark),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.aiRecommendation,
                    style: TextStyle(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Direct Navigation Button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: () {
                final venue = appState.venues.firstWhere(
                  (v) => v.code == item.venueCode,
                  orElse: () => appState.venues.first,
                );
                appState.startNavigation(venue);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const NavigationModal(),
                );
              },
              icon: const Icon(
                Icons.navigation_rounded,
                size: 14,
                color: Colors.white,
              ),
              label: const Text(
                'GET AI INDOOR ROUTE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cyan(isDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
