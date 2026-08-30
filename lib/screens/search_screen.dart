import 'package:flutter/material.dart';

import '../models/meal_model.dart';
import '../services/meal_service.dart';
import '../widgets/build_error.dart';
import '../widgets/build_loading.dart';
import '../widgets/empty_state.dart';
import '../widgets/meal_card.dart';
import '../widgets/search_bar.dart';
import 'recipe_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final MealService _mealService = MealService();

  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  List<MealModel> _results = [];

  bool _isLoading = false;
  bool _hasSearched = false;

  String? _errorMessage;

  late AnimationController _pageController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _pageController.forward();
  }

  Future<void> _searchMeals() async {
    final query = _searchController.text.trim();

    if (query.isEmpty || _isLoading) {
      return;
    }

    _searchFocusNode.unfocus();

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
    });

    try {
      final result = await _mealService.searchMeals(query);

      if (!mounted) {
        return;
      }

      setState(() {
        _results = result;
        _isLoading = false;
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
    if (!mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailsScreen(mealId: meal.id)),
    );
  }

  void _clearSearch() {
    _searchController.clear();

    if (!mounted) {
      return;
    }

    setState(() {
      _results = [];
      _hasSearched = false;
      _errorMessage = null;
      _isLoading = false;
    });

    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
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
        title: const Text(
          'Search',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SearchBarWidget(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onSearch: _searchMeals,
              onClear: _clearSearch,
              onChanged: (_) {
                if (mounted) {
                  setState(() {});
                }
              },
            ),
            Expanded(child: _buildBody(colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_isLoading) {
      return const BuildLoading(itemCount: 6, childAspectRatio: 0.68);
    }

    if (_errorMessage != null) {
      return BuildError(
        title: 'Search Failed',
        message: 'Check your internet connection and try again.',
        buttonText: 'Search Again',
        onRetry: _searchMeals,
      );
    }

    if (!_hasSearched) {
      return const EmptyState(
        icon: Icons.search_rounded,
        title: 'Find Your Favorite Recipe',
        message: 'Enter a recipe name and press the search button.',
      );
    }

    if (_results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Recipes Found',
        message: 'Try a different recipe name or use a simpler search term.',
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          color: colors.primary,
          backgroundColor: colors.surface,
          onRefresh: _searchMeals,
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            itemCount: _results.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              final meal = _results[index];

              return MealCard(meal: meal, onTap: () => _openMeal(meal));
            },
          ),
        ),
      ),
    );
  }
}
