class DropdownClassModel {
  final String classId;
  final String className;

  DropdownClassModel({required this.classId, required this.className});

  factory DropdownClassModel.fromMap(Map<String, dynamic> map) {
    return DropdownClassModel(
      classId: map['ClassID'] ?? '',
      className: map['ClassName'] ?? '',
    );
  }
}

class DropdownTeacherModel {
  final String teacherId;
  final String fullName;

  DropdownTeacherModel({required this.teacherId, required this.fullName});

  factory DropdownTeacherModel.fromMap(Map<String, dynamic> map) {
    return DropdownTeacherModel(
      teacherId: map['TeacherID'] ?? '',
      fullName: map['FullName'] ?? '',
    );
  }
}

class DropdownCourseModel {
  final String courseId;
  final String courseName;

  DropdownCourseModel({required this.courseId, required this.courseName});

  factory DropdownCourseModel.fromMap(Map<String, dynamic> map) {
    return DropdownCourseModel(
      courseId: map['CourseID'] ?? '',
      courseName: map['CourseName'] ?? '',
    );
  }
}
