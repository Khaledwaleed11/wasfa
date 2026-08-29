import 'package:flutter/material.dart';

import '../models/meal_model.dart';

class IngredientItem extends StatelessWidget {
  final IngredientModel ingredient;

  const IngredientItem({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            Icons.restaurant_outlined,
            size: 17,
            color: colors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            ingredient.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ),
        if (ingredient.measure.trim().isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxWidth: 110),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              ingredient.measure.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
