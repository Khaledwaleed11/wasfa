import 'package:flutter/material.dart';

class BuildLoading extends StatelessWidget {
  final int itemCount;
  final double childAspectRatio;

  const BuildLoading({
    super.key,
    this.itemCount = 6,
    this.childAspectRatio = 0.68,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (_, _) {
        return _LoadingCard(colors: colors);
      },
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final ColorScheme colors;

  const _LoadingCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              color: colors.surfaceContainerHigh,
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(width: double.infinity),
                  const SizedBox(height: 8),
                  _line(width: 85),
                  const Spacer(),
                  _line(width: 65),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line({required double width}) {
    return Container(
      width: width,
      height: 9,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
