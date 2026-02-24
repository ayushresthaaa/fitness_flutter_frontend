import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../widgets/common.dart';

// Shows elapsed workout time in the app bar
// Counts up every second from when the workout started
class WorkoutTimerV2 extends StatefulWidget {
  final DateTime startTime;

  const WorkoutTimerV2({super.key, required this.startTime});

  @override
  State<WorkoutTimerV2> createState() => _WorkoutTimerV2State();
}

class _WorkoutTimerV2State extends State<WorkoutTimerV2> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Calculate how much time has already passed since workout started
    _elapsed = DateTime.now().difference(widget.startTime);

    // Tick every second to update the display
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(widget.startTime);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Format duration as mm:ss or h:mm:ss if over an hour
  String _format(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: kPrimaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 14, color: kPrimary),
          const SizedBox(width: 4),
          Text(
            _format(_elapsed),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
