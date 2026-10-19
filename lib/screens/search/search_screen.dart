import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/navigation_modal.dart';
import '../../models/venue.dart';
import '../../widgets/floor_plan/floor_plan_data.dart';
import '../../widgets/floor_plan/floor_plan_map.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FloorPlanMapState> _mapKey = GlobalKey<FloorPlanMapState>();
  String? _selectedRoomId;

  /// Connects your venues to shapes on the plan.
  /// key = text contained in venue.code, value = PlanRoom id
  /// (ids are in floor_plan_data.dart, e.g. 'cr113', 'room109', 'lt106').
  /// Add one line per venue as you add them.
  static const Map<String, String> _venueCodeToRoomId = {
    'SH': 'cr117',
    'SP': 'room109',
  };

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

  String? _roomIdFor(Venue v) {
    for (final e in _venueCodeToRoomId.entries) {
      if (v.code.contains(e.key)) return e.value;
    }
    return null;
  }

  Venue? _venueForRoom(AppState appState, String roomId) {
    for (final v in appState.venues) {
      if (_roomIdFor(v) == roomId) return v;
    }
    return null;
  }

  /// roomId -> isOccupied, for the status tint + pins on the map.
  Map<String, bool> _occupancy(AppState appState) {
    final result = <String, bool>{};
    for (final v in appState.venues.where((v) => v.level == 1)) {
      final id = _roomIdFor(v);
      if (id != null) result[id] = v.isOccupied;
    }
    return result;
  }

  void _openNavigation(AppState appState, Venue venue) {
    appState.startNavigation(venue);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NavigationModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final occupancy = _occupancy(appState);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(appState.isDarkMode),
            const SizedBox(height: 16),
            _buildSearchField(appState),
            const SizedBox(height: 16),
            _buildMapCard(appState, occupancy),
            const SizedBox(height: 10),
            _buildSelectionBar(appState),
            const SizedBox(height: 6),
            Expanded(child: _buildVenueList(appState.filteredVenues, appState)),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard(AppState appState, Map<String, bool> occupancy) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
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
              icon: const Icon(Icons.fullscreen, color: Colors.white),
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
    );
  }

  /// Shows the tapped room's name + status, with a Navigate button
  /// when that room is linked to a venue.
  Widget _buildSelectionBar(AppState appState) {
    final id = _selectedRoomId;
    if (id == null) {
      return const Text(
        'Pinch to zoom • tap a room to select it',
        style: TextStyle(color: Colors.white38, fontSize: 12),
      );
    }

    String name = id;
    for (final r in kFirstFloorRooms) {
      if (r.id == id) name = r.displayName;
    }
    final venue = _venueForRoom(appState, id);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (venue != null)
                Text(
                  venue.isOccupied ? 'Occupied' : 'Available',
                  style: TextStyle(
                    color: venue.isOccupied ? Colors.redAccent : Colors.greenAccent,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        if (venue != null)
          TextButton.icon(
            onPressed: () => _openNavigation(appState, venue),
            icon: const Icon(Icons.navigation_outlined, size: 18),
            label: const Text('Navigate'),
          ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CAMPUS BLUEPRINT',
                style: TextStyle(
                  color: AppTheme.cyan(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'First Floor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _mapKey.currentState?.resetView();
              setState(() => _selectedRoomId = null);
            },
          ),
        ],
      );

  Widget _buildSearchField(AppState appState) => TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (v) => appState.setSearchQuery(v),
        decoration: const InputDecoration(
          hintText: 'Search room...',
          prefixIcon: Icon(Icons.search, color: Colors.white),
        ),
      );

  Widget _buildVenueList(List<Venue> venues, AppState appState) =>
      ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: venues.length,
        itemBuilder: (c, i) {
          final venue = venues[i];
          return ListTile(
            title: Text(
              venue.name,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            subtitle: Text(
              venue.code,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.white38,
              size: 14,
            ),
            onTap: () {
              final roomId = _roomIdFor(venue);
              if (roomId != null) setState(() => _selectedRoomId = roomId);
              _openNavigation(appState, venue);
            },
          );
        },
      );
}
