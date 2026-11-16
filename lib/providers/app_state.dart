import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/first_floor_venues.dart';
import '../models/venue.dart';
import '../models/timetable_item.dart';
import '../services/ai_timetable_service.dart';

class AppState extends ChangeNotifier {
  // Theme Mode (Dark Theme by default, White Futuristic Theme optional)
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Auth State
  bool _isLoggedIn = false;
  String _userName = '';
  String _studentId = '';
  final String _userDepartment = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get studentId => _studentId;
  String get userDepartment => _userDepartment;

  // Navigation Shell Tab Index
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Live Positioning & IPS System State
  final String _currentBuilding = '';
  final int _currentLevel = 1;
  String _activeBleAnchor = 'BLE Scanning Idle';
  int _pdrStepCounter = 0;
  bool _isArucoCalibrated = false;
  DateTime _lastArucoScanTime = DateTime.now();

  // BLE Beacon Ranging & Broadcaster State
  static const String bleBeaconUUID = 'B9407F30-F5F8-466E-AFF9-25556B57FE6D';
  final FlutterBlePeripheral _blePeripheral = FlutterBlePeripheral();
  StreamSubscription? _bleScanSubscription;
  bool _isBleAnchorBroadcasting = false;
  bool _isBleBeaconDetected = false;
  int _lastBleRssi = -100;

  bool get isBleAnchorBroadcasting => _isBleAnchorBroadcasting;
  bool get isBleBeaconDetected => _isBleBeaconDetected;
  int get lastBleRssi => _lastBleRssi;

  String get currentBuilding => _currentBuilding;
  int get currentLevel => _currentLevel;
  String get activeBleAnchor => _activeBleAnchor;
  int get pdrStepCounter => _pdrStepCounter;
  bool get isArucoCalibrated => _isArucoCalibrated;
  DateTime get lastArucoScanTime => _lastArucoScanTime;

  // Active Route Navigation Simulation
  bool _isNavigating = false;
  Venue? _navigationTargetVenue;
  double _navDistanceRemaining = 45.0; // in meters
  int _navEstMinutesRemaining = 2;
  int _navCurrentStepIndex = 1;
  Timer? _navSimulationTimer;

  bool get isNavigating => _isNavigating;
  Venue? get navigationTargetVenue => _navigationTargetVenue;
  double get navDistanceRemaining => _navDistanceRemaining;
  int get navEstMinutesRemaining => _navEstMinutesRemaining;
  int get navCurrentStepIndex => _navCurrentStepIndex;

  // Search & Filters State
  String _searchQuery = '';
  int? _selectedLevelFilter;
  String? _selectedCategoryFilter;
  List<String> _recentSearches = [
    'Classroom 113',
    'Lecture Theatre 106',
    'Computer Lab 2',
  ];

  String get searchQuery => _searchQuery;
  int? get selectedLevelFilter => _selectedLevelFilter;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  List<String> get recentSearches => _recentSearches;

  // Venues List
  final List<Venue> _venues = List.from(kFirstFloorVenues);
  List<Venue> get venues => _venues;

  List<Venue> get filteredVenues {
    return _venues.where((v) {
      final matchesQuery =
          _searchQuery.isEmpty ||
          v.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.building.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesLevel =
          _selectedLevelFilter == null || v.level == _selectedLevelFilter;
      final matchesCategory =
          _selectedCategoryFilter == null ||
          v.category == _selectedCategoryFilter;
      return matchesQuery && matchesLevel && matchesCategory;
    }).toList();
  }

  List<Venue> get availableVacantVenues {
    return _venues.where((v) => !v.isOccupied).toList();
  }

  // Timetable State & AI Vision Parsing
  List<TimetableItem> _timetable = [];
  List<TimetableItem> get timetable => _timetable;

  String? _selectedTimetableImageName;
  String? get selectedTimetableImageName => _selectedTimetableImageName;

  Uint8List? _selectedTimetableImageBytes;
  Uint8List? get selectedTimetableImageBytes => _selectedTimetableImageBytes;

  String? _selectedTimetableImagePath;
  String? get selectedTimetableImagePath => _selectedTimetableImagePath;

  bool _isAnalyzingTimetable = false;
  bool get isAnalyzingTimetable => _isAnalyzingTimetable;

  String _aiAnalysisSummary =
      'No timetable image parsed yet. Upload an image to extract schedule.';
  String get aiAnalysisSummary => _aiAnalysisSummary;

  TimetableItem? _activeScheduledClass;

  TimetableItem? get nextClass {
    if (_activeScheduledClass != null) return _activeScheduledClass;
    final next = _timetable.where((t) => t.isNextClass).toList();
    if (next.isNotEmpty) return next.first;
    return _timetable.isNotEmpty ? _timetable.first : null;
  }

