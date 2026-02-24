import 'package:flutter/material.dart';

// Reusable number input for kg and reps fields in a set row
// Manages its own TextEditingController so the keyboard stays stable
class SetInputV2 extends StatefulWidget {
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;

  const SetInputV2({
    super.key,
    required this.value,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<SetInputV2> createState() => _SetInputV2State();
}

class _SetInputV2State extends State<SetInputV2> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(SetInputV2 old) {
    super.didUpdateWidget(old);
    // Only update if value changed from outside and user isn't typing
    if (old.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF212121),
      ),
    );
  }
}
