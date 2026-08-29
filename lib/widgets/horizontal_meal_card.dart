import 'package:flutter/material.dart';

import '../models/meal_model.dart';

class HorizontalMealCard extends StatelessWidget {
  final MealModel meal;
  final VoidCallback onTap;
  final double width;
  final double height;

  const HorizontalMealCard({
    super.key,
    required this.meal,
    required this.onTap,
    this.width = 235,
    this.height = 108,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: colors.primary.withValues(alpha: 0.06),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.30),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.025),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.network(
                  meal.image,
                  width: 88,
                  height: 92,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 88,
                      height: 92,
                      color: colors.surfaceContainerHigh,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: colors.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      meal.category.isEmpty ? 'Recipe' : meal.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
