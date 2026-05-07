import 'package:flutter/material.dart';
import '../constants/constants.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = imageUrl != null && imageUrl!.isNotEmpty
        ? _buildNetworkImage()
        : _buildFallback();

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildNetworkImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            color: AppColors.surfaceVariant,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallback() {
    final initial = _getInitial;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.primary,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  String get _getInitial {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }
}
