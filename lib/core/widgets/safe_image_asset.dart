import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SafeImageAsset extends StatelessWidget {
  final String assetPath;
  final double? height;
  final double? width;
  final BoxFit? fit;

  const SafeImageAsset(
    this.assetPath, {
    super.key,
    this.height,
    this.width,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    // Check if running in a widget/unit test environment
    final isTest = kIsWeb ? false : Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      return SizedBox(
        height: height,
        width: width ?? height,
        child: const Placeholder(
          color: Colors.transparent,
          strokeWidth: 0,
        ),
      );
    }
    return Image.asset(
      assetPath,
      height: height,
      width: width,
      fit: fit,
    );
  }
}
