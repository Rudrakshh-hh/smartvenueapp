import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/navigation_modal.dart';
import '../../models/venue.dart';

class AvailableVenuesScreen extends StatefulWidget {
  const AvailableVenuesScreen({super.key});

  @override
  State<AvailableVenuesScreen> createState() => _AvailableVenuesScreenState();
}

class _AvailableVenuesScreenState extends State<AvailableVenuesScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final available = appState.availableVacantVenues.where((v) {
      if (_selectedCategory == null) return true;
      return v.category == _selectedCategory;
    }).toList();

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
                  color: AppTheme.emerald(isDark),
                  borderRadius: 16,
                  isDark: isDark,
                ),
                child: Icon(Icons.meeting_room_outlined, color: AppTheme.emerald(isDark), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REAL-TIME OCCUPANCY',
                      style: TextStyle(
                        color: AppTheme.emerald(isDark),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Find Empty Venue',
                          style: TextStyle(
                            color: AppTheme.textPrimary(isDark),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.emerald(isDark),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${available.length} LIVE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All Categories', null, isDark),
                const SizedBox(width: 8),
                _buildCategoryChip('Lecture Hall', 'Lecture Hall', isDark),
                const SizedBox(width: 8),
                _buildCategoryChip('Computer Lab', 'Computer Lab', isDark),
                const SizedBox(width: 8),
                _buildCategoryChip('Study Pod', 'Study Pod', isDark),
                const SizedBox(width: 8),
                _buildCategoryChip('Seminar Hall', 'Seminar Hall', isDark),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // List of Available Vacant Venues
          if (available.isEmpty)
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No empty venues found in this category.',
                  style: TextStyle(color: AppTheme.textMuted(isDark)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: available.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final venue = available[index];
                return _buildVacantVenueCard(context, appState, venue, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category, bool isDark) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.emerald(isDark).withValues(alpha: 0.25) : (isDark ? AppTheme.darkSurface : AppTheme.lightSurface),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.emerald(isDark) : AppTheme.emerald(isDark).withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.emerald(isDark) : AppTheme.textSecondary(isDark),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildVacantVenueCard(BuildContext context, AppState appState, Venue venue, bool isDark) {
    return GlassContainer(
      borderRadius: 20,
      borderColor: AppTheme.emerald(isDark).withValues(alpha: 0.5),
      gradientColors: [
        AppTheme.emerald(isDark).withValues(alpha: isDark ? 0.1 : 0.08),
        (isDark ? AppTheme.darkCard : AppTheme.lightSurface).withValues(alpha: 0.85),
      ],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.emerald(isDark).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded, color: AppTheme.emerald(isDark), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.code,
                      style: TextStyle(
                        color: AppTheme.emerald(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      venue.name,
                      style: TextStyle(
                        color: AppTheme.textPrimary(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${venue.building} (Level ${venue.level})',
                      style: TextStyle(color: AppTheme.textMuted(isDark), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.darkBg : AppTheme.lightCard).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      '${venue.capacity} SEATS',
                      style: TextStyle(
                        color: AppTheme.textPrimary(isDark),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'VACANT',
                      style: TextStyle(
                        color: AppTheme.emerald(isDark),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status & Distance
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkBg : AppTheme.lightSurface).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_filled_rounded, color: AppTheme.emerald(isDark), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    venue.currentActivity,
                    style: TextStyle(color: AppTheme.textPrimary(isDark), fontSize: 11.5),
                  ),
                ),
                Text(
                  '${venue.distanceMeters.toInt()}m away',
                  style: TextStyle(color: AppTheme.cyan(isDark), fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tags
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: venue.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.cyan(isDark).withValues(alpha: 0.15)),
                ),
                child: Text(
                  '# $tag',
                  style: TextStyle(color: AppTheme.textMuted(isDark), fontSize: 10),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Claim / Navigate Now Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                appState.startNavigation(venue);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const NavigationModal(),
                );
              },
              icon: const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
              label: const Text(
                'NAVIGATE TO VACANT VENUE NOW',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emerald(isDark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
