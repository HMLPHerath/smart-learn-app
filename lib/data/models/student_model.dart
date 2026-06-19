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
      className: map['ClassName'] ?? map['ClassID']?.toString() ?? map['className'] ?? '',
      classId: map['ClassID']?.toString(),
      section: map['section'] ?? '',
      attendanceRate: int.tryParse(map['attendanceRate']?.toString() ?? '0') ?? 0,
      gpa: double.tryParse(map['gpa']?.toString() ?? '0') ?? 0.0,
      rank: int.tryParse(map['rank']?.toString() ?? '0') ?? 0,
      parentId: map['ParentID'] ?? map['parentId'] ?? '',
      profilePictureUri: map['ProfilePictureURI'] ?? map['imageUrl'],
      
      // Handle the new fields
      email: map['Email'] ?? map['email'] ?? 'No Email',
      phoneNumber: map['PhoneNumber'] ?? map['phoneNumber'] ?? 'No Phone',
      accountStatus: map['AccountStatus'] ?? map['accountStatus'] ?? 'Pending',
      dateOfBirth: map['DateOfBirth']?.toString() ?? map['dateOfBirth']?.toString() ?? 'Unknown',
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