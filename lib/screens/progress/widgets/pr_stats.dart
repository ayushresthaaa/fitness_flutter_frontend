import 'package:flutter/material.dart';
import '../../../widgets/common.dart';

class PRStatsCard extends StatelessWidget {
  final double? heaviestWeight;
  final double? best1RM;
  final double? bestSetVolume;
  final double? bestSessionVolume;

  const PRStatsCard({
    super.key,
    this.heaviestWeight,
    this.best1RM,
    this.bestSetVolume,
    this.bestSessionVolume,
  });

  String _formatKg(double? value) {
    if (value == null) return '-';
    return '${value.toStringAsFixed(1)}kg';
  }

  String _formatVolume(double? value) {
    if (value == null) return '-';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k kg';
    return '${value.toStringAsFixed(0)}kg';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('PERSONAL RECORDS'),
          const SizedBox(height: 12),
          _StatRow(label: 'Heaviest Weight', value: _formatKg(heaviestWeight)),
          const Divider(height: 20, color: kDivider),
          _StatRow(
            label: 'Best 1RM',
            value: _formatKg(best1RM),
            subtitle: 'Epley estimate',
          ),
          const Divider(height: 20, color: kDivider),
          _StatRow(
            label: 'Best Set Volume',
            value: _formatVolume(bestSetVolume),
            subtitle: 'weight × reps',
          ),
          const Divider(height: 20, color: kDivider),
          _StatRow(
            label: 'Best Session Volume',
            value: _formatVolume(bestSessionVolume),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;

  const _StatRow({required this.label, required this.value, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kTextDark,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 11, color: kTextGrey),
                ),
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: kPrimary,
          ),
        ),
      ],
    );
  }
}
