import 'package:flutter/material.dart';
import '../constants/constants.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;
  final bool disabled;
  final IconData? icon;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.loading = false,
    this.disabled = false,
    this.icon,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || loading;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: _buildButton(isDisabled),
    );
  }

  double get _getVerticalPadding {
    switch (size) {
      case AppButtonSize.small:
        return 6.0;
      case AppButtonSize.medium:
        return 10.0;
      case AppButtonSize.large:
        return 14.0;
    }
  }

  double get _getHorizontalPadding {
    switch (size) {
      case AppButtonSize.small:
        return AppSpacing.md;
      case AppButtonSize.medium:
        return AppSpacing.lg;
      case AppButtonSize.large:
        return AppSpacing.xl;
    }
  }

  Widget _buildButton(bool isDisabled) {
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding,
              vertical: _getVerticalPadding,
            ),
          ),
          child: _buildContent(AppColors.textOnPrimary),
        );
      case AppButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textPrimary,
            minimumSize: Size.zero,
            padding: EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding,
              vertical: _getVerticalPadding,
            ),
          ),
          child: _buildContent(AppColors.textPrimary),
        );
      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding,
              vertical: _getVerticalPadding,
            ),
          ),
          child: _buildContent(AppColors.primary),
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding,
              vertical: _getVerticalPadding,
            ),
          ),
          child: _buildContent(AppColors.primary),
        );
      case AppButtonVariant.danger:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: AppColors.textOnPrimary,
            minimumSize: Size.zero,
            padding: EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding,
              vertical: _getVerticalPadding,
            ),
          ),
          child: _buildContent(AppColors.textOnPrimary),
        );
    }
  }

  Widget _buildContent(Color color) {
    if (loading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _getIconSize),
          const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      );
    }

    return Text(label);
  }

  double get _getIconSize {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }
}
