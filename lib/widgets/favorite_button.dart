import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/meal_model.dart';
import '../services/favorites_service.dart';

class FavoriteButton extends StatefulWidget {
  final MealModel meal;
  final double size;
  final bool showBackground;
  final ValueChanged<bool>? onChanged;

  const FavoriteButton({
    super.key,
    required this.meal,
    this.size = 20,
    this.showBackground = true,
    this.onChanged,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Box _favoritesBox;

  bool _isToggling = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _favoritesBox = Hive.box('favoriteMeals');
  }

  Future<void> _toggleFavorite(bool isFavorite) async {
    if (_isToggling) {
      return;
    }

    setState(() {
      _isToggling = true;
    });

    try {
      final result = await FavoritesService.toggleFavorite(widget.meal);

      if (!mounted) {
        return;
      }

      widget.onChanged?.call(result);

      if (result) {
        await _controller.forward(from: 0);

        if (!mounted) {
          return;
        }

        await _controller.reverse();
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? 'Recipe added to favorites ❤️'
                : 'Recipe removed from favorites',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1100),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update favorites'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1100),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isToggling = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ValueListenableBuilder<Box>(
      valueListenable: _favoritesBox.listenable(),
      builder: (context, box, _) {
        final isFavorite = box.containsKey(widget.meal.id);

        return Material(
          color: widget.showBackground
              ? Colors.black.withValues(alpha: 0.28)
              : Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _isToggling ? null : () => _toggleFavorite(isFavorite),
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: _isToggling
                  ? SizedBox(
                      width: widget.size,
                      height: widget.size,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        color: widget.showBackground
                            ? Colors.white
                            : colors.primary,
                      ),
                    )
                  : ScaleTransition(
                      scale: _scaleAnimation,
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: widget.size,
                        color: isFavorite
                            ? Colors.redAccent
                            : widget.showBackground
                            ? Colors.white
                            : colors.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
