class AppUserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? accountStatus;
  final String? profilePicture;

  AppUserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.accountStatus,
    this.profilePicture,
  });

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      uid: map['uid'] ?? map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      accountStatus: map['accountStatus'],
      profilePicture: map['profilePicture'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'accountStatus': accountStatus,
      'profilePicture': profilePicture,
    };
  }
}
