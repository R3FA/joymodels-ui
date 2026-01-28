import 'dart:async';

import 'package:flutter/material.dart';
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/model/sso/response_types/sso_user_response_api_model.dart';
import 'package:joymodels_desktop/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_desktop/ui/core/ui/error_display.dart';
import 'package:joymodels_desktop/ui/core/ui/pagination_controls.dart';
import 'package:joymodels_desktop/ui/core/ui/user_avatar.dart';
import 'package:joymodels_desktop/ui/users_page/view_model/users_page_view_model.dart';
import 'package:provider/provider.dart';

class UsersPageScreen extends StatefulWidget {
  final VoidCallback? onSessionExpired;
  final VoidCallback? onForbidden;
  final int initialTabIndex;

  const UsersPageScreen({
    super.key,
    this.onSessionExpired,
    this.onForbidden,
    this.initialTabIndex = 0,
  });

  @override
  State<UsersPageScreen> createState() => _UsersPageScreenState();
}

class _UsersPageScreenState extends State<UsersPageScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _verifiedSearchController;
  late final TextEditingController _unverifiedNicknameController;
  late final TextEditingController _unverifiedEmailController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    final viewModel = context.read<UsersPageViewModel>();

    _verifiedSearchController = TextEditingController(
      text: viewModel.verifiedSearchQuery,
    );
    _unverifiedNicknameController = TextEditingController(
      text: viewModel.unverifiedSearchNickname,
    );
    _unverifiedEmailController = TextEditingController(
      text: viewModel.unverifiedSearchEmail,
    );

    viewModel.onSessionExpired = widget.onSessionExpired;
    viewModel.onForbidden = widget.onForbidden;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.init();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _verifiedSearchController.dispose();
    _unverifiedNicknameController.dispose();
    _unverifiedEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UsersPageViewModel>();
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text:
                    'Verified Users (${viewModel.verifiedPagination?.totalRecords ?? 0})',
              ),
              Tab(
                text:
                    'Unverified Users (${viewModel.unverifiedPagination?.totalRecords ?? 0})',
              ),
            ],
          ),
        ),
        if (viewModel.errorMessage != null)
          ErrorDisplay(
            message: viewModel.errorMessage!,
            onDismiss: () => viewModel.clearErrorMessage(),
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildVerifiedUsersTab(viewModel, theme),
              _buildUnverifiedUsersTab(viewModel, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerifiedUsersTab(UsersPageViewModel viewModel, ThemeData theme) {
    final pagination = viewModel.verifiedPagination;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _verifiedSearchController,
            decoration: InputDecoration(
              hintText: 'Search by nickname...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
              errorText: viewModel.verifiedSearchError,
            ),
            onChanged: (value) {
              viewModel.setVerifiedSearchQuery(value);
              _debounce?.cancel();
              if (viewModel.verifiedSearchError == null) {
                _debounce = Timer(const Duration(milliseconds: 400), () {
                  viewModel.searchVerifiedUsers();
                });
              }
            },
          ),
        ),
        Expanded(
          child: viewModel.isLoadingVerified
              ? const Center(child: CircularProgressIndicator())
              : (pagination == null || pagination.data.isEmpty)
              ? Center(
                  child: Text(
                    'No verified users found.',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : _buildVerifiedDataTable(pagination.data, viewModel, theme),
        ),
        if (pagination != null)
          PaginationControls(
            currentPage: pagination.pageNumber,
            totalPages: pagination.totalPages,
            totalRecords: pagination.totalRecords,
            hasPreviousPage: pagination.hasPreviousPage,
            hasNextPage: pagination.hasNextPage,
            isLoading: viewModel.isLoadingVerified,
            onPreviousPage: () =>
                viewModel.searchVerifiedUsers(page: pagination.pageNumber - 1),
            onNextPage: () =>
                viewModel.searchVerifiedUsers(page: pagination.pageNumber + 1),
          ),
      ],
    );
  }

  Widget _buildVerifiedDataTable(
    List<UsersResponseApiModel> users,
    UsersPageViewModel viewModel,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Avatar')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Nickname')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Models')),
            DataColumn(label: Text('Followers')),
            DataColumn(label: Text('Created')),
            DataColumn(label: Text('Actions')),
          ],
          rows: users
              .map((user) => _buildVerifiedUserRow(user, viewModel, theme))
              .toList(),
        ),
      ),
    );
  }

  DataRow _buildVerifiedUserRow(
    UsersResponseApiModel user,
    UsersPageViewModel viewModel,
    ThemeData theme,
  ) {
    return DataRow(
      cells: [
        DataCell(
          UserAvatar(
            imageUrl: '${ApiConstants.baseUrl}/users/get/${user.uuid}/avatar',
            radius: 16,
          ),
        ),
        DataCell(Text('${user.firstName} ${user.lastName ?? ''}'.trim())),
        DataCell(Text(user.nickName)),
        DataCell(Text(user.email)),
        DataCell(_buildRoleChip(user.userRole.roleName, theme)),
        DataCell(Text(user.userModelsCount.toString())),
        DataCell(Text(user.userFollowerCount.toString())),
        DataCell(Text(_formatDate(user.createdAt))),
        DataCell(
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            tooltip: 'Delete',
            onPressed: () => _showDeleteDialog(
              context,
              viewModel,
              user.uuid,
              user.nickName,
              isSso: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnverifiedUsersTab(
    UsersPageViewModel viewModel,
    ThemeData theme,
  ) {
    final pagination = viewModel.unverifiedPagination;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _unverifiedNicknameController,
                  decoration: InputDecoration(
                    hintText: 'Search by nickname...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                    errorText: viewModel.unverifiedNicknameError,
                  ),
                  onChanged: (value) {
                    viewModel.setUnverifiedSearchNickname(value);
                    _debounce?.cancel();
                    if (viewModel.unverifiedNicknameError == null) {
                      _debounce = Timer(const Duration(milliseconds: 400), () {
                        viewModel.searchUnverifiedUsers();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _unverifiedEmailController,
                  decoration: InputDecoration(
                    hintText: 'Search by email...',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                    errorText: viewModel.unverifiedEmailError,
                  ),
                  onChanged: (value) {
                    viewModel.setUnverifiedSearchEmail(value);
                    _debounce?.cancel();
                    if (viewModel.unverifiedEmailError == null) {
                      _debounce = Timer(const Duration(milliseconds: 400), () {
                        viewModel.searchUnverifiedUsers();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: viewModel.isLoadingUnverified
              ? const Center(child: CircularProgressIndicator())
              : (pagination == null || pagination.data.isEmpty)
              ? Center(
                  child: Text(
                    'No unverified users found.',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : _buildUnverifiedDataTable(pagination.data, viewModel, theme),
        ),
        if (pagination != null)
          PaginationControls(
            currentPage: pagination.pageNumber,
            totalPages: pagination.totalPages,
            totalRecords: pagination.totalRecords,
            hasPreviousPage: pagination.hasPreviousPage,
            hasNextPage: pagination.hasNextPage,
            isLoading: viewModel.isLoadingUnverified,
            onPreviousPage: () => viewModel.searchUnverifiedUsers(
              page: pagination.pageNumber - 1,
            ),
            onNextPage: () => viewModel.searchUnverifiedUsers(
              page: pagination.pageNumber + 1,
            ),
          ),
      ],
    );
  }

  Widget _buildUnverifiedDataTable(
    List<SsoUserResponseApiModel> users,
    UsersPageViewModel viewModel,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Avatar')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Nickname')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Created')),
            DataColumn(label: Text('Actions')),
          ],
          rows: users
              .map((user) => _buildUnverifiedUserRow(user, viewModel, theme))
              .toList(),
        ),
      ),
    );
  }

  DataRow _buildUnverifiedUserRow(
    SsoUserResponseApiModel user,
    UsersPageViewModel viewModel,
    ThemeData theme,
  ) {
    return DataRow(
      cells: [
        DataCell(
          UserAvatar(
            imageUrl: '${ApiConstants.baseUrl}/users/get/${user.uuid}/avatar',
            radius: 16,
          ),
        ),
        DataCell(Text('${user.firstName} ${user.lastName ?? ''}'.trim())),
        DataCell(Text(user.nickName)),
        DataCell(Text(user.email)),
        DataCell(_buildRoleChip(user.userRole.roleName, theme)),
        DataCell(Text(_formatDate(user.createdAt))),
        DataCell(
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            tooltip: 'Delete',
            onPressed: () => _showDeleteDialog(
              context,
              viewModel,
              user.uuid,
              user.nickName,
              isSso: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleChip(String roleName, ThemeData theme) {
    final Color chipColor;
    switch (roleName.toLowerCase()) {
      case 'root':
        chipColor = Colors.red;
      case 'headstaff':
        chipColor = Colors.orange;
      case 'staff':
        chipColor = Colors.blue;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        roleName,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  void _showDeleteDialog(
    BuildContext ctx,
    UsersPageViewModel viewModel,
    String uuid,
    String nickname, {
    required bool isSso,
  }) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete "$nickname"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (isSso) {
                viewModel.deleteUnverifiedUser(uuid);
              } else {
                viewModel.deleteVerifiedUser(uuid);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
