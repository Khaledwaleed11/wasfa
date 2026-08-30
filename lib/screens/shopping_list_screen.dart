import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/shopping_item_model.dart';
import '../services/shopping_list_service.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen>
    with SingleTickerProviderStateMixin {
  static const String _boxName = ShoppingListService.boxName;

  late AnimationController _pageController;
  late Animation<double> _fadeAnimation;

  late Box _shoppingBox;

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

    _shoppingBox = Hive.box(_boxName);

    _pageController.forward();
  }

  Future<void> toggleItem(ShoppingItemModel item) async {
    await ShoppingListService.toggleItem(item);
  }

  Future<void> removeItem(ShoppingItemModel item) async {
    await ShoppingListService.removeItem(item.id);
  }

  Future<void> clearList() async {
    if (_shoppingBox.isEmpty) {
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
            'Clear Shopping List',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Do you want to remove all items from your shopping list?',
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

    await ShoppingListService.clearItems();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shopping list cleared'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1200),
      ),
    );
  }

  List<ShoppingItemModel> _parseItems(Box box) {
    final items = <ShoppingItemModel>[];

    for (final value in box.values) {
      if (value is! Map) {
        continue;
      }

      try {
        items.add(
          ShoppingItemModel.fromJson(Map<dynamic, dynamic>.from(value)),
        );
      } catch (_) {}
    }

    return items;
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
        title: const Text(
          'Shopping List',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<Box>(
            valueListenable: _shoppingBox.listenable(),
            builder: (context, box, _) {
              if (box.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                onPressed: clearList,
                tooltip: 'Clear All',
                icon: const Icon(Icons.delete_sweep_outlined),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ValueListenableBuilder<Box>(
        valueListenable: _shoppingBox.listenable(),
        builder: (context, box, _) {
          final items = _parseItems(box);

          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildBody(context, colors, items),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ColorScheme colors,
    List<ShoppingItemModel> items,
  ) {
    if (items.isEmpty) {
      return _buildEmpty(colors);
    }

    final completedCount = items.where((item) => item.isCompleted).length;

    final remainingCount = items.length - completedCount;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          sliver: SliverToBoxAdapter(
            child: _buildHeader(
              colors,
              items.length,
              completedCount,
              remainingCount,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          sliver: SliverToBoxAdapter(
            child: _buildProgress(colors, items.length, completedCount),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = items[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ShoppingItemCard(
                  item: item,
                  onToggle: () => toggleItem(item),
                  onDelete: () => removeItem(item),
                ),
              );
            }, childCount: items.length),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    ColorScheme colors,
    int total,
    int completed,
    int remaining,
  ) {
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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_rounded,
              size: 27,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ready to Cook?',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Shopping List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  remaining == 0
                      ? 'Everything is purchased 🎉'
                      : '$remaining items remaining out of $total',
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

  Widget _buildProgress(ColorScheme colors, int total, int completed) {
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '$completed / $total',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: colors.primary.withValues(alpha: 0.08),
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 45,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Shopping List is Empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add ingredients from your recipes and they will appear here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingItemCard extends StatelessWidget {
  final ShoppingItemModel item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ShoppingItemCard({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: item.isCompleted ? colors.surfaceContainerLow : colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isCompleted
              ? colors.outlineVariant
              : colors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: item.isCompleted
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.025),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        leading: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.isCompleted
                  ? colors.primary
                  : colors.primary.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.isCompleted
                  ? Icons.check_rounded
                  : Icons.shopping_basket_outlined,
              size: 20,
              color: item.isCompleted ? colors.onPrimary : colors.primary,
            ),
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: item.isCompleted
                ? colors.onSurfaceVariant
                : colors.onSurface,
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: item.quantity.trim().isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  item.quantity,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
        trailing: IconButton(
          onPressed: onDelete,
          tooltip: 'Delete',
          icon: Icon(
            Icons.delete_outline_rounded,
            size: 20,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
