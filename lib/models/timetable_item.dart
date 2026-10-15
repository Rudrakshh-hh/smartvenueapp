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

  factory TimetableItem.fromJson(Map<String, dynamic> json, {String? id}) {
    return TimetableItem(
      id:
          id ??
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      courseCode:
          json['courseCode']?.toString() ??
          json['code']?.toString() ??
          'CS-101',
      courseTitle:
          json['courseTitle']?.toString() ??
          json['subject']?.toString() ??
          json['title']?.toString() ??
          'General Lecture',
      venueCode:
          json['venueCode']?.toString() ??
          json['venue']?.toString() ??
          'LH-201',
      building: json['building']?.toString() ?? 'Tech Block A',
      level: json['level'] is int
          ? json['level']
          : int.tryParse(json['level']?.toString() ?? '2') ?? 2,
      dayOfWeek:
          json['dayOfWeek']?.toString() ?? json['day']?.toString() ?? 'Monday',
      startTime:
          json['startTime']?.toString() ??
          json['time']?.toString() ??
          '10:00 AM',
      endTime: json['endTime']?.toString() ?? '11:30 AM',
      instructor: json['instructor']?.toString() ?? 'Faculty Member',
      aiRecommendation:
          json['aiRecommendation']?.toString() ??
          'Extracted via AI API Vision OCR.',
      isNextClass: json['isNextClass'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'courseCode': courseCode,
    'courseTitle': courseTitle,
    'venueCode': venueCode,
    'building': building,
    'level': level,
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
    'instructor': instructor,
    'aiRecommendation': aiRecommendation,
    'isNextClass': isNextClass,
  };

  static List<TimetableItem> sampleTimetable = const [];
}
