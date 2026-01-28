import 'package:flutter/material.dart';
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_desktop/ui/core/ui/loading_screen.dart';
import 'package:joymodels_desktop/ui/core/ui/user_avatar.dart';
import 'package:joymodels_desktop/ui/home_page/view_model/home_page_view_model.dart';
import 'package:joymodels_desktop/ui/login_page/widgets/login_page_screen.dart';
import 'package:provider/provider.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late final HomePageScreenViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<HomePageScreenViewModel>();
    _viewModel.onLogoutSuccess = _handleLogoutSuccess;
    _viewModel.onSessionExpired = _handleSessionExpired;
    _viewModel.onForbidden = _handleForbidden;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  void _handleLogoutSuccess() {
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPageScreen()),
        (route) => false,
      );
    }
  }

  void _handleSessionExpired() async {
    if (!mounted) return;

    await TokenStorage.clearAuthToken();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPageScreen()),
      (route) => false,
    );
  }

  void _handleForbidden() {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AccessDeniedScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomePageScreenViewModel>();
    final theme = Theme.of(context);

    if (viewModel.isLoading) {
      return const LoadingScreen(message: 'Loading...');
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(context, viewModel, theme),
          // Main content
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, viewModel, theme),
                Expanded(child: _buildContent(viewModel, theme)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    HomePageScreenViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.view_in_ar,
                    size: 24,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'JoyModels',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Navigation items
          _buildNavItem(
            context,
            viewModel,
            theme,
            index: 0,
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            label: 'Dashboard',
          ),
          _buildNavItem(
            context,
            viewModel,
            theme,
            index: 1,
            icon: Icons.people_outline,
            selectedIcon: Icons.people,
            label: 'Users',
          ),
          _buildNavItem(
            context,
            viewModel,
            theme,
            index: 2,
            icon: Icons.view_in_ar_outlined,
            selectedIcon: Icons.view_in_ar,
            label: 'Models',
          ),
          _buildNavItem(
            context,
            viewModel,
            theme,
            index: 3,
            icon: Icons.category_outlined,
            selectedIcon: Icons.category,
            label: 'Categories',
          ),
          _buildNavItem(
            context,
            viewModel,
            theme,
            index: 4,
            icon: Icons.forum_outlined,
            selectedIcon: Icons.forum,
            label: 'Community',
          ),
          _buildNavItem(
            context,
            viewModel,
            theme,
            index: 5,
            icon: Icons.report_outlined,
            selectedIcon: Icons.report,
            label: 'Reports',
          ),
          const Spacer(),
          // Settings & Logout
          _buildNavItem(
            context,
            viewModel,
            theme,
            index: 6,
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text(
                'Logout',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () => _showLogoutDialog(context, viewModel),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    HomePageScreenViewModel viewModel,
    ThemeData theme, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = viewModel.selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ListTile(
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primaryContainer.withValues(
          alpha: 0.4,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => viewModel.setSelectedIndex(index),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    HomePageScreenViewModel viewModel,
    ThemeData theme,
  ) {
    final titles = [
      'Dashboard',
      'Users',
      'Models',
      'Categories',
      'Community',
      'Reports',
      'Settings',
    ];

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            titles[viewModel.selectedIndex],
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // User info
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  UserAvatar(
                    imageUrl:
                        "${ApiConstants.baseUrl}/users/get/${viewModel.userUuid}/avatar",
                    radius: 16,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    viewModel.currentUserName!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(HomePageScreenViewModel viewModel, ThemeData theme) {
    switch (viewModel.selectedIndex) {
      case 0:
        return _buildDashboardContent(theme);
      case 1:
        return _buildPlaceholderContent(theme, 'Users', Icons.people);
      case 2:
        return _buildPlaceholderContent(theme, 'Models', Icons.view_in_ar);
      case 3:
        return _buildPlaceholderContent(theme, 'Categories', Icons.category);
      case 4:
        return _buildPlaceholderContent(theme, 'Community', Icons.forum);
      case 5:
        return _buildPlaceholderContent(theme, 'Reports', Icons.report);
      case 6:
        return _buildPlaceholderContent(theme, 'Settings', Icons.settings);
      default:
        return _buildDashboardContent(theme);
    }
  }

  Widget _buildDashboardContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  icon: Icons.people,
                  label: 'Total Users',
                  value: '0',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildStatCard(
                  theme,
                  icon: Icons.view_in_ar,
                  label: 'Total Models',
                  value: '0',
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildStatCard(
                  theme,
                  icon: Icons.shopping_cart,
                  label: 'Total Orders',
                  value: '0',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildStatCard(
                  theme,
                  icon: Icons.report,
                  label: 'Pending Reports',
                  value: '0',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildQuickAction(
                theme,
                icon: Icons.person_add,
                label: 'Add User',
                onTap: () {},
              ),
              const SizedBox(width: 16),
              _buildQuickAction(
                theme,
                icon: Icons.add_box,
                label: 'Add Category',
                onTap: () {},
              ),
              const SizedBox(width: 16),
              _buildQuickAction(
                theme,
                icon: Icons.flag,
                label: 'Review Reports',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
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
    );
  }

  Widget _buildQuickAction(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderContent(
    ThemeData theme,
    String title,
    IconData icon,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 24),
          Text(
            '$title Management',
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

  void _showLogoutDialog(
    BuildContext context,
    HomePageScreenViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
