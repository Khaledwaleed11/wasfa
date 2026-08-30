import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';
import '../services/recent_meal_service.dart';
import '../widgets/build_error.dart';
import '../widgets/build_loading.dart';
import '../widgets/category_card.dart';
import '../widgets/favorite_button.dart';
import '../widgets/horizontal_meal_card.dart';
import '../widgets/meal_card.dart';
import '../widgets/section_header.dart';
import 'categories_screen.dart';
import 'category_meals_screen.dart';
import 'recipe_details_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final MealService _mealService = MealService();

  List<CategoryModel> _categories = [];
  List<MealModel> _popularMeals = [];
  List<MealModel> _recentMeals = [];

  MealModel? _featuredMeal;

  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _pageController;
  late AnimationController _heroController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _contentSlide;
  late Animation<double> _heroScale;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
        );

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _heroScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic),
    );

    _loadHomeData();
  }

  Future<void> _loadHomeData({bool refresh = false}) async {
    if (!refresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        _mealService.getRandomMeal(),
        _mealService.getCategories(),
        _mealService.getMealsByCategory('Chicken'),
        RecentMealsService.getRecentMeals(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _featuredMeal = results[0] as MealModel;
        _categories = results[1] as List<CategoryModel>;
        _popularMeals = results[2] as List<MealModel>;
        _recentMeals = results[3] as List<MealModel>;
        _isLoading = false;
        _errorMessage = null;
      });

      _pageController.forward(from: 0);

      _heroController.forward(from: 0);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _openMeal(MealModel meal) async {
    try {
      await RecentMealsService.addRecentMeal(meal);
    } catch (_) {}

    if (!mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailsScreen(mealId: meal.id)),
    );

    await _reloadRecentMeals();
  }

  Future<void> _reloadRecentMeals() async {
    try {
      final result = await RecentMealsService.getRecentMeals();

      if (!mounted) {
        return;
      }

      setState(() {
        _recentMeals = result;
      });
    } catch (_) {}
  }

  void _openCategory(CategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryMealsScreen(categoryName: category.name),
      ),
    );
  }

  IconData _categoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'beef':
        return Icons.lunch_dining_rounded;

      case 'chicken':
        return Icons.set_meal_rounded;

      case 'dessert':
        return Icons.cake_rounded;

      case 'lamb':
        return Icons.restaurant_rounded;

      case 'miscellaneous':
        return Icons.restaurant_menu_rounded;

      case 'pasta':
        return Icons.ramen_dining_rounded;

      case 'pork':
        return Icons.fastfood_rounded;

      case 'seafood':
        return Icons.phishing_rounded;

      case 'side':
        return Icons.dinner_dining_rounded;

      case 'starter':
        return Icons.tapas_rounded;

      case 'vegan':
        return Icons.eco_rounded;

      case 'vegetarian':
        return Icons.spa_rounded;

      case 'breakfast':
        return Icons.free_breakfast_rounded;

      case 'goat':
        return Icons.restaurant_rounded;

      default:
        return Icons.restaurant_rounded;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heroController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(child: _buildBody(colors)),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_isLoading) {
      return const BuildLoading(itemCount: 6, childAspectRatio: 0.68);
    }

    if (_errorMessage != null) {
      return BuildError(
        title: 'Failed to Load Recipes',
        message: 'Check your internet connection and try again.',
        buttonText: 'Try Again',
        onRetry: () => _loadHomeData(),
      );
    }

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: () => _loadHomeData(refresh: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 34),
            sliver: SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(colors),
                      const SizedBox(height: 24),
                      _buildHero(colors),
                      const SizedBox(height: 22),
                      _buildSearch(colors),
                      const SizedBox(height: 30),
                      _buildCategories(colors),
                      const SizedBox(height: 32),
                      _buildPopular(colors),
                      if (_recentMeals.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _buildRecent(colors),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.restaurant_menu_rounded,
            color: colors.onPrimary,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome 👋',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'What are we cooking today?',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHero(ColorScheme colors) {
    final meal = _featuredMeal;

    if (meal == null) {
      return const SizedBox.shrink();
    }

    return ScaleTransition(
      scale: _heroScale,
      child: GestureDetector(
        onTap: () => _openMeal(meal),
        child: Container(
          height: 285,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                meal.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: colors.surfaceContainerHigh,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 42,
                      color: colors.onSurfaceVariant,
                    ),
                  );
                },
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.86),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Random Recipe',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: FavoriteButton(
                  meal: meal,
                  size: 20,
                  showBackground: true,
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildHeroMeta(
                          Icons.restaurant_outlined,
                          meal.category.isEmpty ? 'Recipe' : meal.category,
                        ),
                        const SizedBox(width: 12),
                        _buildHeroMeta(
                          Icons.public_outlined,
                          meal.area.isEmpty ? 'Various' : meal.area,
                        ),
                      ],
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

  Widget _buildHeroMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSearch(ColorScheme colors) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.42),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.035),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 20,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search for a recipe or ingredient...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            Icon(Icons.tune_rounded, size: 18, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(ColorScheme colors) {
    final visibleCategories = _categories.take(8).toList();

    return Column(
      children: [
        SectionHeader(
          title: 'Categories',
          action: 'View All',
          onAction: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            );
          },
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: visibleCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = visibleCategories[index];

              return CategoryCard(
                category: category,
                icon: _categoryIcon(category.name),
                onTap: () => _openCategory(category),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopular(ColorScheme colors) {
    final meals = _popularMeals.take(8).toList();

    return Column(
      children: [
        SectionHeader(
          title: 'Delicious Recipes',
          action: 'Explore',
          onAction: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          },
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 252,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: meals.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final meal = meals[index];

              return MealCard(meal: meal, onTap: () => _openMeal(meal));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecent(ColorScheme colors) {
    return Column(
      children: [
        SectionHeader(
          title: 'Recently Viewed',
          action: 'Clear',
          onAction: () async {
            await RecentMealsService.clearRecentMeals();

            if (!mounted) {
              return;
            }

            setState(() {
              _recentMeals = [];
            });
          },
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _recentMeals.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final meal = _recentMeals[index];

              return HorizontalMealCard(
                meal: meal,
                onTap: () => _openMeal(meal),
              );
            },
          ),
        ),
      ],
    );
  }
}
