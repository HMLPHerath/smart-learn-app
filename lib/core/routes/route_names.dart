class RouteNames {
  static const splash = '/';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';

  static const studentShell = '/student';
  static const studentNotes = '/student/notes';
  static const studentBooks = '/student/books';

  static const parentShell = '/parent';

  static const teacherShell = '/teacher';
  static const teacherGradebook = '/teacher/gradebook';
  static const teacherAttendance = '/teacher/attendance';
  static const teacherStudentProfile = '/teacher/student-profile/:id';
  static const teacherChat = '/teacher/chat/:parentId';

  static const adminShell = '/admin';
  static const adminAdmitStudent = '/admin/admit-student';
  static const adminAddParent = '/admin/add-parent';
  static const adminAddTeacher = '/admin/add-teacher';
  static const adminPostNotice = '/admin/post-notice';
  static const adminSuccess = '/admin/success';
}
