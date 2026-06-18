class StudentModel {
  final String uid;
  final String studentId;
  final String fullName;
  final String className; // or classId
  final String? classId;
  final String section;
  final int attendanceRate;
  final double gpa;
  final int rank;
  final String parentId;
  final String? profilePictureUri; // using this name to match the profile screen
  
  // New fields
  final String email;
  final String phoneNumber;
  final String accountStatus;
  final String dateOfBirth;
  final String homeAddress;

  StudentModel({
    required this.uid,
    required this.studentId,
    required this.fullName,
    required this.className,
    this.classId,
    required this.section,
    required this.attendanceRate,
    required this.gpa,
    required this.rank,
    required this.parentId,
    this.profilePictureUri,
    required this.email,
    required this.phoneNumber,
    required this.accountStatus,
    required this.dateOfBirth,
    required this.homeAddress,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      uid: map['StudentID'] ?? map['uid'] ?? '',
      studentId: map['StudentID'] ?? map['studentId'] ?? '',
      fullName: map['FullName'] ?? map['fullName'] ?? '',
      className: map['ClassID']?.toString() ?? map['className'] ?? '',
      classId: map['ClassID']?.toString(),
      section: map['section'] ?? '',
      attendanceRate: map['attendanceRate'] ?? 0,
      gpa: (map['gpa'] ?? 0).toDouble(),
      rank: map['rank'] ?? 0,
      parentId: map['parentId'] ?? '',
      profilePictureUri: map['ProfilePictureURI'] ?? map['imageUrl'],
      
      // Handle the new fields
      email: map['Email'] ?? map['email'] ?? 'No Email',
      phoneNumber: map['PhoneNumber'] ?? map['phoneNumber'] ?? 'No Phone',
      accountStatus: map['AccountStatus'] ?? map['accountStatus'] ?? 'Pending',
      dateOfBirth: map['DateOfBirth'] ?? map['dateOfBirth'] ?? 'Unknown',
      homeAddress: map['HomeAddress'] ?? map['homeAddress'] ?? 'No Address',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'studentId': studentId,
      'fullName': fullName,
      'className': className,
      'classId': classId,
      'section': section,
      'attendanceRate': attendanceRate,
      'gpa': gpa,
      'rank': rank,
      'parentId': parentId,
      'profilePictureUri': profilePictureUri,
      'email': email,
      'phoneNumber': phoneNumber,
      'accountStatus': accountStatus,
      'dateOfBirth': dateOfBirth,
      'homeAddress': homeAddress,
    };
  }
}
