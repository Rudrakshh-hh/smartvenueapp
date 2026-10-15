import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/navigation_modal.dart';
import '../../models/venue.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  bool _showMapMode = true;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _searchController.text = appState.searchQuery;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    return Theme(
      data: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      child: Scaffold(
        backgroundColor: Colors.black, // FORCE SCAFFOLD BLACK
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 16),
              _buildSearchField(appState, isDark),
              const SizedBox(height: 16),
              
              if (_showMapMode) ...[
                _buildDittoMap(),
                const SizedBox(height: 20),
              ],

              _buildVenueList(appState.filteredVenues, appState, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDittoMap() {
    return Container(
      height: 550,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black, // Container background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2), // High contrast border
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Layer 0: Hardcoded Black Base
            const Positioned.fill(child: ColoredBox(color: Colors.black)),
            
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(0.0005, 0),
                initialZoom: 17.2,
                backgroundColor: Colors.black, // Force library background
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                // Layer 1: Floor Base Polygon (Pure Black)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: [LatLng(0.1, -0.1), LatLng(0.1, 0.1), LatLng(-0.1, 0.1), LatLng(-0.1, -0.1)],
                      color: Colors.black,
                      borderColor: Colors.transparent,
                    ),
                  ],
                ),
                // Layer 2: Blueprint Geometry (Solid White Lines)
                PolygonLayer(
                  polygons: _buildBlueprintGeometry(),
                ),
                
                // Layer 3: Room Names (Pure White Bold Text)
                MarkerLayer(
                  markers: _buildBlueprintLabels(),
                ),

                // Layer 4: IPS Status Pins
                MarkerLayer(
                  markers: _buildStatusPins(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Polygon> _buildBlueprintGeometry() {
    const border = Colors.white; 
    const fill = Colors.black; 

    return [
      // TOP ROW CLASSROOMS
      _r(LatLng(0.0045, -0.0045), LatLng(0.0030, -0.0023), border, fill), // 113
      _r(LatLng(0.0045, -0.0023), LatLng(0.0030, -0.0008), border, fill), // 114
      _r(LatLng(0.0045, -0.0008), LatLng(0.0030, 0.0007), border, fill),  // 115
      _r(LatLng(0.0045, 0.0007), LatLng(0.0030, 0.0020), border, fill),   // 116
      _r(LatLng(0.0045, 0.0020), LatLng(0.0030, 0.0048), border, fill),   // 117

      // MAIN HORIZONTAL CORRIDOR
      _r(LatLng(0.0030, -0.0055), LatLng(0.0022, 0.0055), border, fill),

      // LEFT SIDE WING
      _r(LatLng(0.0015, -0.0058), LatLng(0.0006, -0.0048), border, fill), // 112
      _r(LatLng(0.0015, -0.0048), LatLng(0.0006, -0.0038), border, fill), // 111
      _r(LatLng(0.0015, -0.0038), LatLng(0.0006, -0.0028), border, fill), // 110
      _r(LatLng(0.0006, -0.0048), LatLng(-0.0010, -0.0028), border, fill), // 109

      // CENTRAL BLOCK
      _r(LatLng(0.0015, -0.0021), LatLng(-0.0014, 0.0010), border, fill), // Wifi Zone
      _r(LatLng(-0.0006, -0.0014), LatLng(-0.0014, -0.0008), border, border), // Main Lift
      _r(LatLng(-0.0006, 0.0001), LatLng(-0.0014, 0.0007), border, border),  // Female Lift

      // RIGHT SIDE WING
      _r(LatLng(0.0015, 0.0016), LatLng(0.0006, 0.0026), border, fill), // 120
      _r(LatLng(0.0015, 0.0026), LatLng(0.0006, 0.0036), border, fill), // 119
      _r(LatLng(0.0015, 0.0036), LatLng(0.0008, 0.0046), border, fill), // 118
      _r(LatLng(0.0006, 0.0016), LatLng(-0.0010, 0.0036), border, fill), // 121

      // BOTTOM BLOCKS
      _r(LatLng(-0.0023, -0.0024), LatLng(-0.0045, -0.0011), border, fill), // 108
      _r(LatLng(-0.0023, 0.0011), LatLng(-0.0045, 0.0024), border, fill), // Right Bot
    ];
  }

  Polygon _r(LatLng tl, LatLng br, Color b, Color f) => Polygon(
    points: [LatLng(tl.latitude, tl.longitude), LatLng(tl.latitude, br.longitude), LatLng(br.latitude, br.longitude), LatLng(br.latitude, tl.longitude)],
    borderColor: b, borderStrokeWidth: 2.5, color: f, // Bold White lines
  );

  List<Marker> _buildBlueprintLabels() {
    const s = TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold); 
    return [
      _lbl(LatLng(0.0037, -0.0034), "Classroom 113", s),
      _lbl(LatLng(0.0037, -0.0016), "Classroom 114", s),
      _lbl(LatLng(0.0037, -0.0001), "Classroom 115", s),
      _lbl(LatLng(0.0037, 0.0013), "Classroom 116", s),
      _lbl(LatLng(0.0037, 0.0034), "Classroom 117", s),
      _lbl(LatLng(0.0011, -0.0053), "WashRoom Boys\nRoom 112", s),
      _lbl(LatLng(0.0011, -0.0043), "Faculty Washroom\nRoom 111", s),
      _lbl(LatLng(0.0011, -0.0033), "Faculty Room\nRoom 110", s),
      _lbl(LatLng(-0.0003, -0.0038), "Computer Lab 2\nRoom 109", s),
      _lbl(LatLng(0.0004, -0.0005), "Wifi Zone", s),
      _lbl(LatLng(-0.0010, -0.0011), "Main Lift", s.copyWith(fontSize: 5)),
      _lbl(LatLng(-0.0010, 0.0004), "Female Lift", s.copyWith(fontSize: 5)),
      _lbl(LatLng(0.0011, 0.0021), "ERP Cell\nRoom 120", s),
      _lbl(LatLng(0.0011, 0.0031), "Room 119", s),
      _lbl(LatLng(0.0012, 0.0041), "WashRoom Girls\nRoom 118", s),
      _lbl(LatLng(-0.0003, 0.0026), "Computer Lab 9\nRoom 121", s),
      _lbl(LatLng(-0.0034, -0.0017), "Room 108\nServer Room", s),
      _lbl(LatLng(0.0026, 0.0052), "Stair 2", s),
    ];
  }

  Marker _lbl(LatLng p, String t, TextStyle s) => Marker(point: p, width: 110, height: 45, child: Center(child: Text(t.replaceAll("\\n", "\n"), style: s, textAlign: TextAlign.center)));

  List<Marker> _buildStatusPins(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return appState.venues.where((v) => v.level == 1).map((v) {
      LatLng pos = LatLng(0,0);
      if (v.code.contains('SH')) pos = LatLng(0.0037, 0.0034); 
      if (v.code.contains('SP')) pos = LatLng(-0.0003, -0.0038); 
      if (pos.latitude == 0) return Marker(point: LatLng(0,0), child: const SizedBox());
      return Marker(point: pos, width: 12, height: 12, child: Container(decoration: BoxDecoration(color: v.isOccupied ? Colors.red : Colors.greenAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5), boxShadow: [BoxShadow(color: v.isOccupied ? Colors.red : Colors.greenAccent, blurRadius: 8)])));
    }).toList();
  }

  Widget _buildHeader(bool isDark) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('CAMPUS NAVIGATOR', style: TextStyle(color: AppTheme.cyan(isDark), fontSize: 12, fontWeight: FontWeight.bold)),
      Text('Blueprint: Back Wing', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
    ]),
    IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: () => _mapController.move(LatLng(0.0005, 0), 17.2)),
  ]);

  Widget _buildSearchField(AppState appState, bool isDark) => TextField(
    controller: _searchController,
    style: const TextStyle(color: Colors.white),
    onChanged: (v) => appState.setSearchQuery(v),
    decoration: const InputDecoration(hintText: 'Enter Room Number...', prefixIcon: Icon(Icons.search, color: Colors.white)),
  );

  Widget _buildVenueList(List<Venue> venues, AppState appState, bool isDark) => ListView.builder(
    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    itemCount: venues.length,
    itemBuilder: (c, i) => ListTile(
      title: Text(venues[i].name, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(venues[i].code, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 14),
      onTap: () { appState.startNavigation(venues[i]); showModalBottomSheet(context: c, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (c) => const NavigationModal()); },
    ),
  );
}
