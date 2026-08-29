import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  const SectionHeader({
    super.key,
    required this.title,
    required this.action,
    this.onAction,
    this.actionIcon = Icons.arrow_forward_ios_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(actionIcon, size: 9, color: colors.primary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
