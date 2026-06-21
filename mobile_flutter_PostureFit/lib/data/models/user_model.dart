import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.height,
    super.weight,
    super.bmi,
    super.goal,
    super.age,
    super.gender,
    super.profilePicture,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      goal: json['goal'] as String?,
      age: json['age'] != null ? (json['age'] as num).toInt() : null,
      gender: json['gender'] as String?,
      profilePicture: json['profile_picture'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'goal': goal,
      'age': age,
      'gender': gender,
      'profile_picture': profilePicture,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static UserModel get mock => const UserModel(
        id: '1',
        name: 'Riqo Rahma H',
        email: 'riqo@email.com',
        height: 172,
        weight: 78,
        bmi: 28.4,
        goal: 'Cutting - Fat Loss',
        age: 22,
        gender: 'Laki-laki',
      );
}