  // Methods
  void login(String name, String id) {
    _userName = name;
    _studentId = id;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setLevelFilter(int? level) {
    _selectedLevelFilter = level;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void addRecentSearch(String term) {
    if (term.trim().isEmpty) return;
    _recentSearches.remove(term);
    _recentSearches.insert(0, term);
    if (_recentSearches.length > 6) {
      _recentSearches = _recentSearches.sublist(0, 6);
    }
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  // AI Timetable Image Parsing via Open-Source AI API (OpenRouter)
  Future<void> selectAndAnalyzeTimetableImage(
    String imageName, {
    Uint8List? imageBytes,
    String? imagePath,
  }) async {
    _selectedTimetableImageName = imageName;
    if (imageBytes != null) _selectedTimetableImageBytes = imageBytes;
    if (imagePath != null) _selectedTimetableImagePath = imagePath;

    _isAnalyzingTimetable = true;
    notifyListeners();

    final result = await AiTimetableService.analyzeTimetableImage(
      imageName: imageName,
      imageBytes: _selectedTimetableImageBytes,
      imagePath: _selectedTimetableImagePath,
    );

    _timetable = result.extractedSchedule;
    _aiAnalysisSummary = result.summary;
    _activeScheduledClass = result.recommendedClass;

    _isAnalyzingTimetable = false;
    notifyListeners();
  }

  void addCustomClass(TimetableItem item) {
    _timetable.add(item);
    notifyListeners();
  }

  // Indoor Navigation Control & Real BLE Beacon Ranging
  void startNavigation(Venue venue) {
    _isNavigating = true;
    _navigationTargetVenue = venue;
    _navDistanceRemaining = venue.distanceMeters > 0 ? venue.distanceMeters : 45.0;
    _navEstMinutesRemaining = (_navDistanceRemaining / 30).ceil();
    _navCurrentStepIndex = 1;
    _isBleBeaconDetected = false;
    _activeBleAnchor = 'Scanning for BLE Beacon...';

    // Start BLE Ranging to scan for Anchor phone
    _startBleNavigationScanner(venue);

    // Fallback simulation timer (only moves if no real BLE beacon anchor is detected)
    _navSimulationTimer?.cancel();
    _navSimulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isBleBeaconDetected) {
        // Real BLE Beacon is actively driving movement! Skip fake simulation.
        return;
      }

      if (_navDistanceRemaining > 5) {
        _navDistanceRemaining -= 5;
        _pdrStepCounter += 8;
        _navEstMinutesRemaining = (_navDistanceRemaining / 30).ceil();
        if (_navDistanceRemaining <= 20 && _navCurrentStepIndex == 1) {
          _navCurrentStepIndex = 2;
        }
        notifyListeners();
      } else {
        _navDistanceRemaining = 0;
        _navCurrentStepIndex = 3;
        timer.cancel();
        notifyListeners();
      }
    });

    notifyListeners();
  }

  Future<void> _startBleNavigationScanner(Venue venue) async {
    try {
      await [
        Permission.location,
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.off) {
        await FlutterBluePlus.turnOn();
      }

      await FlutterBluePlus.startScan(
        withServices: [Guid(bleBeaconUUID)],
      );

      _bleScanSubscription?.cancel();
      _bleScanSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (!_isNavigating) return;

        if (results.isNotEmpty) {
          results.sort((a, b) => b.rssi.compareTo(a.rssi));
          final closest = results.first;
          final rssi = closest.rssi;
          _lastBleRssi = rssi;
          _isBleBeaconDetected = true;

          // Convert RSSI to distance in meters using Log-Distance Path Loss Model
          // Formula: d = 10 ^ ((MeasuredPower - RSSI) / (10 * N))
          // MeasuredPower = -59 dBm at 1m, N = 2.0
          double rawDist = math.pow(10, (-59 - rssi) / 20.0).toDouble();
          _navDistanceRemaining = rawDist.clamp(0.0, venue.distanceMeters > 0 ? venue.distanceMeters : 100.0);
          _navEstMinutesRemaining = (_navDistanceRemaining / 30).ceil();
          _pdrStepCounter += 2;

          _activeBleAnchor = 'BLE Beacon Locked: ${rssi} dBm (~${_navDistanceRemaining.toStringAsFixed(1)}m)';

          if (_navDistanceRemaining <= 2.0) {
            _navDistanceRemaining = 0.0;
            _navCurrentStepIndex = 3;
            _activeBleAnchor = 'BLE Beacon Arrived! (${rssi} dBm)';
          } else if (_navDistanceRemaining <= 15.0) {
            _navCurrentStepIndex = 2;
          }

          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint("BLE Navigation Scanner Error: $e");
    }
  }

  Future<void> toggleBleAnchorBroadcasting(Venue? venue) async {
    if (_isBleAnchorBroadcasting) {
      await stopBleAnchorBroadcasting();
    } else if (venue != null) {
      await startBleAnchorBroadcasting(venue);
    }
  }

  Future<void> startBleAnchorBroadcasting(Venue venue) async {
    try {
      await [
        Permission.bluetooth,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
      ].request();

      if (await _blePeripheral.isSupported == false) return;

      final advertiseData = AdvertiseDataCore(
        serviceUuid: bleBeaconUUID,
        localName: venue.code,
      );

      await _blePeripheral.start(advertiseData: advertiseData);
      _isBleAnchorBroadcasting = true;
      _activeBleAnchor = 'Broadcasting as BLE Anchor for ${venue.code}';
      notifyListeners();
    } catch (e) {
      debugPrint("BLE Anchor Broadcast Error: $e");
    }
  }

  Future<void> stopBleAnchorBroadcasting() async {
    try {
      await _blePeripheral.stop();
      _isBleAnchorBroadcasting = false;
      _activeBleAnchor = 'BLE Anchor Stopped';
      notifyListeners();
    } catch (e) {
      debugPrint("BLE Anchor Stop Error: $e");
    }
  }

  void stopNavigation() {
    _isNavigating = false;
    _navigationTargetVenue = null;
    _isBleBeaconDetected = false;
    _navSimulationTimer?.cancel();
    _bleScanSubscription?.cancel();
    _bleScanSubscription = null;
    FlutterBluePlus.stopScan();
    notifyListeners();
  }

  void triggerArUcoRecalibration() {
    _isArucoCalibrated = true;
    _lastArucoScanTime = DateTime.now();
    _pdrStepCounter = 1450;
    _activeBleAnchor = 'ArUco Marker #04 Locked (3D Pose Rectified)';
    notifyListeners();
  }

  @override
  void dispose() {
    _navSimulationTimer?.cancel();
    super.dispose();
  }
}
