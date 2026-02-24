import 'package:flutter/material.dart';
import 'active_set_model.dart';

// Shows a bottom sheet for user to pick RPE
// Called when user taps the RPE cell in a set row
void showRpePicker({
  required BuildContext context,
  required ActiveSet set,
  required Function(ActiveSet updated) onChanged,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Rate of Perceived Exertion',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle
            const Text(
              '1 = very easy  ·  10 = maximum effort',
              style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 16),

            // RPE buttons 1-10
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int rpe = 1; rpe <= 10; rpe++)
                  GestureDetector(
                    onTap: () {
                      onChanged(set.copyWith(rpe: rpe));
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: set.rpe == rpe
                            ? const Color(0xFFF57C00)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$rpe',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: set.rpe == rpe
                              ? Colors.white
                              : const Color(0xFF212121),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
