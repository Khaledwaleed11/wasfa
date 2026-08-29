import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final bool showSearchButton;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    required this.onClear,
    this.onChanged,
    this.hintText = 'Search for a recipe...',
    this.showSearchButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textDirection: TextDirection.ltr,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: (_) => onSearch(),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search_rounded, color: colors.primary),
          suffixIcon: controller.text.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                    ),
                    if (showSearchButton) _buildSearchButton(colors),
                  ],
                )
              : showSearchButton
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildSearchButton(colors),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSearchButton(ColorScheme colors) {
    return Material(
      color: colors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onSearch,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 38,
          height: 38,
          child: Icon(Icons.search_rounded, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}
