class UserModel {
  String uid;
  String email;
  String displayName;
  DateTime createdAt;
  String profileImageUrl;
  int faceCount;
  int processedImagesCount;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.profileImageUrl = '',
    this.faceCount = 0,
    this.processedImagesCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'profileImageUrl': profileImageUrl,
      'faceCount': faceCount,
      'processedImagesCount': processedImagesCount,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      profileImageUrl: map['profileImageUrl'] ?? '',
      faceCount: map['faceCount'] ?? 0,
      processedImagesCount: map['processedImagesCount'] ?? 0,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
    String? profileImageUrl,
    int? faceCount,
    int? processedImagesCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      faceCount: faceCount ?? this.faceCount,
      processedImagesCount: processedImagesCount ?? this.processedImagesCount,
    );
  }
} 