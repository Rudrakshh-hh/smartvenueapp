import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/navigation_modal.dart';
import '../../models/venue.dart';
import '../../widgets/floor_plan/floor_plan_map.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFloorView = 2; // Default to Level 2
  bool _showMapMode = true;

  final GlobalKey<FloorPlanMapState> _mapKey = GlobalKey<FloorPlanMapState>();
  String? _selectedRoomId;

  static const Map<String, String> _venueCodeToRoomId = {
    'SH': 'cr117',
    'SP': 'room109',
  };

  String? _roomIdFor(Venue v) {
    for (final e in _venueCodeToRoomId.entries) {
      if (v.code.contains(e.key)) return e.value;
    }
    return null;
  }

  Map<String, bool> _occupancy(AppState appState) {
    final result = <String, bool>{};
    for (final v in appState.venues) {
      final id = _roomIdFor(v);
      if (id != null) result[id] = v.isOccupied;
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _searchController.text = appState.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final venues = appState.filteredVenues;
    final occupancy = _occupancy(appState);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INDOOR EXPLORER',
                    style: TextStyle(
                      color: AppTheme.cyan(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'IMDF Map & Venues',
                    style: TextStyle(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Map vs List Mode Switcher
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.cyan(isDark).withValues(alpha: 0.3)),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _showMapMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _showMapMode ? AppTheme.cyan(isDark) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.map_rounded,
                          color: _showMapMode ? Colors.white : AppTheme.textMuted(isDark),
                          size: 18,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showMapMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: !_showMapMode ? AppTheme.cyan(isDark) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.list_rounded,
                          color: !_showMapMode ? Colors.white : AppTheme.textMuted(isDark),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Field
          TextField(
            controller: _searchController,
            style: TextStyle(color: AppTheme.textPrimary(isDark)),
            onChanged: (val) {
              appState.setSearchQuery(val);
              appState.addRecentSearch(val);
            },
            decoration: InputDecoration(
              hintText: 'Search by room code, lecture hall, or lab name...',
              prefixIcon: Icon(Icons.search_rounded, color: AppTheme.cyan(isDark)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: AppTheme.textMuted(isDark)),
                      onPressed: () {
                        _searchController.clear();
                        appState.setSearchQuery('');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // Level Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLevelChip('All Levels', null, appState, isDark),
                const SizedBox(width: 8),
                _buildLevelChip('Level 1', 1, appState, isDark),
                const SizedBox(width: 8),
                _buildLevelChip('Level 2', 2, appState, isDark),
                const SizedBox(width: 8),
                _buildLevelChip('Level 3', 3, appState, isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // IMDF MAP VIEWER (if map mode enabled)
          if (_showMapMode) ...[
            GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.layers_rounded, color: AppTheme.cyan(isDark), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'IMDF LEVEL BLUEPRINT',
                            style: TextStyle(
                              color: AppTheme.cyan(isDark),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),

                      // Floor Switcher Pills
                      Row(
                        children: [1, 2, 3].map((floor) {
                          final isSel = _selectedFloorView == floor;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedFloorView = floor),
                            child: Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSel ? AppTheme.cyan(isDark) : (isDark ? AppTheme.darkBg : AppTheme.lightCard),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.cyan(isDark).withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                'L$floor',
                                style: TextStyle(
                                  color: isSel ? Colors.white : AppTheme.textPrimary(isDark),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Map Blueprint Canvas
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.darkBg : AppTheme.lightCard),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.blue(isDark).withValues(alpha: 0.3)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        FloorPlanMap(
                          key: _mapKey,
                          occupancy: occupancy,
                          selectedRoomId: _selectedRoomId,
                          onRoomTap: (room) => setState(() => _selectedRoomId = room.id),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            tooltip: 'Full screen',
                            icon: Icon(Icons.fullscreen, color: AppTheme.cyan(isDark)),
                            onPressed: () => FloorPlanFullScreen.open(
                              context,
                              occupancy: occupancy,
                              selectedRoomId: _selectedRoomId,
                              onRoomTap: (room) => setState(() => _selectedRoomId = room.id),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // MATCHING VENUES LIST
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FOUND VENUES (${venues.length})',
                style: TextStyle(
                  color: AppTheme.cyan(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (venues.isEmpty)
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No venues matching your query found.',
                  style: TextStyle(color: AppTheme.textMuted(isDark)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: venues.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final venue = venues[index];
                return _buildVenueCard(context, appState, venue, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLevelChip(String label, int? level, AppState appState, bool isDark) {
    final isSelected = appState.selectedLevelFilter == level;
    return GestureDetector(
      onTap: () => appState.setLevelFilter(level),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cyan(isDark).withValues(alpha: 0.25) : (isDark ? AppTheme.darkSurface : AppTheme.lightSurface),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.cyan(isDark) : AppTheme.cyan(isDark).withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.cyan(isDark) : AppTheme.textSecondary(isDark),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildVenueCard(BuildContext context, AppState appState, Venue venue, bool isDark) {
    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.cyan(isDark).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cyan(isDark).withValues(alpha: 0.3)),
                ),
                child: Icon(Icons.meeting_room_rounded, color: AppTheme.cyan(isDark), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          venue.code,
                          style: TextStyle(
                            color: AppTheme.cyan(isDark),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: venue.isOccupied
                                ? AppTheme.roseAlert.withValues(alpha: 0.2)
                                : AppTheme.emeraldSuccess.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: venue.isOccupied ? AppTheme.roseAlert : AppTheme.emeraldSuccess,
                            ),
                          ),
                          child: Text(
                            venue.isOccupied ? 'OCCUPIED' : 'VACANT',
                            style: TextStyle(
                              color: venue.isOccupied ? AppTheme.roseAlert : AppTheme.emeraldSuccess,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
                      '${venue.building} • Level ${venue.level} • ${venue.category}',
                      style: TextStyle(color: AppTheme.textMuted(isDark), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Current Status / Activity line
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkBg : AppTheme.lightSurface).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  venue.isOccupied ? Icons.info_outline : Icons.check_circle_outline,
                  size: 14,
                  color: venue.isOccupied ? AppTheme.amberWarning : AppTheme.emeraldSuccess,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    venue.currentActivity,
                    style: TextStyle(color: AppTheme.textPrimary(isDark), fontSize: 11),
                  ),
                ),
                Text(
                  '${venue.distanceMeters.toInt()}m away',
                  style: TextStyle(color: AppTheme.cyan(isDark), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 42,
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
              icon: const Icon(Icons.navigation_rounded, size: 16, color: Colors.white),
              label: const Text(
                'NAVIGATE HERE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cyan(isDark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
