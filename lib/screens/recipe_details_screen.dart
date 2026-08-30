import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/meal_model.dart';
import '../models/shopping_item_model.dart';
import '../services/favorites_service.dart';
import '../services/meal_service.dart';
import '../services/recent_meal_service.dart';
import '../services/shopping_list_service.dart';
import '../widgets/build_error.dart';
import '../widgets/build_loading.dart';
import '../widgets/ingredient_item.dart';
import '../widgets/instruction_step.dart';
import '../widgets/recipe_info_chip.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String mealId;

  const RecipeDetailsScreen({super.key, required this.mealId});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen>
    with SingleTickerProviderStateMixin {
  final MealService mealService = MealService();

  MealModel? meal;

  bool isLoading = true;
  bool isFavorite = false;
  bool isAddingToShoppingList = false;
  bool isTogglingFavorite = false;

  String? errorMessage;

  late AnimationController _pageController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _contentSlide;

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
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
        );

    loadMeal();
  }

  Future<void> _openUrl(String url) async {
    final cleanedUrl = url.trim();

    if (cleanedUrl.isEmpty) {
      return;
    }

    final normalizedUrl =
        cleanedUrl.startsWith('http://') || cleanedUrl.startsWith('https://')
        ? cleanedUrl
        : 'https://$cleanedUrl';

    final uri = Uri.tryParse(normalizedUrl);

    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid link'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open this link'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open this link'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> loadMeal() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final result = await mealService.getMealDetails(widget.mealId);

      final favorite = await FavoritesService.isFavorite(result.id);

      await RecentMealsService.addRecentMeal(result);

      if (!mounted) {
        return;
      }

      setState(() {
        meal = result;
        isFavorite = favorite;
        isLoading = false;
      });

      _pageController.forward(from: 0);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> toggleFavorite() async {
    if (isTogglingFavorite) {
      return;
    }

    final currentMeal = meal;

    if (currentMeal == null) {
      return;
    }

    setState(() {
      isTogglingFavorite = true;
    });

    try {
      final result = await FavoritesService.toggleFavorite(currentMeal);

      if (!mounted) {
        return;
      }

      setState(() {
        isFavorite = result;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? 'Recipe added to favorites ❤️'
                : 'Recipe removed from favorites',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1300),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favorites.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isTogglingFavorite = false;
        });
      }
    }
  }

  Future<void> addIngredientsToShoppingList() async {
    final currentMeal = meal;

    if (currentMeal == null ||
        currentMeal.ingredients.isEmpty ||
        isAddingToShoppingList) {
      return;
    }

    setState(() {
      isAddingToShoppingList = true;
    });

    try {
      final items = currentMeal.ingredients
          .map((ingredient) {
            return ShoppingItemModel(
              id: '${currentMeal.id}_${ingredient.name.trim()}',
              name: ingredient.name.trim(),
              quantity: ingredient.measure.trim(),
            );
          })
          .where((item) => item.name.isNotEmpty)
          .toList();

      if (items.isEmpty) {
        throw Exception('No ingredients found');
      }

      await ShoppingListService.addItems(items);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe ingredients added to shopping list 🛒'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1500),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add ingredients to shopping list.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAddingToShoppingList = false;
        });
      }
    }
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
      body: _buildBody(context, colors),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme colors) {
    if (isLoading) {
      return const BuildLoading();
    }

    if (errorMessage != null || meal == null) {
      return BuildError(
        title: 'Failed to Load Recipe',
        message: 'Something went wrong while loading the recipe.',
        onRetry: loadMeal,
        icon: Icons.restaurant_menu_outlined,
      );
    }

    return RefreshIndicator(
      color: colors.primary,
      onRefresh: loadMeal,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            expandedHeight: 330,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: colors.surface,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageHeader(context, colors),
            ),
            leading: _buildCircleButton(
              icon: Icons.arrow_back_rounded,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              _buildCircleButton(
                icon: isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                onTap: toggleFavorite,
                iconColor: isFavorite ? Colors.redAccent : Colors.white,
              ),
              const SizedBox(width: 12),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 35),
            sliver: SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _contentSlide,
                  child: _buildContent(context, colors),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context, ColorScheme colors) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          meal!.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: colors.surfaceContainerHigh,
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 45,
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
                Colors.black.withValues(alpha: 0.25),
                Colors.black.withValues(alpha: 0.10),
                Colors.black.withValues(alpha: 0.72),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  meal!.category.isEmpty ? 'Recipe' : meal!.category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                meal!.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 27,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              if (meal!.area.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.public_outlined,
                      size: 15,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      meal!.area,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Icon(icon, size: 20, color: iconColor ?? Colors.white),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(colors),
        const SizedBox(height: 20),
        _buildShoppingButton(colors),
        const SizedBox(height: 28),
        _buildSectionTitle(
          colors,
          'Ingredients',
          'Everything you need to prepare this recipe',
          Icons.shopping_basket_outlined,
        ),
        const SizedBox(height: 14),
        _buildIngredients(colors),
        const SizedBox(height: 28),
        _buildSectionTitle(
          colors,
          'Instructions',
          'Follow the steps for the best result',
          Icons.menu_book_outlined,
        ),
        const SizedBox(height: 14),
        _buildInstructions(colors),
        const SizedBox(height: 28),
        if (meal!.youtubeUrl != null || meal!.sourceUrl != null)
          _buildLinks(colors),
      ],
    );
  }

  Widget _buildShoppingButton(ColorScheme colors) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAddingToShoppingList ? null : addIngredientsToShoppingList,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: isAddingToShoppingList
                      ? Padding(
                          padding: const EdgeInsets.all(11),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        )
                      : Icon(
                          Icons.add_shopping_cart_rounded,
                          size: 20,
                          color: colors.onPrimary,
                        ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAddingToShoppingList
                            ? 'Adding ingredients...'
                            : 'Add ingredients to shopping list',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${meal!.ingredients.length} ingredients available',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: colors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(ColorScheme colors) {
    final items = [
      (
        icon: Icons.category_outlined,
        label: 'Category',
        value: meal!.category.isEmpty ? 'Recipe' : meal!.category,
      ),
      (
        icon: Icons.public_outlined,
        label: 'Cuisine',
        value: meal!.area.isEmpty ? 'Various' : meal!.area,
      ),
      (
        icon: Icons.restaurant_outlined,
        label: 'Ingredients',
        value: '${meal!.ingredients.length}',
      ),
    ];

    return Row(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == items.length - 1 ? 0 : 8),
            child: RecipeInfoChip(
              icon: item.icon,
              label: item.label,
              value: item.value,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(
    ColorScheme colors,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 20, color: colors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
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
    );
  }

  Widget _buildIngredients(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        children: meal!.ingredients.asMap().entries.map((entry) {
          final isLast = entry.key == meal!.ingredients.length - 1;

          return Column(
            children: [
              IngredientItem(ingredient: entry.value),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Divider(
                    color: colors.outlineVariant.withValues(alpha: 0.35),
                    height: 1,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstructions(ColorScheme colors) {
    final steps = meal!.instructions
        .split(RegExp(r'\r?\n+'))
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();

    final finalSteps = steps.isEmpty ? [meal!.instructions] : steps;

    return Column(
      children: finalSteps.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InstructionStep(stepNumber: entry.key + 1, text: entry.value),
        );
      }).toList(),
    );
  }

  Widget _buildLinks(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          colors,
          'Sources',
          'More recipe details',
          Icons.link_rounded,
        ),
        const SizedBox(height: 14),
        if (meal!.youtubeUrl != null && meal!.youtubeUrl!.trim().isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _openUrl(meal!.youtubeUrl!);
              },
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Watch Preparation'),
            ),
          ),
        if (meal!.sourceUrl != null && meal!.sourceUrl!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _openUrl(meal!.sourceUrl!);
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Original Source'),
              ),
            ),
          ),
      ],
    );
  }
}
