// lib/screens/meal/widgets/hydration_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/common.dart';
import '../../../models/meal/meal_log_model.dart';
import '../../../providers/meal/meal_log_provider.dart';

class HydrationCard extends StatelessWidget {
  final Hydration hydration;
  final bool isToday;

  const HydrationCard({
    super.key,
    required this.hydration,
    required this.isToday,
  });

  void _logWater(BuildContext context, int amount) {
    context.read<MealLogProvider>().logWater(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_outlined, color: kPrimary, size: 18),
              const SizedBox(width: 8),
              const Expanded(child: SectionLabel('Hydration')),
              Text(
                '${hydration.consumed} / ${hydration.goal} ml',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kTextGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: hydration.progress,
              minHeight: 6,
              backgroundColor: kDivider,
              valueColor: const AlwaysStoppedAnimation<Color>(kPrimary),
            ),
          ),
          // only show add buttons for today
          if (isToday) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _WaterButton(
                  label: '+ 150ml',
                  onTap: () => _logWater(context, 150),
                ),
                const SizedBox(width: 8),
                _WaterButton(
                  label: '+ 250ml',
                  onTap: () => _logWater(context, 250),
                ),
                const SizedBox(width: 8),
                _WaterButton(
                  label: '+ 500ml',
                  onTap: () => _logWater(context, 500),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _WaterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _WaterButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: kPrimaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
