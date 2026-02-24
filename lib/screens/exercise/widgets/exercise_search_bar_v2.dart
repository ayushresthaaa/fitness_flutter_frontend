import 'dart:async';
import 'package:flutter/material.dart';
import '../../../widgets/common.dart';

// Search bar with debounce so we don't fire API call on every keystroke
class ExerciseSearchBarV2 extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const ExerciseSearchBarV2({super.key, required this.onChanged});

  @override
  State<ExerciseSearchBarV2> createState() => _ExerciseSearchBarV2State();
}

class _ExerciseSearchBarV2State extends State<ExerciseSearchBarV2> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged(value.trim());
    });
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        style: const TextStyle(fontSize: 14, color: kTextDark),
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          hintStyle: const TextStyle(fontSize: 14, color: kTextGrey),
          prefixIcon: const Icon(Icons.search, color: kTextGrey, size: 20),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: kTextGrey, size: 18),
                  onPressed: _clear,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
