// lib/models/forest_officer.dart
class ForestOfficer {
  final String id;
  final String staffId;
  final String password;
  final String? name;
  final String? rank;
  final String? zone;
  final String? fcmToken;
  final DateTime? createdAt;

  ForestOfficer({
    required this.id,
    required this.staffId,
    required this.password,
    this.name,
    this.rank,
    this.zone,
    this.fcmToken,
    this.createdAt,
  });

  factory ForestOfficer.fromMap(Map<String, dynamic> map) {
    return ForestOfficer(
      id: map['id'] ?? map['Staff_Id'] ?? '',
      staffId: map['Staff_Id'] ?? '',
      password: map['Password'] ?? '',
      name: map['Name'],
      rank: map['Rank'],
      zone: map['Zone'],
      fcmToken: map['fcmToken'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Staff_Id': staffId,
      'Password': password,
      'Name': name,
      'Rank': rank,
      'Zone': zone,
      'fcmToken': fcmToken,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  ForestOfficer copyWith({
    String? id,
    String? staffId,
    String? password,
    String? name,
    String? rank,
    String? zone,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return ForestOfficer(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      password: password ?? this.password,
      name: name ?? this.name,
      rank: rank ?? this.rank,
      zone: zone ?? this.zone,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
