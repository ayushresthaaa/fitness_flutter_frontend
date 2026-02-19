import 'package:flutter/material.dart';

class SetRow extends StatefulWidget {
  final int setNumber;
  final double? weightKg;
  final int? reps;
  final bool isCompleted;
  final ValueChanged<double?> onWeightChanged;
  final ValueChanged<int?> onRepsChanged;
  final VoidCallback onToggleDone;

  const SetRow({
    super.key,
    required this.setNumber,
    this.weightKg,
    this.reps,
    required this.isCompleted,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onToggleDone,
  });

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.weightKg?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.reps?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 30,
            child: Text(
              '${widget.setNumber}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Weight input
          Expanded(
            child: _SetInput(
              controller: _weightController,
              isCompleted: widget.isCompleted,
              onChanged: (v) => widget.onWeightChanged(double.tryParse(v)),
            ),
          ),
          const SizedBox(width: 8),

          // Reps input
          Expanded(
            child: _SetInput(
              controller: _repsController,
              isCompleted: widget.isCompleted,
              onChanged: (v) => widget.onRepsChanged(int.tryParse(v)),
            ),
          ),
          const SizedBox(width: 8),

          // Done button
          GestureDetector(
            onTap: widget.onToggleDone,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: widget.isCompleted
                    ? const Color(0xFF16a34a)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
                border: widget.isCompleted
                    ? null
                    : Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
              ),
              child: Icon(
                widget.isCompleted ? Icons.check : Icons.circle_outlined,
                size: 18,
                color: widget.isCompleted
                    ? Colors.white
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isCompleted;
  final ValueChanged<String> onChanged;

  const _SetInput({
    required this.controller,
    required this.isCompleted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isCompleted ? const Color(0xFF16a34a) : const Color(0xFF1A1A1A),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isCompleted
            ? const Color(0xFFf0fdf4)
            : const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }
}
