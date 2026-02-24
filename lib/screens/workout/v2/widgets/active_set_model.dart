// Local model to hold one set's state during an active workout
// This is NOT saved to backend yet, only saved when user finishes
class ActiveSet {
  int setNumber;
  double? weightKg;
  int? reps;
  int? rpe; // rate of perceived exertion 1 to 10, optional
  bool isWarmup; // warmup sets show W instead of set number
  bool isPR; // personal record, shows trophy badge
  bool isCompleted;

  ActiveSet({
    required this.setNumber,
    this.weightKg,
    this.reps,
    this.rpe,
    this.isWarmup = false,
    this.isPR = false,
    this.isCompleted = false,
  });

  // Copy with updated values
  ActiveSet copyWith({
    int? setNumber,
    double? weightKg,
    int? reps,
    int? rpe,
    bool? isWarmup,
    bool? isPR,
    bool? isCompleted,
  }) {
    return ActiveSet(
      setNumber: setNumber ?? this.setNumber,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      isWarmup: isWarmup ?? this.isWarmup,
      isPR: isPR ?? this.isPR,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
