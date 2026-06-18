import 'package:flutter/material.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/wheelride_models.dart';

class RiderMarker extends StatelessWidget {
  const RiderMarker({
    required this.isCurrentUser,
    super.key,
    this.participant,
  });

  final bool isCurrentUser;
  final RideParticipant? participant;

  @override
  Widget build(BuildContext context) {
    final color = isCurrentUser ? Colors.lightBlueAccent : AppTheme.neon;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.ink,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          padding: const EdgeInsets.all(7),
          child: Icon(
            isCurrentUser ? AppIcons.riderSelf : AppIcons.riderOther,
            color: color,
            size: isCurrentUser ? 18 : 10,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.ink.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            participant?.name ?? 'Rider',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
