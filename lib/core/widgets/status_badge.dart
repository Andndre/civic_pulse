import 'package:flutter/material.dart';
import '../constants/constants.dart';

enum AppStatus { success, warning, danger, info }

class StatusBadge extends StatelessWidget {
  final String label;
  final AppStatus status;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.status,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor,
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(_getIcon, size: 14, color: _getColor),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: _getColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color get _getColor {
    switch (status) {
      case AppStatus.success:
        return AppColors.success;
      case AppStatus.warning:
        return AppColors.warning;
      case AppStatus.danger:
        return AppColors.danger;
      case AppStatus.info:
        return AppColors.info;
    }
  }

  Color get _getBackgroundColor {
    switch (status) {
      case AppStatus.success:
        return AppColors.successLight;
      case AppStatus.warning:
        return AppColors.warningLight;
      case AppStatus.danger:
        return AppColors.dangerLight;
      case AppStatus.info:
        return AppColors.infoLight;
    }
  }

  IconData get _getIcon {
    if (icon != null) return icon!;
    switch (status) {
      case AppStatus.success:
        return Icons.check_circle;
      case AppStatus.warning:
        return Icons.warning;
      case AppStatus.danger:
        return Icons.error;
      case AppStatus.info:
        return Icons.info;
    }
  }
}

class StatusDot extends StatelessWidget {
  final AppStatus status;
  final double size;

  const StatusDot({
    super.key,
    required this.status,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Color get _getColor {
    switch (status) {
      case AppStatus.success:
        return AppColors.success;
      case AppStatus.warning:
        return AppColors.warning;
      case AppStatus.danger:
        return AppColors.danger;
      case AppStatus.info:
        return AppColors.info;
    }
  }
}
