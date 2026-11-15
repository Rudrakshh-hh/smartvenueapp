import '../models/venue.dart';

/// First Floor venues of the Main Building, taken from the floor plan.
///
/// `imdfRoomId` is the SAME id the digital map uses (see
/// widgets/floor_plan/floor_plan_data.dart), so tapping a room on the map
/// finds its venue here, and the other way round.
///
/// NOTE: capacity is 0 = "not entered yet". The Available screen hides the
/// SEATS badge when capacity is 0. Fill in real seat counts when you have them.
/// isOccupied / currentActivity are static for now; later they will come from
/// the `schedules` table.
Venue _venue({
  required String roomId,
  required String code,
  required String name,
  required String category,
  int capacity = 0,
  List<String> tags = const [],
}) {
  return Venue(
    id: 'ff_$roomId',
    code: code,
    name: name,
    building: 'Main Building',
    level: 1,
    category: category,
    isOccupied: false,
    currentActivity: 'Vacant',
    capacity: capacity,
    occupiedSeats: 0,
    distanceMeters: 40, // placeholder: only drives the simulated navigation
    tags: tags,
    imdfRoomId: roomId,
  );
}

final List<Venue> kFirstFloorVenues = [
  // Lecture Theatres
  _venue(roomId: 'lt106', code: 'LT-106', name: 'Lecture Theatre 106', category: 'Lecture Theatre'),
  _venue(roomId: 'lt124', code: 'LT-124', name: 'Lecture Theatre 124', category: 'Lecture Theatre'),

  // Classrooms
  _venue(roomId: 'cr101', code: 'CR-101', name: 'Classroom 101', category: 'Classroom'),
  _venue(roomId: 'cr107', code: 'CR-107', name: 'Classroom 107', category: 'Classroom'),
  _venue(roomId: 'cr113', code: 'CR-113', name: 'Classroom 113', category: 'Classroom'),
  _venue(roomId: 'cr114', code: 'CR-114', name: 'Classroom 114', category: 'Classroom'),
  _venue(roomId: 'cr115', code: 'CR-115', name: 'Classroom 115', category: 'Classroom'),
  _venue(roomId: 'cr116', code: 'CR-116', name: 'Classroom 116', category: 'Classroom'),
  _venue(roomId: 'cr117', code: 'CR-117', name: 'Classroom 117', category: 'Classroom'),
  _venue(roomId: 'cr123', code: 'CR-123', name: 'Classroom 123', category: 'Classroom'),

  // Labs
  _venue(roomId: 'room109', code: 'CL-109', name: 'Computer Lab 2', category: 'Computer Lab'),
  _venue(roomId: 'room121', code: 'CL-121', name: 'Computer Lab 9', category: 'Computer Lab'),
  _venue(
    roomId: 'lab102',
    code: 'LAB-102',
    name: '102 Lab A/B',
    category: 'Computer Lab',
    tags: ['TCL 1', 'TCL 2'],
  ),
];
