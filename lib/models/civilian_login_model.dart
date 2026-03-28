// lib/models/civilian.dart
class Civilian {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phoneNumber;
  final String? fcmToken;
  final DateTime? createdAt;

  Civilian({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phoneNumber,
    this.fcmToken,
    this.createdAt,
  });

  factory Civilian.fromMap(Map<String, dynamic> map) {
    return Civilian(
      id: map['uid'] ?? map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['displayName'] ?? map['name'] ?? 'Anonymous',
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      fcmToken: map['fcmToken'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'email': email,
      'displayName': name,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'fcmToken': fcmToken,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  Civilian copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return Civilian(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
