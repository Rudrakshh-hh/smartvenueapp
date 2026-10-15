class Venue {
  final String id;
  final String code; // e.g. "LH-201"
  final String name; // e.g. "Main Lecture Hall"
  final String building; // e.g. "Innovation Hub"
  final int level; // e.g. 2
  final String category; // "Lecture Hall", "Computer Lab", "Study Pod", "Seminar Hall"
  final bool isOccupied;
  final String currentActivity; // e.g. "CS302 Lecture" or "Vacant - Open for Study"
  final int capacity;
  final int occupiedSeats;
  final double distanceMeters;
  final List<String> tags; // e.g. ["AC", "Projector", "Power Sockets", "ArUco Anchor #12"]
  final String imdfRoomId;

  const Venue({
    required this.id,
    required this.code,
    required this.name,
    required this.building,
    required this.level,
    required this.category,
    required this.isOccupied,
    required this.currentActivity,
    required this.capacity,
    required this.occupiedSeats,
    required this.distanceMeters,
    required this.tags,
    required this.imdfRoomId,
  });

  int get availableSeats => capacity - occupiedSeats;

  static List<Venue> sampleVenues = const [
    Venue(
      id: 'v1',
      code: 'LH-201',
      name: 'Alan Turing Auditorium',
      building: 'Tech Block A',
      level: 2,
      category: 'Lecture Hall',
      isOccupied: false,
      currentActivity: 'Vacant - Free until 02:00 PM',
      capacity: 120,
      occupiedSeats: 0,
      distanceMeters: 45.0,
      tags: ['Projector', 'Power Sockets', 'AC', 'BLE Anchor #201'],
      imdfRoomId: 'imdf_room_lh201',
    ),
    Venue(
      id: 'v2',
      code: 'LAB-304',
      name: 'AI & Robotics Lab',
      building: 'Tech Block A',
      level: 3,
      category: 'Computer Lab',
      isOccupied: true,
      currentActivity: 'CS401 Computer Vision Class',
      capacity: 40,
      occupiedSeats: 38,
      distanceMeters: 120.0,
      tags: ['GPU Workstations', 'ArUco Marker #04', 'High Speed Wi-Fi'],
      imdfRoomId: 'imdf_room_lab304',
    ),
    Venue(
      id: 'v3',
      code: 'SP-102',
      name: 'Quiet Focus Pod B',
      building: 'Library Complex',
      level: 1,
      category: 'Study Pod',
      isOccupied: false,
      currentActivity: 'Vacant - Open for individual study',
      capacity: 6,
      occupiedSeats: 1,
      distanceMeters: 85.0,
      tags: ['Quiet Zone', 'Smart Screen', 'Wireless Charging'],
      imdfRoomId: 'imdf_room_sp102',
    ),
    Venue(
      id: 'v4',
      code: 'SH-105',
      name: 'Ada Lovelace Seminar Hall',
      building: 'Innovation Center',
      level: 1,
      category: 'Seminar Hall',
      isOccupied: false,
      currentActivity: 'Vacant - Open for booking',
      capacity: 80,
      occupiedSeats: 0,
      distanceMeters: 160.0,
      tags: ['Audio System', 'Live Stream Rig', 'BLE Anchor #105'],
      imdfRoomId: 'imdf_room_sh105',
    ),
    Venue(
      id: 'v5',
      code: 'LAB-202',
      name: 'Cybersecurity Lab',
      building: 'Tech Block B',
      level: 2,
      category: 'Computer Lab',
      isOccupied: false,
      currentActivity: 'Vacant - Open Lab Hours',
      capacity: 35,
      occupiedSeats: 4,
      distanceMeters: 210.0,
      tags: ['Dual Monitors', 'Ethernet Jacks', 'AC'],
      imdfRoomId: 'imdf_room_lab202',
    ),
  ];
}
