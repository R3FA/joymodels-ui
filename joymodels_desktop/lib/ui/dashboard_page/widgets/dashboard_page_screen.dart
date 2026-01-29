import 'package:flutter/material.dart';
import 'package:joymodels_desktop/ui/dashboard_page/view_model/dashboard_page_view_model.dart';
import 'package:provider/provider.dart';

class DashboardPageScreen extends StatefulWidget {
  final VoidCallback? onSessionExpired;
  final VoidCallback? onForbidden;
  final VoidCallback? onNetworkError;
  final void Function(int tabIndex)? onNavigateToUsers;

  const DashboardPageScreen({
    super.key,
    this.onSessionExpired,
    this.onForbidden,
    this.onNetworkError,
    this.onNavigateToUsers,
  });

  @override
  State<DashboardPageScreen> createState() => _DashboardPageScreenState();
}

class _DashboardPageScreenState extends State<DashboardPageScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<DashboardPageViewModel>();
    viewModel.onSessionExpired = widget.onSessionExpired;
    viewModel.onForbidden = widget.onForbidden;
    viewModel.onNetworkError = widget.onNetworkError;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardPageViewModel>();
    final theme = Theme.of(context);

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int crossAxisCount;
        if (width >= 1100) {
          crossAxisCount = 4;
        } else if (width >= 700) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        final cards = [
          _buildStatCard(
            theme,
            icon: Icons.verified_user,
            label: 'Verified Users',
            value: viewModel.totalVerifiedUsers.toString(),
            color: Colors.blue,
            onTap: () => widget.onNavigateToUsers?.call(0),
          ),
          _buildStatCard(
            theme,
            icon: Icons.person_outline,
            label: 'Unverified Users',
            value: viewModel.totalUnverifiedUsers.toString(),
            color: Colors.orange,
            onTap: () => widget.onNavigateToUsers?.call(1),
          ),
          _buildStatCard(
            theme,
            icon: Icons.category,
            label: 'Categories',
            value: viewModel.totalCategories.toString(),
            color: Colors.teal,
          ),
          _buildStatCard(
            theme,
            icon: Icons.report,
            label: 'Reports',
            value: viewModel.totalReports.toString(),
            color: Colors.red,
          ),
          _buildStatCard(
            theme,
            icon: Icons.shopping_cart,
            label: 'Orders',
            value: viewModel.totalOrders.toString(),
            color: Colors.green,
          ),
        ];

        final spacing = 20.0;
        final cardWidth =
            (width - spacing * (crossAxisCount - 1)) / crossAxisCount;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: cards
                    .map((card) => SizedBox(width: cardWidth, child: card))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
