import 'package:flutter/material.dart';
import '../../../../widgets/common.dart';
import 'active_set_model.dart';
import 'set_input.dart';
import 'rpe_picker.dart';

// One set row inside an exercise card
// Shows set number or w, kg, reps, RPE, complete circle, remove
class SetRowV2 extends StatelessWidget {
  final ActiveSet set;
  final Function(ActiveSet updated) onChanged;
  final VoidCallback onCompleted;
  final VoidCallback onRemoved;

  const SetRowV2({
    super.key,
    required this.set,
    required this.onChanged,
    required this.onCompleted,
    required this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // PR badge floats above the row
          if (set.isPR) const Positioned(top: -8, right: 24, child: _PRBadge()),

          Row(
            children: [
              // W badge for warmup, number for normal sets
              SizedBox(
                width: 30,
                child: set.isWarmup
                    ? const _WarmupBadge()
                    : Text(
                        '${set.setNumber}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
              ),
              const SizedBox(width: 8),

              // kg input
              Expanded(
                child: SetInputV2(
                  value: set.weightKg?.toString() ?? '',
                  hint: 'kg',
                  onChanged: (val) {
                    onChanged(set.copyWith(weightKg: double.tryParse(val)));
                  },
                ),
              ),
              const SizedBox(width: 8),

              // reps input
              Expanded(
                child: SetInputV2(
                  value: set.reps?.toString() ?? '',
                  hint: 'reps',
                  onChanged: (val) {
                    onChanged(set.copyWith(reps: int.tryParse(val)));
                  },
                ),
              ),
              const SizedBox(width: 8),

              // RPE cell, tap to open picker
              SizedBox(
                width: 46,
                child: GestureDetector(
                  onTap: () => showRpePicker(
                    context: context,
                    set: set,
                    onChanged: onChanged,
                  ),
                  child: Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: set.rpe != null
                          ? const Color(0xFFFFF3E0)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      set.rpe?.toString() ?? '—',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: set.rpe != null
                            ? const Color(0xFFF57C00)
                            : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Complete circle
              GestureDetector(
                onTap: onCompleted,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: set.isCompleted ? kPrimary : Colors.transparent,
                    border: set.isCompleted
                        ? null
                        : Border.all(color: const Color(0xFFBDBDBD), width: 2),
                  ),
                  child: set.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),

              // Remove set
              GestureDetector(
                onTap: onRemoved,
                child: const SizedBox(
                  width: 24,
                  child: Icon(Icons.close, size: 16, color: Color(0xFFBDBDBD)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Orange W badge for warmup sets
class _WarmupBadge extends StatelessWidget {
  const _WarmupBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: const Text(
        'W',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF57C00),
        ),
      ),
    );
  }
}

// Yellow PR trophy badge shown above the row
class _PRBadge extends StatelessWidget {
  const _PRBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 12, color: Color(0xFFF9A825)),
          SizedBox(width: 2),
          Text(
            'PR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF9A825),
            ),
          ),
        ],
      ),
    );
  }
}
