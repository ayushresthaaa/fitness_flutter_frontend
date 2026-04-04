// lib/screens/user/trainer_request/widgets/past_request_tile.dart

import 'package:flutter/material.dart';
// import '../../../../constants/app_constants.dart';
import '../../../widgets/common.dart';
import '../../../../models/trainer/trainer_request_model.dart';

class PastRequestTile extends StatelessWidget {
  final TrainerChangeRequest request;

  const PastRequestTile({super.key, required this.request});

  Color _statusColor() {
    switch (request.status) {
      case 'accepted':
      case 'assigned_by_admin':
        return kGreen;
      case 'closed':
        return kTextGrey;
      case 'needs_admin_attention':
        return kRed;
      default:
        return kPrimary;
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
                if (request.reason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    request.reason!,
                    style: const TextStyle(fontSize: 12, color: kTextGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (request.adminNote != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Admin: ${request.adminNote}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: kTextGrey,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              request.statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
