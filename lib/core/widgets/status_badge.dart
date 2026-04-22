import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum AppStatus { pending, approved, rejected, inProgress, completed, expired, active }

class StatusBadge extends StatelessWidget {
  final AppStatus status;
  final String? customLabel;

  const StatusBadge({super.key, required this.status, this.customLabel});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case AppStatus.pending:
        bgColor = AppColors.warningLight;
        textColor = AppColors.warning;
        label = customLabel ?? 'Pending';
        icon = Icons.schedule_rounded;
        break;
      case AppStatus.approved:
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        label = customLabel ?? 'Approved';
        icon = Icons.check_circle_rounded;
        break;
      case AppStatus.rejected:
        bgColor = AppColors.errorLight;
        textColor = AppColors.error;
        label = customLabel ?? 'Rejected';
        icon = Icons.cancel_rounded;
        break;
      case AppStatus.inProgress:
        bgColor = AppColors.infoLight;
        textColor = AppColors.info;
        label = customLabel ?? 'In Progress';
        icon = Icons.autorenew_rounded;
        break;
      case AppStatus.completed:
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        label = customLabel ?? 'Completed';
        icon = Icons.task_alt_rounded;
        break;
      case AppStatus.expired:
        bgColor = AppColors.errorLight;
        textColor = AppColors.error;
        label = customLabel ?? 'Expired';
        icon = Icons.warning_amber_rounded;
        break;
      case AppStatus.active:
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        label = customLabel ?? 'Active';
        icon = Icons.verified_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
