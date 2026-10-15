import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cyber_background.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'analyser/timetable_analyser_screen.dart';
import 'available/available_venues_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  void _onTabTapped(int index) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setTabIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentIndex = appState.currentTabIndex;
    final isDark = appState.isDarkMode;

    final List<Widget> screens = [
      HomeScreen(onNavigateToTab: _onTabTapped),
      const SearchScreen(),
      const TimetableAnalyserScreen(),
      const AvailableVenuesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: CyberBackground(
        child: Column(
          children: [
            // Top Futuristic App Bar
            _buildFuturisticAppBar(context, appState, isDark),

            // Active Tab View
            Expanded(
              child: IndexedStack(index: currentIndex, children: screens),
            ),
          ],
        ),
      ),

      // Floating Glass Bottom Navigation Bar
      bottomNavigationBar: _buildFuturisticBottomBar(
        context,
        currentIndex,
        isDark,
      ),
    );
  }

  Widget _buildFuturisticAppBar(
    BuildContext context,
    AppState appState,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.darkSurface : AppTheme.lightSurface)
            .withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.cyanPrimary.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: AppTheme.neonGlowDecoration(
                    color: AppTheme.cyanPrimary,
                    borderRadius: 12,
                    isDark: isDark,
                  ),
                  child: const Icon(
                    Icons.radar_rounded,
                    color: AppTheme.cyanPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SMART VENUE',
                      style: TextStyle(
                        color: AppTheme.textPrimary(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Text(
                      'AI IPS & TIMETABLE ROUTING',
                      style: TextStyle(
                        color: AppTheme.cyanPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Row(
              children: [
                // Theme Switcher Button (Sun / Moon)
                IconButton(
                  icon: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    color: isDark
                        ? AppTheme.amberWarning
                        : AppTheme.purpleAccent,
                    size: 20,
                  ),
                  tooltip: isDark
                      ? 'Switch to White Theme'
                      : 'Switch to Dark Theme',
                  onPressed: () => appState.toggleTheme(),
                ),

                // Live Location Indicator Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? AppTheme.darkBg : AppTheme.lightCard)
                        .withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.cyanPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppTheme.cyanPrimary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'L${appState.currentLevel} • Tech A',
                        style: TextStyle(
                          color: AppTheme.textPrimary(isDark),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuturisticBottomBar(
    BuildContext context,
    int currentIndex,
    bool isDark,
  ) {
    final navItems = [
      {'label': 'Home', 'icon': Icons.home_rounded},
      {'label': 'Search', 'icon': Icons.search_rounded},
      {'label': 'Analyser', 'icon': Icons.auto_awesome_rounded},
      {'label': 'Available', 'icon': Icons.meeting_room_rounded},
      {'label': 'Profile', 'icon': Icons.person_rounded},
    ];

    return Container(
      margin: const EdgeInsets.only(left: 14, right: 14, bottom: 16),
      height: 68,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkSurface : AppTheme.lightSurface)
                  .withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.cyanPrimary.withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cyanPrimary.withValues(
                    alpha: isDark ? 0.12 : 0.18,
                  ),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final isSelected = currentIndex == index;
                final item = navItems[index];
                final isAnalyser = index == 2;

                final activeColor = isAnalyser
                    ? AppTheme.purpleAccent
                    : AppTheme.cyanPrimary;

                return GestureDetector(
                  onTap: () => _onTabTapped(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? activeColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(
                              color: activeColor.withValues(alpha: 0.5),
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: isSelected
                              ? activeColor
                              : AppTheme.textMuted(isDark),
                          size: isSelected ? 22 : 20,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? activeColor
                                : AppTheme.textMuted(isDark),
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
