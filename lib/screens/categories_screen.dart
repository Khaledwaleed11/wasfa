import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../services/meal_service.dart';
import '../widgets/build_error.dart';
import '../widgets/build_loading.dart';
import '../widgets/category_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/search_bar.dart';
import 'category_meals_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  final MealService _mealService = MealService();

  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  List<CategoryModel> _allCategories = [];
  List<CategoryModel> _filteredCategories = [];

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
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
        );

    _searchController.addListener(_filterCategories);

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await _mealService.getCategories();

      if (!mounted) return;

      setState(() {
        _allCategories = result;
        _filteredCategories = result;
        _isLoading = false;
      });

      _pageController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _filterCategories() {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = query.isEmpty
        ? _allCategories
        : _allCategories.where((category) {
            return category.name.toLowerCase().contains(query);
          }).toList();

    if (!mounted) return;

    setState(() {
      _filteredCategories = filtered;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
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
    _searchController.removeListener(_filterCategories);
    _searchController.dispose();
    _searchFocusNode.dispose();
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.category_rounded,
                size: 20,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Categories',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_isLoading) {
      return const BuildLoading(itemCount: 6, childAspectRatio: 0.88);
    }

    if (_errorMessage != null) {
      return BuildError(
        title: 'Failed to Load Categories',
        message: 'Check your internet connection and try again.',
        buttonText: 'Try Again',
        onRetry: _loadCategories,
        icon: Icons.category_outlined,
      );
    }

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: _loadCategories,
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(colors),
                      const SizedBox(height: 18),
                      SearchBarWidget(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onSearch: () {},
                        onClear: _clearSearch,
                        onChanged: (_) {},
                        hintText: 'Search for a category...',
                        showSearchButton: false,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            _searchController.text.trim().isEmpty
                                ? 'All Categories'
                                : 'Search Results',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: colors.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_filteredCategories.length} categories',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildGrid(),
                    ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            colors.primary,
            Color.lerp(colors.primary, colors.primaryContainer, 0.45)!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover a World of Recipes',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose What You Crave',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recipes for Every Taste',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    if (_filteredCategories.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Categories Found',
        message: 'Try a different search term.',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredCategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        final category = _filteredCategories[index];

        return TweenAnimationBuilder<double>(
          key: ValueKey(category.id),
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 350 + (index * 35).clamp(0, 300)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 18 * (1 - value)),
                child: Transform.scale(
                  scale: 0.96 + (value * 0.04),
                  child: child,
                ),
              ),
            );
          },
          child: CategoryCard(
            category: category,
            icon: _categoryIcon(category.name),
            onTap: () => _openCategory(category),
          ),
        );
      },
    );
  }
}
