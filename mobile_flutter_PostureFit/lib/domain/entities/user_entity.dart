class UserEntity {
  final String id;
  final String name;
  final String email;
  final double? height;
  final double? weight;
  final double? bmi;
  final String? goal;
  final int? age;
  final String? gender;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.height,
    this.weight,
    this.bmi,
    this.goal,
    this.age,
    this.gender,
  });
}
