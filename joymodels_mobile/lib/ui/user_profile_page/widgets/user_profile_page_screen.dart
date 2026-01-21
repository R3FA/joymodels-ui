import 'dart:async';

import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/users/response_types/user_model_likes_search_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_mobile/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/error_display.dart';
import 'package:joymodels_mobile/ui/core/ui/model_image.dart';
import 'package:joymodels_mobile/ui/core/ui/pagination_controls.dart';
import 'package:joymodels_mobile/ui/core/ui/user_avatar.dart';
import 'package:joymodels_mobile/ui/model_page/widgets/model_page_screen.dart';
import 'package:joymodels_mobile/ui/user_profile_page/view_model/user_profile_page_view_model.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';

class UserProfilePageScreen extends StatefulWidget {
  final String userUuid;

  const UserProfilePageScreen({super.key, required this.userUuid});

  @override
  State<UserProfilePageScreen> createState() => _UserProfilePageScreenState();
}

class _UserProfilePageScreenState extends State<UserProfilePageScreen>
    with SingleTickerProviderStateMixin {
  late final UserProfilePageViewModel _viewModel;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<UserProfilePageViewModel>();
    _viewModel.onSessionExpired = _handleSessionExpired;
    _viewModel.onForbidden = _handleForbidden;
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init(widget.userUuid);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleSessionExpired() {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePageScreen()),
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
    final viewModel = context.watch<UserProfilePageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(body: SafeArea(child: _buildBody(viewModel, theme)));
  }

  Widget _buildBody(UserProfilePageViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return ErrorDisplay(
        message: viewModel.errorMessage!,
        onRetry: () => viewModel.init(widget.userUuid),
      );
    }

    if (viewModel.user == null) {
      return const Center(child: Text('User not found'));
    }

    return Column(
      children: [
        _buildProfileHeader(viewModel, theme),
        _buildTabBar(theme),
        Expanded(child: _buildTabBarView(viewModel, theme)),
      ],
    );
  }

  Widget _buildProfileHeader(
    UserProfilePageViewModel viewModel,
    ThemeData theme,
  ) {
    final user = viewModel.user!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => viewModel.onBackPressed(context),
              ),
              const Spacer(),
              if (!viewModel.isOwnProfile)
                viewModel.isFollowLoading
                    ? const SizedBox(
                        width: 48,
                        height: 48,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          viewModel.isFollowing
                              ? Icons.person_remove
                              : Icons.person_add_outlined,
                        ),
                        onPressed: viewModel.toggleFollow,
                      ),
            ],
          ),
          const SizedBox(height: 8),
          _buildAvatar(viewModel, theme),
          const SizedBox(height: 12),
          Text(
            '${user.firstName} ${user.lastName ?? ''}'.trim(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.nickName}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _buildStats(viewModel, theme),
        ],
      ),
    );
  }

  Widget _buildAvatar(UserProfilePageViewModel viewModel, ThemeData theme) {
    final hasAvatar =
        viewModel.userAvatar != null && viewModel.userAvatar!.isNotEmpty;

    return CircleAvatar(
      radius: 50,
      backgroundColor: theme.colorScheme.primary,
      backgroundImage: hasAvatar ? MemoryImage(viewModel.userAvatar!) : null,
      child: hasAvatar
          ? null
          : Icon(Icons.person, size: 50, color: theme.colorScheme.onPrimary),
    );
  }

  Widget _buildStats(UserProfilePageViewModel viewModel, ThemeData theme) {
    final user = viewModel.user!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          theme: theme,
          value: user.userFollowingCount.toString(),
          label: 'following',
          onTap: () => _showFollowModal(isFollowing: true),
        ),
        _buildStatItem(
          theme: theme,
          value: user.userFollowerCount.toString(),
          label: 'followers',
          onTap: () => _showFollowModal(isFollowing: false),
        ),
        _buildStatItem(
          theme: theme,
          value: user.userLikedModelsCount.toString(),
          label: 'likes',
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required ThemeData theme,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    final content = Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: content,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: content,
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Liked Models'),
        Tab(text: 'Liked Community Posts'),
      ],
    );
  }

  Widget _buildTabBarView(UserProfilePageViewModel viewModel, ThemeData theme) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildLikedModelsTab(viewModel, theme),
        _buildLikedCommunityPostsTab(theme),
      ],
    );
  }

  Widget _buildLikedModelsTab(
    UserProfilePageViewModel viewModel,
    ThemeData theme,
  ) {
    if (viewModel.isLikedModelsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final likedModels = viewModel.likedModels?.data ?? [];

    if (likedModels.isEmpty) {
      return _buildEmptyState(
        theme: theme,
        icon: Icons.favorite_border,
        message: 'No liked models yet',
      );
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: likedModels.length,
            itemBuilder: (_, index) {
              final likedModel = likedModels[index];
              return _buildModelCard(viewModel, theme, likedModel);
            },
          ),
        ),
        if (viewModel.totalLikedModelsPages > 1)
          PaginationControls(
            currentPage: viewModel.currentLikedModelsPage,
            totalPages: viewModel.totalLikedModelsPages,
            hasPreviousPage: viewModel.hasLikedModelsPreviousPage,
            hasNextPage: viewModel.hasLikedModelsNextPage,
            onPreviousPage: viewModel.onLikedModelsPreviousPage,
            onNextPage: viewModel.onLikedModelsNextPage,
            isLoading: viewModel.isLikedModelsLoading,
          ),
      ],
    );
  }

  Widget _buildModelCard(
    UserProfilePageViewModel viewModel,
    ThemeData theme,
    UserModelLikesSearchResponseApiModel likedModel,
  ) {
    final model = likedModel.modelResponse;
    final hasImage = model.modelPictures.isNotEmpty;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _navigateToModelPage(likedModel),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: hasImage
                    ? ModelImage(
                        imageUrl:
                            "${ApiConstants.baseUrl}/models/get/${model.uuid}/images/${Uri.encodeComponent(model.modelPictures[0].pictureLocation)}",
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.view_in_ar,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    model.modelCategories.isNotEmpty
                        ? model.modelCategories[0].categoryName
                        : 'Unknown',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToModelPage(UserModelLikesSearchResponseApiModel likedModel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModelPageScreen(loadedModel: likedModel.modelResponse),
      ),
    );
  }

  Widget _buildLikedCommunityPostsTab(ThemeData theme) {
    return _buildEmptyState(
      theme: theme,
      icon: Icons.forum_outlined,
      message: 'Community posts coming soon',
    );
  }

  Widget _buildEmptyState({
    required ThemeData theme,
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showFollowModal({required bool isFollowing}) {
    final viewModel = context.read<UserProfilePageViewModel>();
    viewModel.resetFollowModalState();

    if (isFollowing) {
      viewModel.loadFollowingUsers(resetPage: true);
    } else {
      viewModel.loadFollowerUsers(resetPage: true);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return _FollowModalContent(
          viewModel: viewModel,
          isFollowing: isFollowing,
          onUserTap: (userUuid) {
            Navigator.of(modalContext).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => UserProfilePageViewModel(),
                  child: UserProfilePageScreen(userUuid: userUuid),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FollowModalContent extends StatefulWidget {
  final UserProfilePageViewModel viewModel;
  final bool isFollowing;
  final void Function(String userUuid) onUserTap;

  const _FollowModalContent({
    required this.viewModel,
    required this.isFollowing,
    required this.onUserTap,
  });

  @override
  State<_FollowModalContent> createState() => _FollowModalContentState();
}

class _FollowModalContentState extends State<_FollowModalContent> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.viewModel.onFollowModalSearchChanged(
        query,
        isFollowing: widget.isFollowing,
      );
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
        widget.isFollowing ? 'Following' : 'Followers',
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
        controller: widget.viewModel.followModalSearchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search users...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: widget.viewModel.followModalSearchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.viewModel.followModalSearchController.clear();
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
        if (widget.viewModel.isFollowModalLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.viewModel.followModalErrorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.viewModel.followModalErrorMessage!,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (widget.isFollowing) {
                      widget.viewModel.loadFollowingUsers(resetPage: true);
                    } else {
                      widget.viewModel.loadFollowerUsers(resetPage: true);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final users = _getUsersList();
        final totalPages = widget.isFollowing
            ? widget.viewModel.totalFollowingPages
            : widget.viewModel.totalFollowersPages;

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.isFollowing
                      ? 'Not following anyone yet'
                      : 'No followers yet',
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
            if (totalPages > 1)
              PaginationControls(
                currentPage: widget.viewModel.currentFollowModalPage,
                totalPages: totalPages,
                hasPreviousPage: widget.viewModel.hasFollowModalPreviousPage,
                hasNextPage: widget.isFollowing
                    ? widget.viewModel.hasFollowingNextPage
                    : widget.viewModel.hasFollowersNextPage,
                onPreviousPage: () => widget.viewModel
                    .onFollowModalPreviousPage(isFollowing: widget.isFollowing),
                onNextPage: () => widget.viewModel.onFollowModalNextPage(
                  isFollowing: widget.isFollowing,
                ),
                isLoading: widget.viewModel.isFollowModalLoading,
              ),
          ],
        );
      },
    );
  }

  List<UsersResponseApiModel> _getUsersList() {
    if (widget.isFollowing) {
      return widget.viewModel.followingList?.data
              .map((f) => f.targetUser)
              .toList() ??
          [];
    } else {
      return widget.viewModel.followersList?.data
              .map((f) => f.originUser)
              .toList() ??
          [];
    }
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
