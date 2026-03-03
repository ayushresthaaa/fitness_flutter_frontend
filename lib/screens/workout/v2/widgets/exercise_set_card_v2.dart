import 'package:flutter/material.dart';
import '../../../../models/exercise/exercise_model.dart';
import '../../../../widgets/common.dart';
import 'active_set_model.dart';
import 'set_row_v2.dart';

class ExerciseSetCardV2 extends StatelessWidget {
  final Exercise
  exercise; // changed from WorkoutExercise because we want to show name + last perf even if exercise is removed from workout
  final List<ActiveSet> sets;
  final List<Map<String, dynamic>> lastPerformance;
  final VoidCallback onAddSet;
  final VoidCallback onAddWarmupSet;
  final VoidCallback onRemoveExercise;
  final Function(int index) onSetCompleted;
  final Function(int index) onSetRemoved;
  final Function(int index, ActiveSet updated) onSetChanged;
  final bool showBackground;
  bool get isCardio => exercise.category == 'cardio';
  final VoidCallback? onLongPress; // for pairing into superset
  const ExerciseSetCardV2({
    super.key,
    required this.exercise,
    required this.sets,
    required this.lastPerformance,
    required this.onAddSet,
    required this.onAddWarmupSet,
    required this.onRemoveExercise,
    required this.onSetCompleted,
    required this.onSetRemoved,
    required this.onSetChanged,
    this.onLongPress,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: showBackground
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (lastPerformance.isNotEmpty) _buildLastPerf(),
          _buildColumnLabels(),
          for (int i = 0; i < sets.length; i++)
            SetRowV2(
              set: sets[i],
              isCardio: isCardio, // ← add this
              onChanged: (updated) => onSetChanged(i, updated),
              onCompleted: () => onSetCompleted(i),
              onRemoved: () => onSetRemoved(i),
            ),
          _buildAddSet(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212121),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: onRemoveExercise,
              child: const Icon(
                Icons.close,
                size: 20,
                color: Color(0xFFBDBDBD),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastPerf() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              'Last  ',
              style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
            ),
            for (int i = 0; i < lastPerformance.length; i++)
              _LastPerfPill(
                label: 'S${i + 1}',
                isCardio: isCardio, // ← add
                weightKg: (lastPerformance[i]['weightKg'] as num?)?.toDouble(),
                reps: lastPerformance[i]['reps'] as int?,
                durationSec: (lastPerformance[i]['durationSec'] as num?)
                    ?.toDouble(), // ← add
                distanceMeters: (lastPerformance[i]['distanceMeters'] as num?)
                    ?.toDouble(), // ← add
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnLabels() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
      child: Row(
        children: [
          const SizedBox(width: 30, child: _ColLabel('SET')),
          const SizedBox(width: 8),
          Expanded(child: _ColLabel(isCardio ? 'MINS' : 'KG (0=BW)')),
          const SizedBox(width: 8),
          Expanded(child: _ColLabel(isCardio ? 'DIST' : 'REPS')),
          const SizedBox(width: 8),
          const Expanded(child: _ColLabel('RPE')),
          const SizedBox(width: 8),
          const SizedBox(width: 38, child: _ColLabel('DONE')),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildAddSet(BuildContext context) {
    final bool atLimit = sets.length >= 10;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      child: Row(
        children: [
          // Add working set
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (atLimit) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Maximum 10 sets per exercise'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                onAddSet();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 15, color: kPrimary),
                    SizedBox(width: 4),
                    Text(
                      'Add Set',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Add warmup set
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (atLimit) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Maximum 10 sets per exercise'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                onAddWarmupSet();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 15, color: Color(0xFFF57C00)),
                    SizedBox(width: 4),
                    Text(
                      'Warmup Set',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF57C00),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColLabel extends StatelessWidget {
  final String text;
  const _ColLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9E9E9E),
        letterSpacing: 0.4,
      ),
    );
  }
}

class _LastPerfPill extends StatelessWidget {
  final String label;
  final double? weightKg;
  final int? reps;
  final double? durationSec; //  add
  final double? distanceMeters; //
  final bool isCardio;
  const _LastPerfPill({
    required this.label,
    this.weightKg,
    this.reps,
    this.durationSec,
    this.distanceMeters,
    this.isCardio = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = isCardio
        ? (durationSec != null
              ? '$label: ${durationSec}mins ${distanceMeters ?? 0}km'
              : label)
        : (weightKg != null && reps != null
              ? '$label: ${weightKg}kg×$reps'
              : label);

    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF9E9E9E),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
