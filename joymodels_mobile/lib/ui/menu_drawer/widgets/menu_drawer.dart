import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/ui/menu_drawer/view_model/menu_drawer_view_model.dart';
import 'package:joymodels_mobile/ui/core/ui/user_avatar.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  late final MenuDrawerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<MenuDrawerViewModel>();
    _viewModel.onLogoutSuccess = _handleLogoutSuccess;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  void _handleLogoutSuccess() {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePageScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MenuDrawerViewModel>();
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildUserHeader(viewModel, theme),
            const Divider(),
            _buildMenuItem(
              icon: Icons.library_books,
              label: 'Library',
              onTap: () => viewModel.navigateToLibrary(context),
            ),
            _buildMenuItem(
              icon: Icons.settings,
              label: 'Settings',
              onTap: () => viewModel.navigateToSettings(context),
            ),
            const Spacer(),
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            const Divider(),
            _buildLogoutButton(viewModel, theme),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(MenuDrawerViewModel viewModel, ThemeData theme) {
    return InkWell(
      onTap: () => viewModel.navigateToUserProfile(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (viewModel.userUuid != null)
              UserAvatar(
                imageUrl:
                    "${ApiConstants.baseUrl}/users/get/${viewModel.userUuid}/avatar",
                radius: 28,
              )
            else
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.surface,
                child: Icon(
                  Icons.person,
                  size: 28,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                viewModel.userName ?? 'User',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurface),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }

  Widget _buildLogoutButton(MenuDrawerViewModel viewModel, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: viewModel.isLoggingOut ? null : () => viewModel.logout(),
          icon: viewModel.isLoggingOut
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onError,
                    ),
                  ),
                )
              : const Icon(Icons.logout),
          label: Text(viewModel.isLoggingOut ? 'Logging out...' : 'Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
        ),
      ),
    );
  }
}
