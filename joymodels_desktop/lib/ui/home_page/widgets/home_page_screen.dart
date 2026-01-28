import 'package:flutter/material.dart';
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/ui/categories_page/view_model/categories_page_view_model.dart';
import 'package:joymodels_desktop/ui/categories_page/widgets/categories_page_screen.dart';
import 'package:joymodels_desktop/ui/community_page/view_model/community_page_view_model.dart';
import 'package:joymodels_desktop/ui/community_page/widgets/community_page_screen.dart';
import 'package:joymodels_desktop/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_desktop/ui/core/ui/error_display.dart';
import 'package:joymodels_desktop/ui/core/ui/loading_screen.dart';
import 'package:joymodels_desktop/ui/core/ui/user_avatar.dart';
import 'package:joymodels_desktop/ui/dashboard_page/view_model/dashboard_page_view_model.dart';
import 'package:joymodels_desktop/ui/dashboard_page/widgets/dashboard_page_screen.dart';
import 'package:joymodels_desktop/ui/home_page/view_model/home_page_view_model.dart';
import 'package:joymodels_desktop/ui/login_page/widgets/login_page_screen.dart';
import 'package:joymodels_desktop/ui/models_page/view_model/models_page_view_model.dart';
import 'package:joymodels_desktop/ui/models_page/widgets/models_page_screen.dart';
import 'package:joymodels_desktop/ui/reports_page/view_model/reports_page_view_model.dart';
import 'package:joymodels_desktop/ui/reports_page/widgets/reports_page_screen.dart';
import 'package:joymodels_desktop/ui/settings_page/view_model/settings_page_view_model.dart';
import 'package:joymodels_desktop/ui/settings_page/widgets/settings_page_screen.dart';
import 'package:joymodels_desktop/ui/users_page/view_model/users_page_view_model.dart';
import 'package:joymodels_desktop/ui/users_page/widgets/users_page_screen.dart';
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

  void _handleForbidden() async {
    if (!mounted) return;

    await TokenStorage.clearAuthToken();

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
          _buildSidebar(context, viewModel, theme),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, viewModel, theme),
                if (viewModel.errorMessage != null)
                  ErrorDisplay(
                    message: viewModel.errorMessage!,
                    onDismiss: () => viewModel.clearErrorMessage(),
                  ),
                Expanded(child: _buildContent(viewModel)),
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

  Widget _buildContent(HomePageScreenViewModel viewModel) {
    switch (viewModel.selectedIndex) {
      case 0:
        return ChangeNotifierProvider(
          create: (_) => DashboardPageViewModel(),
          child: DashboardPageScreen(
            onSessionExpired: _handleSessionExpired,
            onForbidden: _handleForbidden,
            onNavigateToUsers: (tabIndex) =>
                viewModel.navigateToUsers(tabIndex: tabIndex),
          ),
        );
      case 1:
        return ChangeNotifierProvider(
          create: (_) => UsersPageViewModel(),
          child: UsersPageScreen(
            onSessionExpired: _handleSessionExpired,
            onForbidden: _handleForbidden,
            initialTabIndex: viewModel.usersInitialTabIndex,
          ),
        );
      case 2:
        return ChangeNotifierProvider(
          create: (_) => ModelsPageViewModel(),
          child: ModelsPageScreen(
            onSessionExpired: _handleSessionExpired,
            onForbidden: _handleForbidden,
          ),
        );
      case 3:
        return ChangeNotifierProvider(
          create: (_) => CategoriesPageViewModel(),
          child: CategoriesPageScreen(
            onSessionExpired: _handleSessionExpired,
            onForbidden: _handleForbidden,
          ),
        );
      case 4:
        return ChangeNotifierProvider(
          create: (_) => CommunityPageViewModel(),
          child: CommunityPageScreen(
            onSessionExpired: _handleSessionExpired,
            onForbidden: _handleForbidden,
          ),
        );
      case 5:
        return ChangeNotifierProvider(
          create: (_) => ReportsPageViewModel(),
          child: ReportsPageScreen(
            onSessionExpired: _handleSessionExpired,
            onForbidden: _handleForbidden,
          ),
        );
      case 6:
        return ChangeNotifierProvider(
          create: (_) => SettingsPageViewModel(),
          child: SettingsPageScreen(
            onSessionExpired: _handleSessionExpired,
            onForbidden: _handleForbidden,
          ),
        );
      default:
        return ChangeNotifierProvider(
          create: (_) => DashboardPageViewModel(),
          child: DashboardPageScreen(
            onSessionExpired: _handleSessionExpired,
            onForbidden: _handleForbidden,
          ),
        );
    }
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
