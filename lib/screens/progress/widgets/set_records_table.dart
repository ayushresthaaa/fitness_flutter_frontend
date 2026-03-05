import 'package:flutter/material.dart';
import '../../../widgets/common.dart';

class SetRecordsTable extends StatelessWidget {
  // Map of reps  to best weight  {5: 85.0, 8: 80.0, 10: 60.0}
  final Map<int, double> setRecords;

  const SetRecordsTable({super.key, required this.setRecords});

  @override
  Widget build(BuildContext context) {
    if (setRecords.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('SET RECORDS'),
          const SizedBox(height: 12),

          // Header row
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Reps',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kTextGrey,
                  ),
                ),
              ),
              Text(
                'Personal Best',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kTextGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, color: kDivider),

          // Data rows
          ...setRecords.entries.map((entry) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${entry.key} reps',
                          style: const TextStyle(
                            fontSize: 14,
                            color: kTextDark,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(1)}kg',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: kDivider),
              ],
            );
          }),
        ],
      ),
    );
  }
}
