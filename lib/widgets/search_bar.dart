import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
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
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);

      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textDirection: TextDirection.ltr,
        textInputAction: TextInputAction.search,
        onChanged: widget.onChanged,
        onSubmitted: (_) => widget.onSearch(),
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Icon(Icons.search_rounded, color: colors.primary),
          suffixIcon: _buildSuffixContent(colors),
        ),
      ),
    );
  }

  Widget? _buildSuffixContent(ColorScheme colors) {
    final hasText = widget.controller.text.isNotEmpty;

    if (!hasText && !widget.showSearchButton) {
      return null;
    }

    if (!widget.showSearchButton) {
      return IconButton(
        onPressed: widget.onClear,
        icon: const Icon(Icons.close_rounded),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 6, left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasText)
            IconButton(
              onPressed: widget.onClear,
              icon: const Icon(Icons.close_rounded),
            ),
          _buildSearchButton(colors),
        ],
      ),
    );
  }

  Widget _buildSearchButton(ColorScheme colors) {
    return Material(
      color: colors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: widget.onSearch,
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
