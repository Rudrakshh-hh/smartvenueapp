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
    String extractedStartTime = json['startTime']?.toString() ??
        json['start_time']?.toString() ??
        json['start']?.toString() ??
        '';
    String extractedEndTime = json['endTime']?.toString() ??
        json['end_time']?.toString() ??
        json['end']?.toString() ??
        '';

    final String combinedTime = json['time']?.toString() ??
        json['timeSlot']?.toString() ??
        json['time_slot']?.toString() ??
        json['slot']?.toString() ??
        '';

    if ((extractedStartTime.isEmpty || extractedEndTime.isEmpty) &&
        combinedTime.isNotEmpty) {
      if (combinedTime.contains('-')) {
        final parts = combinedTime.split('-');
        if (parts.length >= 2) {
          extractedStartTime = parts[0].trim();
          extractedEndTime = parts[1].trim();
        }
      } else if (combinedTime.contains('to')) {
        final parts = combinedTime.split('to');
        if (parts.length >= 2) {
          extractedStartTime = parts[0].trim();
          extractedEndTime = parts[1].trim();
        }
      }
    }

    if (extractedStartTime.isEmpty) extractedStartTime = '09:00 AM';
    if (extractedEndTime.isEmpty) extractedEndTime = '09:55 AM';

    return TimetableItem(
      id:
          id ??
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      courseCode:
          json['courseCode']?.toString() ??
          json['course_code']?.toString() ??
          json['code']?.toString() ??
          json['subjectCode']?.toString() ??
          'CS-101',
      courseTitle:
          json['courseTitle']?.toString() ??
          json['course_title']?.toString() ??
          json['subject']?.toString() ??
          json['subjectName']?.toString() ??
          json['title']?.toString() ??
          'General Lecture',
      venueCode:
          json['venueCode']?.toString() ??
          json['venue_code']?.toString() ??
          json['venue']?.toString() ??
          json['room']?.toString() ??
          'LH-201',
      building:
          json['building']?.toString() ??
          json['block']?.toString() ??
          'Main Block',
      level: json['level'] is int
          ? json['level']
          : int.tryParse(json['level']?.toString() ?? '1') ?? 1,
      dayOfWeek:
          json['dayOfWeek']?.toString() ??
          json['day_of_week']?.toString() ??
          json['day']?.toString() ??
          'Monday',
      startTime: extractedStartTime,
      endTime: extractedEndTime,
      instructor:
          json['instructor']?.toString() ??
          json['faculty']?.toString() ??
          json['teacher']?.toString() ??
          json['professor']?.toString() ??
          'Faculty Member',
      aiRecommendation:
          json['aiRecommendation']?.toString() ??
          json['recommendation']?.toString() ??
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
