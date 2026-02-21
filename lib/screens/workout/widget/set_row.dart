import 'package:flutter/material.dart';

class SetData {
  final double? weightKg;
  final int? reps;
  final bool isCompleted;

  const SetData({this.weightKg, this.reps, this.isCompleted = false});

  SetData copyWith({double? weightKg, int? reps, bool? isCompleted}) => SetData(
    weightKg: weightKg ?? this.weightKg,
    reps: reps ?? this.reps,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}

class SetRow extends StatefulWidget {
  final int setNumber;
  final SetData data;
  final Function(SetData) onChanged;
  final VoidCallback onToggleDone;
  final VoidCallback onRemove;

  const SetRow({
    super.key,
    required this.setNumber,
    required this.data,
    required this.onChanged,
    required this.onToggleDone,
    required this.onRemove,
  });

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late final TextEditingController _weightCtrl;
  late final TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
      text: widget.data.weightKg?.toString() ?? '',
    );
    _repsCtrl = TextEditingController(text: widget.data.reps?.toString() ?? '');
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(bool done) => InputDecoration(
    filled: true,
    fillColor: done ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
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
      borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
    ),
  );

  TextStyle _inputStyle(bool done) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: done ? const Color(0xFF2E7D32) : const Color(0xFF1A1A1A),
  );

  @override
  Widget build(BuildContext context) {
    final done = widget.data.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 24,
            child: Text(
              '${widget.setNumber}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Weight
          Expanded(
            child: TextField(
              controller: _weightCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: _inputStyle(done),
              decoration: _inputDecoration(done),
              onChanged: (v) => widget.onChanged(
                widget.data.copyWith(weightKg: double.tryParse(v)),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Reps
          Expanded(
            child: TextField(
              controller: _repsCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: _inputStyle(done),
              decoration: _inputDecoration(done),
              onChanged: (v) =>
                  widget.onChanged(widget.data.copyWith(reps: int.tryParse(v))),
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
                color: done ? const Color(0xFF2E7D32) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
                border: done
                    ? null
                    : Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
              ),
              child: Icon(
                done ? Icons.check : Icons.circle_outlined,
                size: 18,
                color: done ? Colors.white : const Color(0xFF9E9E9E),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Remove button
          GestureDetector(
            onTap: widget.onRemove,
            child: const Icon(Icons.close, size: 16, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}
