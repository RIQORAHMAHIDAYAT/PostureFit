class UserEntity {
  final String id;
  final String name;
  final String email;
  final double height;
  final double weight;
  final double bmi;
  final String goal;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.goal,
  });
}
