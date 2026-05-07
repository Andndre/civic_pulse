import 'package:flutter/material.dart';
import '../constants/constants.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cardChild = Container(
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: borderRadius ?? AppRadius.card,
        boxShadow: _getShadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius ?? AppRadius.card,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? AppRadius.card,
            child: cardChild,
          ),
        ),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: cardChild,
    );
  }

  List<BoxShadow> get _getShadows {
    if (elevation == 0) return [];
    final level = elevation ?? 2;
    if (level <= 2) return AppShadows.shadowSm;
    if (level <= 4) return AppShadows.shadowMd;
    if (level <= 8) return AppShadows.shadowLg;
    return AppShadows.shadowXl;
  }
}
