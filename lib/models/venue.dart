class Venue {
  final String id;
  final String code; // e.g. "LH-201"
  final String name; // e.g. "Main Lecture Hall"
  final String building; // e.g. "Innovation Hub"
  final int level; // e.g. 2
  final String
  category; // "Lecture Hall", "Computer Lab", "Study Pod", "Seminar Hall"
  final bool isOccupied;
  final String
  currentActivity; // e.g. "CS302 Lecture" or "Vacant - Open for Study"
  final int capacity;
  final int occupiedSeats;
  final double distanceMeters;
  final List<String>
  tags; // e.g. ["AC", "Projector", "Power Sockets", "ArUco Anchor #12"]
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
      id: "v_001",
      code: "LH-201",
      name: "Main Lecture Hall",
      building: "Innovation Hub",
      level: 2,
      category: "Lecture Hall",
      isOccupied: false,
      currentActivity: "Vacant - Open for Study",
      capacity: 150,
      occupiedSeats: 0,
      distanceMeters: 45.5,
      tags: ["AC", "Projector", "Smart Board", "Mic"],
      imdfRoomId: "room_lh_201",
    ),
    Venue(
      id: "v_002",
      code: "CL-105",
      name: "Advanced Computer Lab",
      building: "Tech Annex",
      level: 1,
      category: "Computer Lab",
      isOccupied: false,
      currentActivity: "Vacant",
      capacity: 40,
      occupiedSeats: 0,
      distanceMeters: 120.0,
      tags: ["AC", "High-End PCs", "Linux", "Dual Monitors"],
      imdfRoomId: "room_cl_105",
    ),
    Venue(
      id: "v_003",
      code: "SP-301",
      name: "Quiet Study Pod A",
      building: "Central Library",
      level: 3,
      category: "Study Pod",
      isOccupied: false,
      currentActivity: "Vacant",
      capacity: 1, // Classic Binary Semaphore case
      occupiedSeats: 0,
      distanceMeters: 15.0,
      tags: ["AC", "Power Sockets", "Soundproof", "Whiteboard"],
      imdfRoomId: "room_sp_301",
    ),
    Venue(
      id: "v_004",
      code: "SH-400",
      name: "Executive Seminar Hall",
      building: "Business Block",
      level: 4,
      category: "Seminar Hall",
      isOccupied: true,
      currentActivity: "Faculty Meeting",
      capacity: 30,
      occupiedSeats: 30, // Currently full
      distanceMeters: 300.0,
      tags: ["AC", "Video Conferencing", "Catering Setup"],
      imdfRoomId: "room_sh_400",
    ),
  ];
}
