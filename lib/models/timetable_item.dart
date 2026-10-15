class TimetableItem {
  final String id;
  final String courseCode; // e.g. "CS-302"
  final String courseTitle; // e.g. "Data Structures & Algorithms"
  final String venueCode; // e.g. "LH-201"
  final String building; // e.g. "Tech Block A"
  final int level; // e.g. 2
  final String dayOfWeek; // "Monday", "Tuesday", etc.
  final String startTime; // "09:00 AM"
  final String endTime; // "10:30 AM"
  final String instructor; // "Dr. Sarah Jenkins"
  final String aiRecommendation; // e.g. "Arrive via Level 2 West Stairwell. Avoid Level 1 main corridor."
  final bool isNextClass;

  const TimetableItem({
    required this.id,
    required this.courseCode,
    required this.courseTitle,
    required this.venueCode,
    required this.building,
    required this.level,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.instructor,
    required this.aiRecommendation,
    this.isNextClass = false,
  });

  static List<TimetableItem> sampleTimetable = const [
    TimetableItem(
      id: 't1',
      courseCode: 'CS-302',
      courseTitle: 'Data Structures & Algorithms',
      venueCode: 'LH-201',
      building: 'Tech Block A',
      level: 2,
      dayOfWeek: 'Monday',
      startTime: '10:00 AM',
      endTime: '11:30 AM',
      instructor: 'Dr. Alan Vance',
      aiRecommendation: 'Next class in 15 mins. Take Level 2 North Bridge (Estimated 2 min walk).',
      isNextClass: true,
    ),
    TimetableItem(
      id: 't2',
      courseCode: 'AI-401',
      courseTitle: 'Computer Vision & Kinematics',
      venueCode: 'LAB-304',
      building: 'Tech Block A',
      level: 3,
      dayOfWeek: 'Monday',
      startTime: '01:00 PM',
      endTime: '02:30 PM',
      instructor: 'Prof. Maya Lin',
      aiRecommendation: 'Floor 3 Elevator crowded around 12:50 PM. Stairs recommended.',
      isNextClass: false,
    ),
    TimetableItem(
      id: 't3',
      courseCode: 'SE-204',
      courseTitle: 'Human-Computer Interaction',
      venueCode: 'SH-105',
      building: 'Innovation Center',
      level: 1,
      dayOfWeek: 'Tuesday',
      startTime: '09:00 AM',
      endTime: '10:30 AM',
      instructor: 'Dr. Marcus Vance',
      aiRecommendation: 'Room opened 10 mins early for pre-lecture check-in.',
      isNextClass: false,
    ),
    TimetableItem(
      id: 't4',
      courseCode: 'NET-301',
      courseTitle: 'Wireless & Sensor Networks',
      venueCode: 'LAB-202',
      building: 'Tech Block B',
      level: 2,
      dayOfWeek: 'Wednesday',
      startTime: '11:30 AM',
      endTime: '01:00 PM',
      instructor: 'Dr. Elena Rostova',
      aiRecommendation: 'BLE anchor density high in Tech Block B for pinpoint indoor accuracy.',
      isNextClass: false,
    ),
  ];
}
