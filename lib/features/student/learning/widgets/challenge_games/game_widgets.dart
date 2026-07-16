import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/constants.dart';

/// Elemen visual bersama untuk game tantangan (DESIGN.md §7).
///
/// Identitas warna tetap per jenis game (dari palet PULSE §3.3):
/// - Pilihan Ganda   → biru   (pulseParticipation)
/// - Benar / Salah   → oranye (pulseLearning)
/// - Cocokkan        → ungu   (pulseSocialEngagement)
/// - Sortir Kategori → hijau  (pulseUnderstanding)

Color gameDarken(Color color, [double amount = 0.18]) =>
    Color.lerp(color, Colors.black, amount)!;

/// Pill gradient kecil penanda jenis game.
class GameBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const GameBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, gameDarken(color)]),
        borderRadius: AppRadius.radiusFull,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.30),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrapper feedback sentuh: mengecil 0.96 saat ditekan + haptic ringan.
class GamePressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const GamePressable({super.key, required this.child, this.onTap});

  @override
  State<GamePressable> createState() => _GamePressableState();
}

class _GamePressableState extends State<GamePressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}

/// Banner hasil jawaban yang muncul dengan animasi pop.
class GameFeedbackBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String message;

  const GameFeedbackBanner({
    super.key,
    required this.color,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Transform.scale(
        scale: 0.9 + 0.1 * value,
        child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySmall.copyWith(
                  color: gameDarken(color, 0.25),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bar progres membulat dengan gradient dan animasi halus.
class GameProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const GameProgressBar({super.key, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (context, animated, _) => Container(
        height: 10,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppRadius.radiusFull,
        ),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: animated,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, gameDarken(color)]),
              borderRadius: AppRadius.radiusFull,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu soal bergaya hero: latar tint gradient lembut + judul kecil.
class GameQuestionCard extends StatelessWidget {
  final Color color;
  final String? label;
  final String text;

  const GameQuestionCard({
    super.key,
    required this.color,
    this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.10),
            color.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null && label!.isNotEmpty) ...[
            Text(
              label!.toUpperCase(),
              style: AppTypography.labelSmall.copyWith(
                color: gameDarken(color, 0.10),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            AppSpacing.vGapSm,
          ],
          Text(
            text,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
