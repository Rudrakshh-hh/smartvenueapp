import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/navigation_modal.dart';
import '../../models/timetable_item.dart';

class TimetableAnalyserScreen extends StatefulWidget {
  const TimetableAnalyserScreen({super.key});

  @override
  State<TimetableAnalyserScreen> createState() => _TimetableAnalyserScreenState();
}

class _TimetableAnalyserScreenState extends State<TimetableAnalyserScreen> {
  String _selectedDay = 'Monday';

  void _showAddClassDialog(BuildContext context, AppState appState, bool isDark) {
    final codeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final venueCtrl = TextEditingController(text: 'LH-201');
    final timeCtrl = TextEditingController(text: '10:00 AM');

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
          style: TextStyle(color: AppTheme.textPrimary(isDark), fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtrl,
              style: TextStyle(color: AppTheme.textPrimary(isDark)),
              decoration: const InputDecoration(labelText: 'Course Code (e.g. CS-101)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleCtrl,
              style: TextStyle(color: AppTheme.textPrimary(isDark)),
              decoration: const InputDecoration(labelText: 'Course Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: venueCtrl,
              style: TextStyle(color: AppTheme.textPrimary(isDark)),
              decoration: const InputDecoration(labelText: 'Venue Code (e.g. LH-201)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeCtrl,
              style: TextStyle(color: AppTheme.textPrimary(isDark)),
              decoration: const InputDecoration(labelText: 'Start Time (e.g. 10:00 AM)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted(isDark))),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeCtrl.text.isNotEmpty) {
                appState.addCustomClass(
                  TimetableItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    courseCode: codeCtrl.text,
                    courseTitle: titleCtrl.text.isEmpty ? 'Custom Class' : titleCtrl.text,
                    venueCode: venueCtrl.text,
                    building: 'Tech Block A',
                    level: 2,
                    dayOfWeek: _selectedDay,
                    startTime: timeCtrl.text,
                    endTime: '11:30 AM',
                    instructor: 'Faculty Member',
                    aiRecommendation: 'AI mapped venue. Path generated via D* Lite.',
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cyan(isDark),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add Class', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final dayClasses = appState.timetable.where((t) => t.dayOfWeek == _selectedDay).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: AppTheme.neonGlowDecoration(
                  color: AppTheme.purple(isDark),
                  borderRadius: 16,
                  isDark: isDark,
                ),
                child: Icon(Icons.center_focus_strong_rounded, color: AppTheme.purple(isDark), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI OCR VISION DECISION ENGINE',
                      style: TextStyle(
                        color: AppTheme.purple(isDark),
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
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

          // UPLOAD TIMETABLE IMAGE CONTAINER
          GlassContainer(
            borderRadius: 24,
            borderColor: AppTheme.purple(isDark).withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.add_a_photo_rounded, color: AppTheme.cyan(isDark), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'UPLOAD TIMETABLE IMAGE / SCAN',
                      style: TextStyle(
                        color: AppTheme.cyan(isDark),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Timetable Image Sample Selection Pills
                Text('Choose or Upload Schedule Image:', style: TextStyle(color: AppTheme.purple(isDark), fontSize: 11.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildImageSampleChip('CS_Semester_4_Schedule_Scan.png', appState, isDark),
                      const SizedBox(width: 8),
                      _buildImageSampleChip('Physics_Lab_Class_Image.png', appState, isDark),
                      const SizedBox(width: 8),
                      _buildImageSampleChip('Engineering_Master_Schedule.jpg', appState, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Selected Image Preview Card Box
                Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: (isDark ? AppTheme.darkBg : AppTheme.lightSurface).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.purple(isDark).withValues(alpha: 0.3)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.purple(isDark).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.image_search_rounded, color: AppTheme.purple(isDark), size: 32),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              appState.selectedTimetableImageName ?? 'No Image Selected',
                              style: TextStyle(color: AppTheme.textPrimary(isDark), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'AI OCR Vision Ready • 300 DPI Resolution',
                              style: TextStyle(color: AppTheme.textMuted(isDark), fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.emerald(isDark).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.emerald(isDark)),
                          ),
                          child: Text('IMAGE LOADED', style: TextStyle(color: AppTheme.emerald(isDark), fontSize: 9, fontWeight: FontWeight.bold)),
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
                        onPressed: () {
                          appState.selectAndAnalyzeTimetableImage('Custom_Camera_Scan_${DateTime.now().millisecondsSinceEpoch}.png');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Camera Photo Captured! Processing OCR Vision...'),
                              backgroundColor: AppTheme.purpleAccent,
                            ),
                          );
                        },
                        icon: Icon(Icons.camera_alt_rounded, size: 16, color: AppTheme.purple(isDark)),
                        label: Text('Take Photo', style: TextStyle(color: AppTheme.purple(isDark), fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.purple(isDark)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          appState.selectAndAnalyzeTimetableImage('Gallery_Timetable_Doc.png');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Image Selected from Device Storage!'),
                              backgroundColor: AppTheme.cyanPrimary,
                            ),
                          );
                        },
                        icon: Icon(Icons.photo_library_rounded, size: 16, color: AppTheme.cyan(isDark)),
                        label: Text('Upload File', style: TextStyle(color: AppTheme.cyan(isDark), fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.cyan(isDark)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    onPressed: appState.isAnalyzingTimetable
                        ? null
                        : () => appState.selectAndAnalyzeTimetableImage(appState.selectedTimetableImageName ?? 'CS_Semester_4_Schedule_Scan.png'),
                    icon: appState.isAnalyzingTimetable
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
                    label: const Text(
                      'RUN AI VISION OCR SCAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.purple(isDark),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 6,
                      shadowColor: AppTheme.purple(isDark).withValues(alpha: 0.4),
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
                Icon(Icons.smart_toy_rounded, color: AppTheme.purple(isDark), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI VISION ROUTE DECISION OUTPUT',
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
                        style: TextStyle(color: AppTheme.textPrimary(isDark), fontSize: 12.5),
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
                'WEEKLY TIMELINE',
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
                    Icon(Icons.add_circle_outline_rounded, color: AppTheme.cyan(isDark), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Add Class',
                      style: TextStyle(color: AppTheme.cyan(isDark), fontSize: 12, fontWeight: FontWeight.bold),
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
              children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].map((day) {
                final isSel = _selectedDay == day;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.cyan(isDark) : (isDark ? AppTheme.darkSurface : AppTheme.lightSurface),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel ? AppTheme.cyan(isDark) : AppTheme.cyan(isDark).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        color: isSel ? Colors.white : AppTheme.textPrimary(isDark),
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Timeline Class Items
          if (dayClasses.isEmpty)
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No classes scheduled for this day.',
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

  Widget _buildImageSampleChip(String imageName, AppState appState, bool isDark) {
    final isSelected = appState.selectedTimetableImageName == imageName;
    return GestureDetector(
      onTap: () => appState.selectAndAnalyzeTimetableImage(imageName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.purple(isDark) : AppTheme.purple(isDark).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.purple(isDark).withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.image_outlined, size: 14, color: isSelected ? Colors.white : AppTheme.purple(isDark)),
            const SizedBox(width: 6),
            Text(
              imageName,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.purple(isDark),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, AppState appState, TimetableItem item, bool isDark) {
    return GlassContainer(
      borderRadius: 20,
      borderColor: item.isNextClass ? AppTheme.cyan(isDark) : null,
      gradientColors: item.isNextClass
          ? [AppTheme.cyan(isDark).withValues(alpha: 0.15), (isDark ? AppTheme.darkCard : AppTheme.lightSurface).withValues(alpha: 0.8)]
          : null,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              if (item.isNextClass)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.amber(isDark),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NEXT CLASS',
                    style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
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
              Icon(Icons.location_on_rounded, color: AppTheme.textSecondary(isDark), size: 14),
              const SizedBox(width: 4),
              Text(
                '${item.venueCode} (${item.building}, Level ${item.level})',
                style: TextStyle(color: AppTheme.textSecondary(isDark), fontSize: 12),
              ),
              const Spacer(),
              Icon(Icons.person_outline_rounded, color: AppTheme.textMuted(isDark), size: 14),
              const SizedBox(width: 4),
              Text(
                item.instructor,
                style: TextStyle(color: AppTheme.textMuted(isDark), fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // AI Recommendation Note
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkBg : AppTheme.lightSurface).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: AppTheme.purple(isDark), size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.aiRecommendation,
                    style: TextStyle(color: AppTheme.textPrimary(isDark), fontSize: 11),
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
              icon: const Icon(Icons.navigation_rounded, size: 14, color: Colors.white),
              label: const Text('GET AI INDOOR ROUTE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cyan(isDark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
