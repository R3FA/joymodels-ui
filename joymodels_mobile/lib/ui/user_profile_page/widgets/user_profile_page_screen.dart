import 'dart:async';

import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/users/response_types/user_model_likes_search_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_mobile/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_mobile/data/model/community_post/response_types/community_post_response_api_model.dart';
import 'package:joymodels_mobile/ui/community_post_detail_page/view_model/community_post_detail_page_view_model.dart';
import 'package:joymodels_mobile/ui/community_post_detail_page/widgets/community_post_detail_page_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/error_display.dart';
import 'package:joymodels_mobile/ui/core/ui/model_image.dart';
import 'package:joymodels_mobile/ui/core/ui/pagination_controls.dart';
import 'package:joymodels_mobile/ui/core/ui/report_dialog.dart';
import 'package:joymodels_mobile/ui/core/ui/user_avatar.dart';
import 'package:joymodels_mobile/data/model/enums/reported_entity_type_api_enum.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/model_page/view_model/model_page_view_model.dart';
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
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init(widget.userUuid);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 &&
        _viewModel.likedCommunityPosts == null &&
        !_viewModel.isLikedCommunityPostsLoading) {
      _viewModel.loadLikedCommunityPosts(resetPage: true);
    }
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            theme.colorScheme.surface,
          ],
        ),
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
              if (!viewModel.isOwnProfile) ...[
                IconButton(
                  icon: Icon(
                    Icons.flag_outlined,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: () => _showReportUserDialog(viewModel.user!),
                ),
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
          const SizedBox(height: 8),
          _buildRoleBadge(user.userRole.roleName, theme),
          const SizedBox(height: 16),
          _buildStats(viewModel, theme),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String roleName, ThemeData theme) {
    Color backgroundColor;
    Color textColor;

    switch (roleName) {
      case 'Admin':
      case 'Root':
        backgroundColor = Colors.black;
        textColor = Colors.white;
        break;
      case 'Helper':
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        break;
      case 'User':
        backgroundColor = Colors.amber;
        textColor = Colors.black;
        break;
      case 'Unverified':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      default:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        roleName,
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
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
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ModelPageViewModel(),
          child: ModelPageScreen(loadedModel: likedModel.modelResponse),
        ),
      ),
    );
  }

  Widget _buildLikedCommunityPostsTab(ThemeData theme) {
    final viewModel = context.watch<UserProfilePageViewModel>();

    if (viewModel.isLikedCommunityPostsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.likedCommunityPosts == null) {
      return _buildEmptyState(
        theme: theme,
        icon: Icons.forum_outlined,
        message: 'Tap to load liked posts',
      );
    }

    final likedPosts = viewModel.likedCommunityPosts!.data;

    if (likedPosts.isEmpty) {
      return _buildEmptyState(
        theme: theme,
        icon: Icons.forum_outlined,
        message: 'No liked community posts yet',
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: likedPosts.length,
            itemBuilder: (_, index) {
              final post = likedPosts[index];
              return _buildCommunityPostCard(theme, post);
            },
          ),
        ),
        if ((viewModel.likedCommunityPosts?.totalPages ?? 1) > 1)
          PaginationControls(
            currentPage: viewModel.currentLikedCommunityPostsPage,
            totalPages: viewModel.likedCommunityPosts!.totalPages,
            hasPreviousPage: viewModel.likedCommunityPosts!.hasPreviousPage,
            hasNextPage: viewModel.likedCommunityPosts!.hasNextPage,
            onPreviousPage: viewModel.onLikedCommunityPostsPreviousPage,
            onNextPage: viewModel.onLikedCommunityPostsNextPage,
            isLoading: viewModel.isLikedCommunityPostsLoading,
          ),
      ],
    );
  }

  Widget _buildCommunityPostCard(
    ThemeData theme,
    CommunityPostResponseApiModel post,
  ) {
    final hasImage = post.pictureLocations.isNotEmpty;
    final youtubeVideoId = RegexValidationViewModel.extractYoutubeVideoId(
      post.youtubeVideoLink,
    );
    final hasYoutubeThumbnail = youtubeVideoId != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _navigateToCommunityPostDetail(post),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: hasImage
                      ? ModelImage(
                          imageUrl:
                              "${ApiConstants.baseUrl}/community-posts/get/${post.uuid}/images/${Uri.encodeComponent(post.pictureLocations[0].pictureLocation)}",
                          fit: BoxFit.cover,
                        )
                      : hasYoutubeThumbnail
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              'https://img.youtube.com/vi/$youtubeVideoId/mqdefault.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: Colors.red.withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.play_circle_fill,
                                  size: 40,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Icon(
                            Icons.article_outlined,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      post.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCommunityPostDetail(CommunityPostResponseApiModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => CommunityPostDetailPageViewModel()..init(post),
          child: const CommunityPostDetailPageScreen(),
        ),
      ),
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

  void _showReportUserDialog(UsersResponseApiModel user) async {
    final result = await ReportDialog.show(
      context: context,
      entityType: ReportedEntityTypeApiEnum.user,
      entityUuid: user.uuid,
      entityDescription: '@${user.nickName}',
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report submitted')));
    }
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
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final hasError = widget.viewModel.followModalSearchError != null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widget.viewModel.followModalSearchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: widget.viewModel.followModalSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            widget.viewModel.followModalSearchController
                                .clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: hasError
                        ? BorderSide(color: theme.colorScheme.error)
                        : BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: hasError
                        ? BorderSide(color: theme.colorScheme.error)
                        : BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: hasError
                        ? BorderSide(color: theme.colorScheme.error, width: 2)
                        : BorderSide(color: theme.colorScheme.primary),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    widget.viewModel.followModalSearchError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
