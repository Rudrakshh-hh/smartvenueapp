import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/navigation_modal.dart';

class HomeScreen extends StatelessWidget {
  final Function(int tabIndex) onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final nextClass = appState.nextClass;
    final isDark = appState.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HERO SECTION (CONTAINER 1)
          _buildHeroSection(context, appState, isDark),
          const SizedBox(height: 18),

          // 2. NEXT CLASS TO ATTEND CONTAINER (CONTAINER 2)
          if (nextClass != null) ...[
            _buildNextClassContainer(context, appState, nextClass, isDark),
            const SizedBox(height: 18),
          ],

          // 3. SEARCH BAR CONTAINER
          _buildSearchBar(context, appState, isDark),
          const SizedBox(height: 18),

          // 4. CONTAINERS OF "FIND VENUE" & "FIND EMPTY VENUE"
          _buildFindVenueAndEmptyRow(context, appState, isDark),
          const SizedBox(height: 18),

          // 5. QUICK ACCESS GRID
          _buildQuickAccessSection(context, appState, isDark),
          const SizedBox(height: 18),

          // 6. RECENT SEARCHES CONTAINER
          _buildRecentSearchesSection(context, appState, isDark),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // HERO SECTION (CONTAINER 1)
  Widget _buildHeroSection(BuildContext context, AppState appState, bool isDark) {
    return GlassContainer(
      borderRadius: 24,
      gradientColors: [
        (isDark ? AppTheme.darkSurface : AppTheme.lightSurface).withValues(alpha: isDark ? 0.9 : 0.95),
        (isDark ? AppTheme.darkCard : AppTheme.lightCard).withValues(alpha: isDark ? 0.7 : 0.85),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${appState.userName}',
                      style: TextStyle(
                        color: AppTheme.textPrimary(isDark),
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${appState.studentId} • ${appState.userDepartment}',
                      style: TextStyle(
                        color: AppTheme.textMuted(isDark),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: AppTheme.neonGlowDecoration(
                  color: AppTheme.emerald(isDark),
                  borderRadius: 20,
                  isDark: isDark,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: AppTheme.emerald(isDark), size: 8),
                    const SizedBox(width: 6),
                    Text(
                      'IPS ACTIVE',
                      style: TextStyle(
                        color: AppTheme.emerald(isDark),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: (isDark ? Colors.white : Colors.black12).withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 12),

          // Live Position Pill & IPS Status
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.my_location_rounded, color: AppTheme.cyan(isDark), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Zone', style: TextStyle(color: AppTheme.textMuted(isDark), fontSize: 10)),
                          Text(
                            '${appState.currentBuilding} (L${appState.currentLevel})',
                            style: TextStyle(color: AppTheme.textPrimary(isDark), fontSize: 12.5, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.sensors_rounded, color: AppTheme.purple(isDark), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fused Hardware', style: TextStyle(color: AppTheme.textMuted(isDark), fontSize: 10)),
                          Text(
                            'BLE + PDR + ArUco',
                            style: TextStyle(color: AppTheme.textPrimary(isDark), fontSize: 12.5, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // NEXT CLASS TO ATTEND CONTAINER (CONTAINER 2)
  Widget _buildNextClassContainer(BuildContext context, AppState appState, nextClass, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppTheme.cyan(isDark).withValues(alpha: isDark ? 0.12 : 0.18),
            AppTheme.purple(isDark).withValues(alpha: isDark ? 0.12 : 0.18),
          ],
        ),
        border: Border.all(color: AppTheme.cyan(isDark).withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cyan(isDark).withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.cyan(isDark),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.schedule_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'NEXT CLASS TO ATTEND',
                        style: TextStyle(
                          color: AppTheme.cyan(isDark),
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.amber(isDark).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.amber(isDark).withValues(alpha: 0.6)),
                ),
                child: Text(
                  'IN 15 MINS',
                  style: TextStyle(
                    color: AppTheme.amber(isDark),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Course Code & Title
          Text(
            '${nextClass.courseCode}: ${nextClass.courseTitle}',
            style: TextStyle(
              color: AppTheme.textPrimary(isDark),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Icon(Icons.room_outlined, color: AppTheme.textSecondary(isDark), size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${nextClass.venueCode} • ${nextClass.building} (L${nextClass.level})',
                  style: TextStyle(color: AppTheme.textSecondary(isDark), fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.access_time_rounded, color: AppTheme.textSecondary(isDark), size: 16),
              const SizedBox(width: 4),
              Text(
                '${nextClass.startTime} - ${nextClass.endTime}',
                style: TextStyle(color: AppTheme.textSecondary(isDark), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // AI Optimal Route Insight
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkBg : AppTheme.lightSurface).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cyan(isDark).withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: AppTheme.cyan(isDark), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    nextClass.aiRecommendation,
                    style: TextStyle(color: AppTheme.textPrimary(isDark), fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Start Navigation Trigger Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                final targetVenue = appState.venues.firstWhere(
                  (v) => v.code == nextClass.venueCode,
                  orElse: () => appState.venues.first,
                );
                appState.startNavigation(targetVenue);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const NavigationModal(),
                );
              },
              icon: const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
              label: const Text(
                'START INDOOR NAVIGATION (D* LITE)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cyan(isDark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                shadowColor: AppTheme.cyan(isDark).withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SEARCH BAR CONTAINER
  Widget _buildSearchBar(BuildContext context, AppState appState, bool isDark) {
    return GestureDetector(
      onTap: () => onNavigateToTab(1),
      child: GlassContainer(
        borderRadius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppTheme.cyan(isDark), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search venues, labs, halls or room code...',
                style: TextStyle(color: AppTheme.textMuted(isDark), fontSize: 13.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.cyan(isDark).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.tune_rounded, color: AppTheme.cyan(isDark), size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // FIND VENUE & FIND EMPTY VENUE CONTAINERS
  Widget _buildFindVenueAndEmptyRow(BuildContext context, AppState appState, bool isDark) {
    final emptyCount = appState.availableVacantVenues.length;

    return Row(
      children: [
        // Find Venue Card
        Expanded(
          child: GlassContainer(
            borderRadius: 20,
            onTap: () => onNavigateToTab(1),
            gradientColors: [
              AppTheme.blue(isDark).withValues(alpha: isDark ? 0.2 : 0.15),
              (isDark ? AppTheme.darkCard : AppTheme.lightSurface).withValues(alpha: 0.85),
            ],
            borderColor: AppTheme.blue(isDark).withValues(alpha: 0.4),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.blue(isDark).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.map_rounded, color: AppTheme.blue(isDark), size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  'Find Venue',
                  style: TextStyle(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'IMDF Plans & 3D Maps',
                  style: TextStyle(color: AppTheme.textMuted(isDark), fontSize: 10.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Find Empty Venue Card
        Expanded(
          child: GlassContainer(
            borderRadius: 20,
            onTap: () => onNavigateToTab(3),
            gradientColors: [
              AppTheme.emerald(isDark).withValues(alpha: isDark ? 0.2 : 0.15),
              (isDark ? AppTheme.darkCard : AppTheme.lightSurface).withValues(alpha: 0.85),
            ],
            borderColor: AppTheme.emerald(isDark).withValues(alpha: 0.4),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.emerald(isDark).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.meeting_room_outlined, color: AppTheme.emerald(isDark), size: 22),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.emerald(isDark),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$emptyCount OPEN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Find Empty Room',
                  style: TextStyle(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Real-time Vacant Spaces',
                  style: TextStyle(color: AppTheme.textMuted(isDark), fontSize: 10.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // QUICK ACCESS GRID
  Widget _buildQuickAccessSection(BuildContext context, AppState appState, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACCESS',
          style: TextStyle(
            color: AppTheme.cyan(isDark),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.1,
          children: [
            _buildQuickAccessTile(
              context,
              title: 'ArUco Vision Scan',
              subtitle: '3D Pose Recalibrate',
              icon: Icons.qr_code_scanner_rounded,
              color: AppTheme.cyan(isDark),
              isDark: isDark,
              onTap: () {
                appState.triggerArUcoRecalibration();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('ArUco Camera Vision Scan Completed! Position calibrated.'),
                    backgroundColor: AppTheme.cyan(isDark),
                  ),
                );
              },
            ),
            _buildQuickAccessTile(
              context,
              title: 'AI Timetable Scan',
              subtitle: 'Upload Schedule Image',
              icon: Icons.auto_awesome_rounded,
              color: AppTheme.purple(isDark),
              isDark: isDark,
              onTap: () => onNavigateToTab(2),
            ),
            _buildQuickAccessTile(
              context,
              title: 'IMDF 3D View',
              subtitle: 'Campus Floor Blueprint',
              icon: Icons.layers_rounded,
              color: AppTheme.blue(isDark),
              isDark: isDark,
              onTap: () => onNavigateToTab(1),
            ),
            _buildQuickAccessTile(
              context,
              title: 'Campus Heatmap',
              subtitle: 'Avoid Hallway Traffic',
              icon: Icons.local_fire_department_rounded,
              color: AppTheme.amber(isDark),
              isDark: isDark,
              onTap: () => onNavigateToTab(3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      borderRadius: 16,
      onTap: onTap,
      borderColor: color.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: AppTheme.textMuted(isDark), fontSize: 9.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // RECENT SEARCHES CONTAINER
  Widget _buildRecentSearchesSection(BuildContext context, AppState appState, bool isDark) {
    if (appState.recentSearches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT SEARCHES',
              style: TextStyle(
                color: AppTheme.cyan(isDark),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            GestureDetector(
              onTap: () => appState.clearRecentSearches(),
              child: Text(
                'Clear All',
                style: TextStyle(color: AppTheme.textMuted(isDark), fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: appState.recentSearches.map((term) {
            return GestureDetector(
              onTap: () {
                appState.setSearchQuery(term);
                onNavigateToTab(1);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.cyan(isDark).withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_rounded, color: AppTheme.textMuted(isDark), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      term,
                      style: TextStyle(color: AppTheme.textPrimary(isDark), fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
