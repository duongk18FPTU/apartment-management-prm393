import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../app/theme.dart';

/// Loading indicator widgets following the DESIGN.md Modern Haven system.
///
/// Two named constructors:
/// - [LoadingIndicator.circular] — small amber spinner for button loading state
/// - [LoadingIndicator.skeleton] — shimmer placeholder matching a layout shape
///
/// Generic [CircularProgressIndicator] with default blue is BANNED.
class LoadingIndicator extends StatelessWidget {
  // Circular variant
  const LoadingIndicator.circular({super.key, this.size = 20})
    : _variant = _Variant.circular,
      width = null,
      height = null,
      borderRadius = null;

  // Skeleton variant
  const LoadingIndicator.skeleton({
    super.key,
    required double this.width,
    required double this.height,
    this.borderRadius = AppRadius.borderSm,
  }) : _variant = _Variant.skeleton,
       size = null;

  final _Variant _variant;
  final double? size;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return switch (_variant) {
      _Variant.circular => _buildCircular(),
      _Variant.skeleton => _buildSkeleton(),
    };
  }

  Widget _buildCircular() {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(DesignTokens.secondary),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: borderRadius ?? AppRadius.borderSm,
        ),
      ),
    );
  }
}

enum _Variant { circular, skeleton }
