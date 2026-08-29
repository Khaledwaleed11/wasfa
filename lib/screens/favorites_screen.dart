import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/meal_model.dart';
import '../services/favorites_service.dart';
import '../services/recent_meal_service.dart';
import '../widgets/build_loading.dart';
import '../widgets/empty_state.dart';
import '../widgets/meal_card.dart';
import 'categories_screen.dart';
import 'recipe_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  static const String _boxName = 'favoriteMeals';

  List<MealModel> favorites = [];

  bool isLoading = true;

  late AnimationController _pageController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Box? _favoritesBox;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
        );

    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final box = Hive.isBoxOpen(_boxName)
          ? Hive.box(_boxName)
          : await Hive.openBox(_boxName);

      _favoritesBox = box;
      box.listenable().addListener(_onFavoritesChanged);

      await loadFavorites();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void _onFavoritesChanged() {
    if (!mounted || _favoritesBox == null) {
      return;
    }

    _updateFavorites();
  }

  void _updateFavorites() {
    final box = _favoritesBox;

    if (box == null) {
      return;
    }

    final result = box.values
        .whereType<Map>()
        .map((item) => MealModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    setState(() {
      favorites = result;
      isLoading = false;
    });
  }

  Future<void> loadFavorites() async {
    try {
      final result = await FavoritesService.getFavorites();

      if (!mounted) return;

      setState(() {
        favorites = result;
        isLoading = false;
      });

      _pageController.forward(from: 0);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openRecipe(MealModel meal) async {
    await RecentMealsService.addRecentMeal(meal);

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailsScreen(mealId: meal.id)),
    );

    await loadFavorites();
  }

  void removeFavoriteFromUi(MealModel meal) {
    if (!mounted) return;

    setState(() {
      favorites.removeWhere((item) => item.id == meal.id);
    });
  }

  Future<void> clearFavorites() async {
    if (favorites.isEmpty) {
      return;
    }

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Clear Favorites',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Do you want to remove all recipes from your favorites?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) {
      return;
    }

    await FavoritesService.clearFavorites();

    if (!mounted) return;

    setState(() {
      favorites.clear();
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Favorites cleared'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1200),
      ),
    );
  }

  @override
  void dispose() {
    _favoritesBox?.listenable().removeListener(_onFavoritesChanged);

    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: isLoading
            ? const BuildLoading(itemCount: 6, childAspectRatio: 0.68)
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContent(colors),
                ),
              ),
      ),
    );
  }

  Widget _buildContent(ColorScheme colors) {
    if (favorites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'No Favorite Recipes Yet ❤️',
        message:
            'When you like a recipe, tap the heart and it will appear here.',
        buttonText: 'Discover New Recipes',
        onButtonPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoriesScreen()),
          );
        },
      );
    }

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: loadFavorites,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            sliver: SliverToBoxAdapter(child: _buildHeader(colors)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final meal = favorites[index];

                return TweenAnimationBuilder<double>(
                  key: ValueKey(meal.id),
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(
                    milliseconds: 250 + ((index % 6) * 40).clamp(0, 220),
                  ),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - value)),
                        child: Transform.scale(
                          scale: 0.97 + (value * 0.03),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: MealCard(
                    meal: meal,
                    onTap: () => openRecipe(meal),
                    onFavoriteChanged: (isFavorite) {
                      if (!isFavorite) {
                        removeFavoriteFromUi(meal);
                      }
                    },
                  ),
                );
              }, childCount: favorites.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                childAspectRatio: 0.68,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.favorite_rounded,
                size: 23,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Favorites',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${favorites.length} saved recipes',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: colors.surface,
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                onTap: clearFavorites,
                borderRadius: BorderRadius.circular(13),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.delete_outline_rounded, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.bookmark_outline_rounded,
                size: 18,
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Save the recipes you love and find them easily anytime.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
