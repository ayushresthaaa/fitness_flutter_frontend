import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../widgets/common.dart';

// Shows a countdown banner after user completes a set
// Automatically hides when timer reaches zero
// User can also skip it early
class RestTimerBannerV2 extends StatefulWidget {
  final int restSeconds; // how long to rest (default 90)
  final VoidCallback onDone; // called when timer finishes or user skips

  const RestTimerBannerV2({
    super.key,
    this.restSeconds = 90,
    required this.onDone,
  });

  @override
  State<RestTimerBannerV2> createState() => _RestTimerBannerV2State();
}

class _RestTimerBannerV2State extends State<RestTimerBannerV2> {
  late Timer _timer;
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.restSeconds;

    // Tick every second hide banner when done
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _timer.cancel();
        widget.onDone();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Format seconds
  String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kPrimaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: kPrimary, size: 20),
          const SizedBox(width: 10),

          // Label
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rest Timer',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
                Text(
                  'Take a breather',
                  style: TextStyle(fontSize: 11, color: kPrimary),
                ),
              ],
            ),
          ),

          // Countdown
          Text(
            _format(_remaining),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: kPrimary,
            ),
          ),

          const SizedBox(width: 12),

          // Skip button
          GestureDetector(
            onTap: () {
              _timer.cancel();
              widget.onDone();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
