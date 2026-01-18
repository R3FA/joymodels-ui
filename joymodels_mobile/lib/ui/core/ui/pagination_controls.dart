import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final bool isLoading;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
    this.onPreviousPage,
    this.onNextPage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: hasPreviousPage && !isLoading ? onPreviousPage : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous',
            disabledColor: theme.disabledColor,
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Text(
              '$currentPage / $totalPages',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: hasNextPage && !isLoading ? onNextPage : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next',
            disabledColor: theme.disabledColor,
          ),
        ],
      ),
    );
  }
}
