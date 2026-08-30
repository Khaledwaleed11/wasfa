import 'package:flutter/material.dart';

import '../models/meal_model.dart';
import '../services/meal_service.dart';
import '../services/recent_meal_service.dart';
import '../widgets/build_error.dart';
import '../widgets/build_loading.dart';
import '../widgets/empty_state.dart';
import '../widgets/meal_card.dart';
import 'recipe_details_screen.dart';

class CategoryMealsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryMealsScreen({super.key, required this.categoryName});

  @override
  State<CategoryMealsScreen> createState() => _CategoryMealsScreenState();
}

class _CategoryMealsScreenState extends State<CategoryMealsScreen>
    with SingleTickerProviderStateMixin {
  final MealService _mealService = MealService();

  List<MealModel> _meals = [];

  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _pageController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
        );

    _loadMeals();
  }

  Future<void> _loadMeals({bool refresh = false}) async {
    if (!refresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final result = await _mealService.getMealsByCategory(widget.categoryName);

      if (!mounted) {
        return;
      }

      setState(() {
        _meals = result;
        _isLoading = false;
        _errorMessage = null;
      });

      _pageController.forward(from: 0);
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
    await RecentMealsService.addRecentMeal(meal);

    if (!mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailsScreen(mealId: meal.id)),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _loadMeals(refresh: true);
            },
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_isLoading) {
      return const BuildLoading(itemCount: 8, childAspectRatio: 0.62);
    }

    if (_errorMessage != null) {
      return BuildError(
        title: 'Failed to Load Recipes',
        message: 'Check your internet connection and try again.',
        buttonText: 'Try Again',
        onRetry: _loadMeals,
      );
    }

    if (_meals.isEmpty) {
      return const EmptyState(
        icon: Icons.restaurant_outlined,
        title: 'No Recipes Found',
        message: 'Try another category.',
      );
    }

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: () => _loadMeals(refresh: true),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                sliver: SliverToBoxAdapter(child: _buildHeader(colors)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final meal = _meals[index];

                    final duration = 350 + ((index % 8) * 45);

                    return TweenAnimationBuilder<double>(
                      key: ValueKey(meal.id),
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: duration),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Transform.scale(
                              scale: 0.97 + (value * 0.03),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: MealCard(meal: meal, onTap: () => _openMeal(meal)),
                    );
                  }, childCount: _meals.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.62,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: 22,
              color: colors.onPrimary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.categoryName} Recipes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_meals.length} recipes available to explore',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
