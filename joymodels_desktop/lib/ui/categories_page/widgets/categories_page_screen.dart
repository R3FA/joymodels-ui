import 'package:flutter/material.dart';
import 'package:joymodels_desktop/ui/categories_page/view_model/categories_page_view_model.dart';
import 'package:provider/provider.dart';

class CategoriesPageScreen extends StatefulWidget {
  final VoidCallback? onSessionExpired;
  final VoidCallback? onForbidden;
  final VoidCallback? onNetworkError;

  const CategoriesPageScreen({
    super.key,
    this.onSessionExpired,
    this.onForbidden,
    this.onNetworkError,
  });

  @override
  State<CategoriesPageScreen> createState() => _CategoriesPageScreenState();
}

class _CategoriesPageScreenState extends State<CategoriesPageScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<CategoriesPageViewModel>();
    viewModel.onSessionExpired = widget.onSessionExpired;
    viewModel.onForbidden = widget.onForbidden;
    viewModel.onNetworkError = widget.onNetworkError;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CategoriesPageViewModel>();
    final theme = Theme.of(context);

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category,
            size: 80,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 24),
          Text(
            'Categories Management',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
