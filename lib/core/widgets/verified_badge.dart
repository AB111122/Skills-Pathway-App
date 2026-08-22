import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/text_styles.dart';

/// Verified Badge that strictly displays only when [isVerified] is true.
/// Renders an official blue/teal checkmark badge with "Verified" text or compact icon.
class VerifiedBadge extends StatelessWidget {
  final bool isVerified;
  final bool isCompact;
  final String? customLabel;

  const VerifiedBadge({
    super.key,
    required this.isVerified,
    this.isCompact = false,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Strict requirement: Never display verified badge for unverified records
    if (!isVerified) return const SizedBox.shrink();

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: AppColors.verifiedBadge,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          size: 10,
          color: Colors.white,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.verifiedBadge.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.verifiedBadge.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              color: AppColors.verifiedBadge,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 9,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            customLabel ?? 'Verified',
            style: AppTextStyles.labelSmall(
              context,
              color: AppColors.verifiedBadge,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
