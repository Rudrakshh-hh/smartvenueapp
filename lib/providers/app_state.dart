import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/venue.dart';
import '../models/timetable_item.dart';

class AppState extends ChangeNotifier {
  // Theme Mode (Dark Theme by default, White Futuristic Theme optional)
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Auth State
  bool _isLoggedIn = true;
  String _userName = 'Alex Mercer';
  String _studentId = 'SU-2026-8942';
  final String _userDepartment = 'Computer Science & AI';

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
  final String _currentBuilding = 'Tech Block A';
  final int _currentLevel = 2;
  String _activeBleAnchor = 'BLE-204-A (RSSI: -62 dBm)';
  int _pdrStepCounter = 1420;
  bool _isArucoCalibrated = true;
  DateTime _lastArucoScanTime = DateTime.now().subtract(const Duration(minutes: 8));

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
    'LH-201 Turing Hall',
    'AI Robotics Lab 304',
    'Quiet Pod B',
    'Innovation Center',
  ];

  String get searchQuery => _searchQuery;
  int? get selectedLevelFilter => _selectedLevelFilter;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  List<String> get recentSearches => _recentSearches;

  // Venues List
  final List<Venue> _venues = List.from(Venue.sampleVenues);
  List<Venue> get venues => _venues;

  List<Venue> get filteredVenues {
    return _venues.where((v) {
      final matchesQuery = _searchQuery.isEmpty ||
          v.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.building.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesLevel = _selectedLevelFilter == null || v.level == _selectedLevelFilter;
      final matchesCategory = _selectedCategoryFilter == null || v.category == _selectedCategoryFilter;
      return matchesQuery && matchesLevel && matchesCategory;
    }).toList();
  }

  List<Venue> get availableVacantVenues {
    return _venues.where((v) => !v.isOccupied).toList();
  }

  // Timetable State & AI Vision Parsing
  List<TimetableItem> _timetable = List.from(TimetableItem.sampleTimetable);
  List<TimetableItem> get timetable => _timetable;

  String? _selectedTimetableImageName = 'CS_Semester_4_Schedule_Scan.png';
  String? get selectedTimetableImageName => _selectedTimetableImageName;

  bool _isAnalyzingTimetable = false;
  bool get isAnalyzingTimetable => _isAnalyzingTimetable;

  String _aiAnalysisSummary =
      'AI OCR Vision Complete: Image parsed successfully! 4 classes detected. Optimal route mapped avoiding Level 2 construction hallway.';
  String get aiAnalysisSummary => _aiAnalysisSummary;

  TimetableItem? get nextClass {
    final next = _timetable.where((t) => t.isNextClass).toList();
    if (next.isNotEmpty) return next.first;
    return _timetable.isNotEmpty ? _timetable.first : null;
  }

  // Methods
  void login(String name, String id) {
    _userName = name.isEmpty ? 'Alex Mercer' : name;
    _studentId = id.isEmpty ? 'SU-2026-8942' : id;
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

  // AI Timetable Image Parsing Simulation
  Future<void> selectAndAnalyzeTimetableImage(String imageName) async {
    _selectedTimetableImageName = imageName;
    _isAnalyzingTimetable = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 2200));

    if (imageName.contains('Physics')) {
      _timetable = [
        const TimetableItem(
          id: 't_img1',
          courseCode: 'PHY-201',
          courseTitle: 'Applied Physics & Quantum Optics',
          venueCode: 'LH-201',
          building: 'Tech Block A',
          level: 2,
          dayOfWeek: 'Monday',
          startTime: '09:00 AM',
          endTime: '10:30 AM',
          instructor: 'Dr. Robert Oppen',
          aiRecommendation: 'Arrive via Door 1. BLE Anchor locked.',
          isNextClass: true,
        ),
        const TimetableItem(
          id: 't_img2',
          courseCode: 'MTH-301',
          courseTitle: 'Linear Algebra & Kinematics',
          venueCode: 'LAB-304',
          building: 'Tech Block A',
          level: 3,
          dayOfWeek: 'Monday',
          startTime: '11:00 AM',
          endTime: '12:30 PM',
          instructor: 'Prof. Katherine Johnson',
          aiRecommendation: 'Stairs recommended due to floor 3 elevator wait time.',
          isNextClass: false,
        ),
      ];
      _aiAnalysisSummary =
          'AI Vision Scan Success: Extracted Physics & Math Timetable Image. Mapped 2 classes with zero congestion delays.';
    } else {
      _aiAnalysisSummary =
          'AI Vision OCR Analysis Complete: Image parsed successfully! Matched 4 courses with campus IMDF GeoJSON database.';
    }

    _isAnalyzingTimetable = false;
    notifyListeners();
  }

  void addCustomClass(TimetableItem item) {
    _timetable.add(item);
    notifyListeners();
  }

  // Indoor Navigation Control
  void startNavigation(Venue venue) {
    _isNavigating = true;
    _navigationTargetVenue = venue;
    _navDistanceRemaining = venue.distanceMeters;
    _navEstMinutesRemaining = (venue.distanceMeters / 30).ceil();
    _navCurrentStepIndex = 1;

    _navSimulationTimer?.cancel();
    _navSimulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
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

  void stopNavigation() {
    _isNavigating = false;
    _navigationTargetVenue = null;
    _navSimulationTimer?.cancel();
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
