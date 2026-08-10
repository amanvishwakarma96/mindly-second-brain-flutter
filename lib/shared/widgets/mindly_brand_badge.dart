import 'package:flutter/material.dart';
import 'package:mindly/shared/design_tokens/mindly_colors.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class MindlyBrandBadge extends StatelessWidget {
  const MindlyBrandBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MindlySpacing.md,
        vertical: MindlySpacing.sm,
      ),
      decoration: BoxDecoration(
        color: MindlyColors.lavender,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text('Mindly ✦'),
    );
  }
}
