import 'dart:async';

import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_mobile/ui/core/ui/pagination_controls.dart';
import 'package:joymodels_mobile/ui/menu_drawer/view_model/menu_drawer_view_model.dart';
import 'package:joymodels_mobile/ui/core/ui/user_avatar.dart';
import 'package:joymodels_mobile/ui/user_profile_page/widgets/user_profile_page_screen.dart';
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

  void _showSearchUsersModal() {
    final viewModel = context.read<MenuDrawerViewModel>();
    viewModel.resetSearchState();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return _SearchUsersModalContent(
          viewModel: viewModel,
          onUserTap: (userUuid) {
            Navigator.of(modalContext).pop();
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => UserProfilePageScreen(userUuid: userUuid),
              ),
            );
          },
        );
      },
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
              icon: Icons.search,
              label: 'Search Users',
              onTap: _showSearchUsersModal,
            ),
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

class _SearchUsersModalContent extends StatefulWidget {
  final MenuDrawerViewModel viewModel;
  final void Function(String userUuid) onUserTap;

  const _SearchUsersModalContent({
    required this.viewModel,
    required this.onUserTap,
  });

  @override
  State<_SearchUsersModalContent> createState() =>
      _SearchUsersModalContentState();
}

class _SearchUsersModalContentState extends State<_SearchUsersModalContent> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.viewModel.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(theme),
          _buildHeader(theme),
          _buildSearchBar(theme),
          Expanded(child: _buildUserList(theme)),
        ],
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Search Users',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: widget.viewModel.searchController,
        onChanged: _onSearchChanged,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search by nickname...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: widget.viewModel.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.viewModel.searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(ThemeData theme) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isSearching) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.viewModel.searchErrorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.viewModel.searchErrorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (widget.viewModel.searchQuery.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Start typing to search users',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        final users = widget.viewModel.items;

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No users found',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return _buildUserTile(users[index], theme);
                },
              ),
            ),
            PaginationControls(
              currentPage: widget.viewModel.currentPage,
              totalPages: widget.viewModel.totalPages,
              hasPreviousPage: widget.viewModel.hasPreviousPage,
              hasNextPage: widget.viewModel.hasNextPage,
              onPreviousPage: widget.viewModel.onPreviousPage,
              onNextPage: widget.viewModel.onNextPage,
              isLoading: widget.viewModel.isSearching,
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserTile(UsersResponseApiModel user, ThemeData theme) {
    return ListTile(
      onTap: () => widget.onUserTap(user.uuid),
      leading: UserAvatar(
        imageUrl: "${ApiConstants.baseUrl}/users/get/${user.uuid}/avatar",
        radius: 24,
      ),
      title: Text(
        user.nickName,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${user.firstName} ${user.lastName ?? ''}'.trim(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
