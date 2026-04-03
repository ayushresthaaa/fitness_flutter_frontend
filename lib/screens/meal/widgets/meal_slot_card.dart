// lib/screens/meal/widgets/meal_slot_card.dart

import 'package:flutter/material.dart';
import '../../../widgets/common.dart';
import '../../../models/meal/meal_log_model.dart';
import 'meal_item_title.dart';

class MealSlotCard extends StatelessWidget {
  final MealSlot slot;
  final bool isToday;
  final VoidCallback onAddFood;

  const MealSlotCard({
    super.key,
    required this.slot,
    required this.isToday,
    required this.onAddFood,
  });

  IconData _slotIcon(String type) {
    switch (type) {
      case 'breakfast':
        return Icons.wb_sunny_outlined;
      case 'lunch':
        return Icons.light_mode_outlined;
      case 'dinner':
        return Icons.nights_stay_outlined;
      case 'snack':
        return Icons.local_cafe_outlined;
      default:
        return Icons.restaurant_outlined;
    }
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
          // slot header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_slotIcon(slot.type), color: kPrimary, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextDark,
                      ),
                    ),
                    if (slot.time != null)
                      Text(
                        slot.time!,
                        style: const TextStyle(fontSize: 11, color: kTextGrey),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${slot.totalCalories.toInt()} kcal',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kPrimary,
                  ),
                ),
              ),
            ],
          ),

          // food items list
          if (slot.items.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Divider(color: kDivider, height: 1),
            for (int i = 0; i < slot.items.length; i++) ...[
              MealItemTile(item: slot.items[i], isToday: isToday),
              if (i < slot.items.length - 1)
                const Divider(color: kDivider, height: 1),
            ],
          ],

          // add food button — today only
          if (isToday) ...[
            const SizedBox(height: 10),
            AddButton(
              text: 'Add food to ${slot.displayName}',
              onTap: onAddFood,
            ),
          ],
        ],
      ),
    );
  }
}
