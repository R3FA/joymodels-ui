import 'dart:async';

import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/enums/report_reason_api_enum.dart';
import 'package:joymodels_mobile/data/model/enums/report_status_api_enum.dart';
import 'package:joymodels_mobile/data/model/enums/reported_entity_type_api_enum.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/model/report/response_types/report_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_mobile/ui/core/ui/model_image.dart';
import 'package:joymodels_mobile/ui/core/ui/pagination_controls.dart';
import 'package:joymodels_mobile/ui/menu_drawer/view_model/menu_drawer_view_model.dart';
import 'package:joymodels_mobile/ui/core/ui/user_avatar.dart';
import 'package:joymodels_mobile/ui/model_page/view_model/model_page_view_model.dart';
import 'package:joymodels_mobile/ui/model_page/widgets/model_page_screen.dart';
import 'package:joymodels_mobile/ui/my_reports/view_model/my_reports_view_model.dart';
import 'package:joymodels_mobile/ui/user_profile_page/view_model/user_profile_page_view_model.dart';
import 'package:joymodels_mobile/ui/user_profile_page/widgets/user_profile_page_screen.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

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
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => UserProfilePageViewModel()..init(userUuid),
                  child: UserProfilePageScreen(userUuid: userUuid),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMyReportsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return ChangeNotifierProvider(
          create: (_) => MyReportsViewModel()..init(),
          child: const _MyReportsModalContent(),
        );
      },
    );
  }

  void _showHiddenModelsModal() {
    final viewModel = context.read<MenuDrawerViewModel>();
    viewModel.resetHiddenModelsState();
    viewModel.searchHiddenModels(1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return _HiddenModelsModalContent(
          viewModel: viewModel,
          onModelTap: (model) {
            Navigator.of(modalContext).pop();
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => ModelPageViewModel(),
                  child: ModelPageScreen(loadedModel: model),
                ),
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
            if (!viewModel.isAdminOrRoot)
              _buildMenuItem(
                icon: Icons.library_books,
                label: 'Library',
                onTap: () => viewModel.navigateToLibrary(context),
              ),
            _buildMenuItem(
              icon: Icons.flag_outlined,
              label: 'My Reports',
              onTap: _showMyReportsModal,
            ),
            if (viewModel.isAdminOrRoot)
              _buildMenuItem(
                icon: Icons.visibility_off,
                label: 'Hidden Models',
                onTap: _showHiddenModelsModal,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => widget.onUserTap(user.uuid),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: UserAvatar(
                  imageUrl:
                      "${ApiConstants.baseUrl}/users/get/${user.uuid}/avatar",
                  radius: 32,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nickName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.firstName} ${user.lastName ?? ''}'.trim(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.chevron_right,
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

class _MyReportsModalContent extends StatelessWidget {
  const _MyReportsModalContent();

  void _showDeleteConfirmation(
    BuildContext context,
    MyReportsViewModel viewModel,
    ReportResponseApiModel report,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              viewModel.deleteReport(context, report.uuid);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<MyReportsViewModel>();

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
          Expanded(child: _buildReportsList(context, viewModel, theme)),
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
        'My Reports',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReportsList(
    BuildContext context,
    MyReportsViewModel viewModel,
    ThemeData theme,
  ) {
    if (viewModel.isLoading && viewModel.reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadReports(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No reports yet',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: viewModel.reports.length,
                itemBuilder: (context, index) {
                  return _buildReportTile(
                    context,
                    viewModel,
                    viewModel.reports[index],
                    theme,
                  );
                },
              ),
            ),
            PaginationControls(
              currentPage: viewModel.currentPage,
              totalPages: viewModel.totalPages,
              hasPreviousPage: viewModel.hasPreviousPage,
              hasNextPage: viewModel.hasNextPage,
              onPreviousPage: viewModel.onPreviousPage,
              onNextPage: viewModel.onNextPage,
              isLoading: viewModel.isLoading,
            ),
          ],
        ),
        if (viewModel.isDeleting)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildReportTile(
    BuildContext context,
    MyReportsViewModel viewModel,
    ReportResponseApiModel report,
    ThemeData theme,
  ) {
    final entityType = ReportedEntityTypeApiEnum.fromApiString(
      report.reportedEntityType,
    );
    final reason = ReportReasonApiEnum.fromApiString(report.reason);
    final status = ReportStatusApiEnum.fromApiString(report.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getEntityIcon(entityType),
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getEntityTypeLabel(entityType),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatusChip(status, theme),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(context, viewModel, report);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: theme.colorScheme.error),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.label_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  reason.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (report.getPreviewText() != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.getPreviewText()!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
            if (report.description != null &&
                report.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                report.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              timeago.format(report.createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ReportStatusApiEnum status, ThemeData theme) {
    Color color;
    switch (status) {
      case ReportStatusApiEnum.pending:
        color = Colors.orange;
        break;
      case ReportStatusApiEnum.reviewed:
        color = Colors.blue;
        break;
      case ReportStatusApiEnum.resolved:
        color = Colors.green;
        break;
      case ReportStatusApiEnum.dismissed:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toApiString(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getEntityIcon(ReportedEntityTypeApiEnum entityType) {
    switch (entityType) {
      case ReportedEntityTypeApiEnum.user:
        return Icons.person;
      case ReportedEntityTypeApiEnum.communityPost:
        return Icons.article;
      case ReportedEntityTypeApiEnum.communityPostComment:
        return Icons.comment;
      case ReportedEntityTypeApiEnum.modelReview:
        return Icons.star;
      case ReportedEntityTypeApiEnum.modelFaqQuestion:
        return Icons.help_outline;
    }
  }

  String _getEntityTypeLabel(ReportedEntityTypeApiEnum entityType) {
    switch (entityType) {
      case ReportedEntityTypeApiEnum.user:
        return 'User';
      case ReportedEntityTypeApiEnum.communityPost:
        return 'Community Post';
      case ReportedEntityTypeApiEnum.communityPostComment:
        return 'Comment';
      case ReportedEntityTypeApiEnum.modelReview:
        return 'Model Review';
      case ReportedEntityTypeApiEnum.modelFaqQuestion:
        return 'FAQ Question';
    }
  }
}

class _HiddenModelsModalContent extends StatefulWidget {
  final MenuDrawerViewModel viewModel;
  final void Function(ModelResponseApiModel model) onModelTap;

  const _HiddenModelsModalContent({
    required this.viewModel,
    required this.onModelTap,
  });

  @override
  State<_HiddenModelsModalContent> createState() =>
      _HiddenModelsModalContentState();
}

class _HiddenModelsModalContentState extends State<_HiddenModelsModalContent> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.viewModel.onHiddenModelsSearchChanged(query);
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
          Expanded(child: _buildModelList(theme)),
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
        'Hidden Models',
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
        controller: widget.viewModel.hiddenModelsSearchController,
        onChanged: _onSearchChanged,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search by model name...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: widget.viewModel.hiddenModelsSearchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.viewModel.hiddenModelsSearchController.clear();
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

  Widget _buildModelList(ThemeData theme) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isHiddenModelsSearching) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.viewModel.hiddenModelsErrorMessage != null) {
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
                    widget.viewModel.hiddenModelsErrorMessage!,
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

        final models = widget.viewModel.hiddenModelsResults?.data ?? [];

        if (models.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.visibility_off,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hidden models found',
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
                itemCount: models.length,
                itemBuilder: (context, index) {
                  return _buildModelTile(models[index], theme);
                },
              ),
            ),
            PaginationControls(
              currentPage: widget.viewModel.hiddenModelsCurrentPage,
              totalPages: widget.viewModel.hiddenModelsTotalPages,
              hasPreviousPage: widget.viewModel.hiddenModelsHasPreviousPage,
              hasNextPage: widget.viewModel.hiddenModelsHasNextPage,
              onPreviousPage: widget.viewModel.onHiddenModelsPreviousPage,
              onNextPage: widget.viewModel.onHiddenModelsNextPage,
              isLoading: widget.viewModel.isHiddenModelsSearching,
            ),
          ],
        );
      },
    );
  }

  Widget _buildModelTile(ModelResponseApiModel model, ThemeData theme) {
    final categoryName = model.modelCategories.isNotEmpty
        ? model.modelCategories.first.categoryName
        : 'No category';
    final hasImage = model.modelPictures.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => widget.onModelTap(model),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: hasImage
                      ? ModelImage(
                          imageUrl:
                              "${ApiConstants.baseUrl}/models/get/${model.uuid}/images/${Uri.encodeComponent(model.modelPictures[0].pictureLocation)}",
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.smart_toy,
                            size: 32,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoryName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.chevron_right,
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
