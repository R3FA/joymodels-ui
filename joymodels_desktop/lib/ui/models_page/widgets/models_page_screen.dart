import 'package:flutter/material.dart';
import 'package:joymodels_desktop/ui/models_page/view_model/models_page_view_model.dart';
import 'package:provider/provider.dart';

class ModelsPageScreen extends StatefulWidget {
  final VoidCallback? onSessionExpired;
  final VoidCallback? onForbidden;

  const ModelsPageScreen({super.key, this.onSessionExpired, this.onForbidden});

  @override
  State<ModelsPageScreen> createState() => _ModelsPageScreenState();
}

class _ModelsPageScreenState extends State<ModelsPageScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ModelsPageViewModel>();
    viewModel.onSessionExpired = widget.onSessionExpired;
    viewModel.onForbidden = widget.onForbidden;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ModelsPageViewModel>();
    final theme = Theme.of(context);

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_in_ar,
            size: 80,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 24),
          Text(
            'Models Management',
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
