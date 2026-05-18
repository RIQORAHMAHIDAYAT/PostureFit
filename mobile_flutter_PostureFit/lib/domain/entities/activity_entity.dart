class ActivityEntity {
  final int olahraga;
  final int nutrisi;
  final int tidur;
  final double sleepDuration;
  final double hydrationCurrent;
  final double hydrationTarget;
  final int activityScore;

  const ActivityEntity({
    required this.olahraga,
    required this.nutrisi,
    required this.tidur,
    required this.sleepDuration,
    required this.hydrationCurrent,
    required this.hydrationTarget,
    required this.activityScore,
  });
}
