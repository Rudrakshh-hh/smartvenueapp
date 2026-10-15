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

  static List<Venue> sampleVenues = const [];
}
