import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.height,
    required super.weight,
    required super.bmi,
    required super.goal,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      goal: json['goal'] as String,
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
      );
}
