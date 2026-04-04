// lib/screens/user/trainer_request/widgets/active_request_card.dart

import 'package:flutter/material.dart';
import '../../../widgets/common.dart';
import '../../../../models/trainer/trainer_request_model.dart';

class ActiveRequestCard extends StatelessWidget {
  final TrainerChangeRequest request;

  const ActiveRequestCard({super.key, required this.request});

  Color _statusColor() {
    switch (request.status) {
      case 'pending_auto_assign':
        return kPrimary;
      case 'pending_trainer_response':
        return const Color(0xFFFB8C00);
      case 'needs_admin_attention':
        return kRed;
      case 'accepted':
      case 'assigned_by_admin':
        return kGreen;
      case 'closed':
        return kTextGrey;
      default:
        return kTextGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Active Request'),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 6),
              Text(
                request.statusLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            request.statusDescription,
            style: const TextStyle(fontSize: 12, color: kTextGrey, height: 1.5),
          ),
          if (request.reason != null) ...[
            const SizedBox(height: 8),
            Text(
              'Reason: ${request.reason}',
              style: const TextStyle(fontSize: 12, color: kTextGrey),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Submitted ${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
            style: const TextStyle(fontSize: 11, color: kTextHint),
          ),
        ],
      ),
    );
  }
}
