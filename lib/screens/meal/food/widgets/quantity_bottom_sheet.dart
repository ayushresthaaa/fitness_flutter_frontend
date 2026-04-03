// lib/screens/meal/widgets/quantity_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../widgets/common.dart';
import '../../../../models/meal/food_model.dart';
import '../../../../providers/meal/meal_log_provider.dart';

class QuantityBottomSheet extends StatefulWidget {
  final Food food;
  final String slotId;

  const QuantityBottomSheet({
    super.key,
    required this.food,
    required this.slotId,
  });

  // convenience static method so any screen can open this with one line
  static Future<bool> show(
    BuildContext context, {
    required Food food,
    required String slotId,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => QuantityBottomSheet(food: food, slotId: slotId),
    );
    return result == true;
  }

  @override
  State<QuantityBottomSheet> createState() => _QuantityBottomSheetState();
}

class _QuantityBottomSheetState extends State<QuantityBottomSheet> {
  late TextEditingController _quantityController;
  late double _quantity;
  bool _isLogging = false;

  @override
  void initState() {
    super.initState();
    // start with the food's default serving size
    _quantity = widget.food.servingSize;
    _quantityController = TextEditingController(
      text: _quantity.toInt().toString(),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  // these recompute live as the user changes quantity
  double get _calories => widget.food.caloriesFor(_quantity);
  double get _protein => widget.food.proteinFor(_quantity);
  double get _carbs => widget.food.carbsFor(_quantity);
  double get _fat => widget.food.fatFor(_quantity);

  void _onQuantityTyped(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed > 0) {
      setState(() {
        _quantity = parsed;
      });
    }
  }

  // step buttons adjust by 10 units at a time
  void _increment() {
    final newQty = (_quantity + 10).clamp(1, 9999).toDouble();
    setState(() {
      _quantity = newQty;
      _quantityController.text = newQty.toInt().toString();
    });
  }

  void _decrement() {
    final newQty = (_quantity - 10).clamp(1, 9999).toDouble();
    setState(() {
      _quantity = newQty;
      _quantityController.text = newQty.toInt().toString();
    });
  }

  Future<void> _logFood() async {
    if (_quantity <= 0) return;

    setState(() => _isLogging = true);

    final success = await context.read<MealLogProvider>().addMealItem(
      slotId: widget.slotId,
      foodId: widget.food.id,
      quantity: _quantity,
      unit: widget.food.servingUnit,
    );
    print('addMealItem success: $success');
    print('error: ${context.read<MealLogProvider>().error}');

    if (!mounted) return;
    setState(() => _isLogging = false);

    if (success) {
      // pop sheet and signal success to food search screen
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log food. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // lift content above keyboard when it opens
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: kTextHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // food name
          Text(
            widget.food.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),

          const SizedBox(height: 2),

          // category label
          Text(
            widget.food.categoryLabel,
            style: const TextStyle(fontSize: 13, color: kTextGrey),
          ),

          const SizedBox(height: 20),

          // quantity row — decrement, text field, increment
          Row(
            children: [
              _StepButton(icon: Icons.remove, onTap: _decrement),

              const SizedBox(width: 12),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: kBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      suffixText: widget.food.servingUnit,
                      suffixStyle: const TextStyle(
                        fontSize: 14,
                        color: kTextGrey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onChanged: _onQuantityTyped,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              _StepButton(icon: Icons.add, onTap: _increment),
            ],
          ),

          const SizedBox(height: 20),

          // live macro preview card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: kBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _MacroCell(
                  label: 'Calories',
                  value: '${_calories.toInt()}',
                  unit: 'kcal',
                  valueColor: kTextDark,
                ),
                _verticalDivider(),
                _MacroCell(
                  label: 'Protein',
                  value: _protein.toStringAsFixed(1),
                  unit: 'g',
                  valueColor: kPrimary,
                ),
                _verticalDivider(),
                _MacroCell(
                  label: 'Carbs',
                  value: _carbs.toStringAsFixed(1),
                  unit: 'g',
                  valueColor: const Color(0xFFFB8C00),
                ),
                _verticalDivider(),
                _MacroCell(
                  label: 'Fat',
                  value: _fat.toStringAsFixed(1),
                  unit: 'g',
                  valueColor: const Color(0xFF8E24AA),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          PrimaryButton(
            text: 'Log Food',
            isLoading: _isLogging,
            onTap: _logFood,
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 36, color: kDivider);
  }
}

// +/- step button
class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: kPrimaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: kPrimary, size: 22),
      ),
    );
  }
}

// one macro value shown in the preview row
class _MacroCell extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color valueColor;

  const _MacroCell({
    required this.label,
    required this.value,
    required this.unit,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: kTextGrey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          Text(unit, style: const TextStyle(fontSize: 10, color: kTextGrey)),
        ],
      ),
    );
  }
}
