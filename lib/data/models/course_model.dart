class CourseModel {
  final String courseId;
  final String title;
  final String teacherName;
  final String startTime;
  final String endTime;
  final String dayOfWeek;
  final String status;
  final String roomIdentifier;

  CourseModel({
    required this.courseId,
    required this.title,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    required this.status,
    this.roomIdentifier = '',
  });

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      courseId: map['CourseID'] ?? map['courseId'] ?? '',
      title: map['CourseName'] ?? map['title'] ?? '',
      teacherName: map['InstructorName'] ?? map['TeacherName'] ?? map['teacherName'] ?? '',
      startTime: map['StartTimeStr'] ?? map['startTime'] ?? '',
      endTime: map['EndTimeStr'] ?? map['endTime'] ?? '',
      dayOfWeek: map['DayOfWeek'] ?? map['dayOfWeek'] ?? '',
      status: map['status'] ?? '',
      roomIdentifier: map['RoomIdentifier'] ?? map['roomIdentifier'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'teacherName': teacherName,
      'startTime': startTime,
      'endTime': endTime,
      'dayOfWeek': dayOfWeek,
      'status': status,
      'roomIdentifier': roomIdentifier,
    };
  }
}
