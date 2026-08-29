import 'package:flutter/material.dart';

class InstructionStep extends StatelessWidget {
  final int stepNumber;
  final String text;

  const InstructionStep({
    super.key,
    required this.stepNumber,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$stepNumber',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.65,
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
