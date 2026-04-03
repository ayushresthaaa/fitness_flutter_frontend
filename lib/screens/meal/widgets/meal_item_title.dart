// lib/screens/meal/widgets/meal_item_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/common.dart';
import '../../../widgets/app_dialog.dart';
import '../../../models/meal/meal_log_model.dart';
import '../../../providers/meal/meal_log_provider.dart';

class MealItemTile extends StatelessWidget {
  final MealItem item;
  final bool isToday;

  const MealItemTile({super.key, required this.item, required this.isToday});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: 'Remove food',
      message: 'Remove ${item.food.name} from this meal?',
      actions: [
        const AppDialogAction(label: 'Cancel', value: false),
        AppDialogAction(
          label: 'Remove',
          value: true,
          isButton: true,
          color: const Color(0xFFF44336),
        ),
      ],
    );

    if (confirmed == true && context.mounted) {
      context.read<MealLogProvider>().deleteMealItem(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // food name + macros
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.food.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'P ${item.protein.toInt()}g · C ${item.carbs.toInt()}g · F ${item.fat.toInt()}g',
                  style: const TextStyle(fontSize: 11, color: kTextGrey),
                ),
              ],
            ),
          ),

          // calories
          Text(
            '${item.calories.toInt()} kcal',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kTextDark,
            ),
          ),

          // delete icon — only shown for today's log
          if (isToday) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _confirmDelete(context),
              child: const Icon(
                Icons.delete_outline,
                size: 18,
                color: kTextGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
