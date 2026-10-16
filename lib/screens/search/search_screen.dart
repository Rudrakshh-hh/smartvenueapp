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

    return Scaffold(
      backgroundColor: Colors.black, // FORCED PURE BLACK
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(appState.isDarkMode),
            const SizedBox(height: 16),
            _buildSearchField(appState),
            const SizedBox(height: 16),
            
            if (_showMapMode) ...[
              _buildIdenticalMap(),
              const SizedBox(height: 20),
            ],

            _buildVenueList(appState.filteredVenues, appState),
          ],
        ),
      ),
    );
  }

  Widget _buildIdenticalMap() {
    return Container(
      height: 750,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(color: Colors.black))),
            
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(0, 0),
                initialZoom: 15.5,
                backgroundColor: Colors.black,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: [const LatLng(1, -1), const LatLng(1, 1), const LatLng(-1, 1), const LatLng(-1, -1)],
                      color: Colors.black,
                      borderColor: Colors.transparent,
                    ),
                  ],
                ),
                PolygonLayer(
                  polygons: _buildFullFloorGeometry(),
                ),
                
                MarkerLayer(
                  markers: _buildFullFloorLabels(),
                ),

                MarkerLayer(
                  markers: _buildIpsPins(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Polygon> _buildFullFloorGeometry() {
    const border = Colors.white; 
    const fill = Colors.black; 

    return [
      // 1. TOP ROW: Classroom 113 to 117 + Stair 2 (with gaps for corridors)
      _r(LatLng(0.0155, -0.0070), LatLng(0.0135, -0.0042), border, fill), // 113
      _r(LatLng(0.0155, -0.0040), LatLng(0.0135, -0.0015), border, fill), // 114
      _r(LatLng(0.0155, -0.0010), LatLng(0.0135, 0.0015), border, fill),  // 115
      _r(LatLng(0.0155, 0.0020), LatLng(0.0135, 0.0045), border, fill),   // 116
      _r(LatLng(0.0155, 0.0050), LatLng(0.0135, 0.0075), border, fill),   // 117
      _r(LatLng(0.0155, 0.0078), LatLng(0.0135, 0.0088), border, fill),   // Stair 2

      // 2. BACK WING ROOMS (Leave wide gap for corridor below)
      _r(LatLng(0.0115, -0.0070), LatLng(0.0100, -0.0058), border, fill), // 112
      _r(LatLng(0.0115, -0.0055), LatLng(0.0100, -0.0042), border, fill), // 111
      _r(LatLng(0.0115, -0.0039), LatLng(0.0100, -0.0026), border, fill), // 110
      _r(LatLng(0.0095, -0.0055), LatLng(0.0060, -0.0026), border, fill), // 109 Lab 2

      _r(LatLng(0.0115, 0.0026), LatLng(0.0100, 0.0039), border, fill), // 120
      _r(LatLng(0.0115, 0.0042), LatLng(0.0100, 0.0055), border, fill), // 119
      _r(LatLng(0.0115, 0.0058), LatLng(0.0100, 0.0070), border, fill), // 118
      _r(LatLng(0.0095, 0.0026), LatLng(0.0060, 0.0055), border, fill), // 121 Lab 9

      // 3. CENTER LOBBY CORE (Wifi Zone)
      _r(LatLng(0.0105, -0.0018), LatLng(0.0055, 0.0018), border, fill), // Wifi Zone box
      _r(LatLng(0.0065, -0.0008), LatLng(0.0055, -0.0001), border, border), // Main Lift
      _r(LatLng(0.0065, 0.0001), LatLng(0.0055, 0.0008), border, border),  // Female Lift

      // 4. CENTRAL INNER CORE
      _r(LatLng(0.0045, -0.0012), LatLng(0.0015, 0.0012), border, fill), // Room 108 Server
      _r(LatLng(0.0045, 0.0018), LatLng(0.0015, 0.0030), border, fill),  // Room 122
      _r(LatLng(0.0020, -0.0025), LatLng(-0.0010, -0.0013), border, fill), // Room 107
      _r(LatLng(0.0020, 0.0030), LatLng(-0.0010, 0.0042), border, fill),  // Room 123

      // 5. SLANTED LECTURE THEATRES (Preserve slanted paths)
      Polygon( // LH-2 (128)
        points: [
          const LatLng(0.0080, -0.0085), const LatLng(0.0065, -0.0045),
          const LatLng(-0.0005, -0.0065), const LatLng(0.0010, -0.0105)
        ], borderColor: border, borderStrokeWidth: 1.5, color: fill,
      ),
      Polygon( // LH-1 (124)
        points: [
          const LatLng(0.0080, 0.0085), const LatLng(0.0065, 0.0045),
          const LatLng(-0.0005, 0.0065), const LatLng(0.0010, 0.0105)
        ], borderColor: border, borderStrokeWidth: 1.5, color: fill,
      ),

      // 6. MAIN POLYGONAL ATRIUM (Large central core)
      Polygon(
        points: [
          const LatLng(-0.0015, -0.0040), const LatLng(-0.0015, 0.0040),
          const LatLng(-0.0070, 0.0080), const LatLng(-0.0105, 0.0080),
          const LatLng(-0.0105, -0.0080), const LatLng(-0.0070, -0.0080),
        ],
        borderColor: border, borderStrokeWidth: 2.0, color: fill,
      ),

      // 7. SIDE WINGS (Leave large corridors)
      _r(LatLng(-0.0065, -0.0145), LatLng(-0.0125, -0.0100), border, fill), // TIC LAB MB
      _r(LatLng(-0.0065, 0.0100), LatLng(-0.0125, 0.0145), border, fill),   // Library Open Floor

      // SIDE SMALL WASHROOMS
      _r(LatLng(-0.0035, -0.0090), LatLng(-0.0055, -0.0078), border, fill), // WR Staff
      _r(LatLng(-0.0035, 0.0078), LatLng(-0.0055, 0.0090), border, fill),   // WR Female

      // 8. BOTTOM ADMIN ROW
      _r(LatLng(-0.0125, -0.0110), LatLng(-0.0140, 0.0110), border, fill), // Bottom Corridor
      _r(LatLng(-0.0145, -0.0055), LatLng(-0.0165, -0.0028), border, fill), // VC Office
      _r(LatLng(-0.0145, -0.0025), LatLng(-0.0165, 0.0005), border, fill),  // USR Cell
      _r(LatLng(-0.0145, 0.0065), LatLng(-0.0165, 0.0105), border, fill),   // Chairman Sr Office
      
      // Bottom Lifts
      _r(LatLng(-0.0105, -0.0010), LatLng(-0.0118, -0.0001), border, border), // SGF Lift L
      _r(LatLng(-0.0105, 0.0002), LatLng(-0.0118, 0.0011), border, border),  // SGF Lift R
      
      _r(LatLng(-0.0115, -0.0135), LatLng(-0.0135, -0.0115), border, fill), // WR KPI
    ];
  }

  Polygon _r(LatLng tl, LatLng br, Color b, Color f) => Polygon(
    points: [LatLng(tl.latitude, tl.longitude), LatLng(tl.latitude, br.longitude), LatLng(br.latitude, br.longitude), LatLng(br.latitude, tl.longitude)],
    borderColor: b, borderStrokeWidth: 1.0, color: f,
  );

  List<Marker> _buildFullFloorLabels() {
    const s = TextStyle(color: Colors.white, fontSize: 5.5, fontWeight: FontWeight.bold); 
    return [
      _lbl(const LatLng(0.0145, -0.0056), "Classroom 113", s),
      _lbl(const LatLng(0.0145, -0.0027), "Classroom 114", s),
      _lbl(const LatLng(0.0145, 0.0002), "Classroom 115", s),
      _lbl(const LatLng(0.0145, 0.0032), "Classroom 116", s),
      _lbl(const LatLng(0.0145, 0.0062), "Classroom 117", s),
      _lbl(const LatLng(0.0145, 0.0083), "Stair 2", s),
      
      _lbl(const LatLng(0.0107, -0.0064), "Room 112", s),
      _lbl(const LatLng(0.0107, -0.0048), "Room 111", s),
      _lbl(const LatLng(0.0107, -0.0032), "Room 110", s),
      _lbl(const LatLng(0.0078, -0.0040), "Computer Lab 2\nRoom 109", s),
      
      _lbl(const LatLng(0.0080, 0.0001), "Wifi Zone", s),
      _lbl(const LatLng(0.0060, -0.00045), "Main Lift", s.copyWith(fontSize: 3.5)),
      _lbl(const LatLng(0.0060, 0.00045), "Female Lift", s.copyWith(fontSize: 3.5)),

      _lbl(const LatLng(0.0107, 0.0032), "Room 120", s),
      _lbl(const LatLng(0.0107, 0.0048), "Room 119", s),
      _lbl(const LatLng(0.0107, 0.0064), "Room 118", s),
      _lbl(const LatLng(0.0078, 0.0040), "Computer Lab 9\nRoom 121", s),

      _lbl(const LatLng(0.0030, 0), "Room 108\nServer Room", s),
      _lbl(const LatLng(0.0030, 0.0024), "Room 122", s),
      _lbl(const LatLng(0.0003, 0.0036), "Room 123", s),
      _lbl(const LatLng(0.0003, -0.0019), "Room 107", s),

      _lbl(const LatLng(0.0040, -0.0075), "Lecture Theatre 128\nLH-2 (TIC)", s),
      _lbl(const LatLng(0.0040, 0.0075), "Lecture Theatre 124\nLH-1 (TIC)", s),

      _lbl(const LatLng(-0.0095, -0.0122), "TIC LAB MB\nTIC, L, TIC 2", s),
      _lbl(const LatLng(-0.0095, 0.0122), "Library Open Floor", s),

      _lbl(const LatLng(-0.0155, -0.0041), "Vice Chancellor's Office", s.copyWith(fontSize: 4)),
      _lbl(const LatLng(-0.0155, -0.0010), "USR Cell", s.copyWith(fontSize: 4)),
      _lbl(const LatLng(-0.0155, 0.0085), "Chairman Sr Office", s.copyWith(fontSize: 4)),
      
      _lbl(const LatLng(-0.0045, -0.0084), "WR Staff", s.copyWith(fontSize: 3.5)),
      _lbl(const LatLng(-0.0045, 0.0084), "WR Female", s.copyWith(fontSize: 3.5)),
      _lbl(const LatLng(-0.0111, 0), "SGF Lifts", s.copyWith(fontSize: 4)),
      _lbl(const LatLng(-0.0125, -0.0125), "WR KPI", s.copyWith(fontSize: 3.5)),
    ];
  }

  Marker _lbl(LatLng p, String t, TextStyle s) => Marker(point: p, width: 110, height: 45, child: Center(child: Text(t.replaceAll("\\n", "\n"), style: s, textAlign: TextAlign.center)));

  List<Marker> _buildIpsPins(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return appState.venues.where((v) => v.level == 1).map((v) {
      LatLng pos = const LatLng(0,0);
      if (v.code.contains('SH')) pos = const LatLng(0.0145, 0.0062); 
      if (v.code.contains('SP')) pos = const LatLng(0.0078, -0.0040); 
      if (pos.latitude == 0) return const Marker(point: LatLng(0,0), child: SizedBox());
      return Marker(point: pos, width: 12, height: 12, child: Container(decoration: BoxDecoration(color: v.isOccupied ? Colors.red : Colors.greenAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5), boxShadow: [BoxShadow(color: v.isOccupied ? Colors.red : Colors.greenAccent, blurRadius: 10)])));
    }).toList();
  }

  Widget _buildHeader(bool isDark) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('CAMPUS BLUEPRINT', style: TextStyle(color: AppTheme.cyan(isDark), fontSize: 12, fontWeight: FontWeight.bold)),
      Text('First Floor High-Fidelity', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    ]),
    IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: () => _mapController.move(const LatLng(0, 0), 15.5)),
  ]);

  Widget _buildSearchField(AppState appState) => TextField(
    controller: _searchController,
    style: const TextStyle(color: Colors.white),
    onChanged: (v) => appState.setSearchQuery(v),
    decoration: const InputDecoration(hintText: 'Search room...', prefixIcon: Icon(Icons.search, color: Colors.white)),
  );

  Widget _buildVenueList(List<Venue> venues, AppState appState) => ListView.builder(
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
