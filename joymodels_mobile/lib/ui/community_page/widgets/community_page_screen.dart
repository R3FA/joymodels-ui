import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/community_post/response_types/community_post_response_api_model.dart';
import 'package:joymodels_mobile/ui/community_page/view_model/community_page_view_model.dart';
import 'package:joymodels_mobile/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/error_display.dart';
import 'package:joymodels_mobile/ui/core/ui/model_image.dart';
import 'package:joymodels_mobile/ui/core/ui/navigation_bar/widgets/navigation_bar_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/pagination_controls.dart';
import 'package:joymodels_mobile/ui/core/ui/user_avatar.dart';
import 'package:joymodels_mobile/ui/menu_drawer/widgets/menu_drawer.dart';
import 'package:joymodels_mobile/ui/user_profile_page/view_model/user_profile_page_view_model.dart';
import 'package:joymodels_mobile/ui/user_profile_page/widgets/user_profile_page_screen.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';

class CommunityPageScreen extends StatefulWidget {
  const CommunityPageScreen({super.key});

  @override
  State<CommunityPageScreen> createState() => _CommunityPageScreenState();
}

class _CommunityPageScreenState extends State<CommunityPageScreen> {
  late final CommunityPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<CommunityPageViewModel>();
    _viewModel.onSessionExpired = _handleSessionExpired;
    _viewModel.onForbidden = _handleForbidden;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
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
    final viewModel = context.watch<CommunityPageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      endDrawer: const MenuDrawer(),
      bottomNavigationBar: viewModel.isLoading
          ? null
          : const NavigationBarScreen(),
      body: SafeArea(child: _buildBody(viewModel, theme)),
    );
  }

  Widget _buildBody(CommunityPageViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return ErrorDisplay(
        message: viewModel.errorMessage!,
        onRetry: () => viewModel.init(),
      );
    }

    return _buildContent(viewModel, theme);
  }

  Widget _buildContent(CommunityPageViewModel viewModel, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: viewModel.onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
              child: _buildHeader(viewModel, theme),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Text(
                'COMMUNITY PAGE',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _buildPostsList(viewModel, theme),
        ],
      ),
    );
  }

  Widget _buildHeader(CommunityPageViewModel viewModel, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: viewModel.isSearching
              ? _buildSearchBar(viewModel, theme)
              : const SizedBox(),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: viewModel.isSearching
              ? () => viewModel.onSearchCancelled()
              : () => viewModel.onSearchPressed(),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => viewModel.onCreatePostPressed(context),
        ),
      ],
    );
  }

  Widget _buildSearchBar(CommunityPageViewModel viewModel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: viewModel.searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search posts...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: viewModel.searchError != null
                  ? BorderSide(color: theme.colorScheme.error)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: viewModel.searchError != null
                  ? BorderSide(color: theme.colorScheme.error)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: viewModel.searchError != null
                  ? BorderSide(color: theme.colorScheme.error, width: 2)
                  : BorderSide(color: theme.colorScheme.primary),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            isDense: true,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: viewModel.onSearchSubmitted,
        ),
        if (viewModel.searchError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              viewModel.searchError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPostsList(CommunityPageViewModel viewModel, ThemeData theme) {
    final posts = viewModel.posts?.data ?? [];

    if (posts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.forum_outlined,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No community posts yet',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == posts.length) {
            return PaginationControls(
              currentPage: viewModel.currentPage,
              totalPages: viewModel.totalPages,
              hasPreviousPage: viewModel.hasPreviousPage,
              hasNextPage: viewModel.hasNextPage,
              onPreviousPage: viewModel.onPreviousPage,
              onNextPage: viewModel.onNextPage,
              isLoading: viewModel.arePostsLoading,
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPostCard(viewModel, theme, posts[index]),
          );
        }, childCount: posts.length + 1),
      ),
    );
  }

  Widget _buildPostCard(
    CommunityPageViewModel viewModel,
    ThemeData theme,
    CommunityPostResponseApiModel post,
  ) {
    final hasImage = post.pictureLocations.isNotEmpty;
    final hasYoutubeLink =
        post.youtubeVideoLink != null && post.youtubeVideoLink!.isNotEmpty;
    final hasNoMedia = !hasImage && !hasYoutubeLink;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => viewModel.onPostTap(context, post),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostTypeBadge(
                  theme,
                  post.communityPostType.communityPostName,
                ),
                if (hasImage)
                  _buildPostImage(theme, post)
                else if (hasYoutubeLink)
                  _buildYoutubeThumbnail(theme, post),
                if (hasNoMedia) _buildPostDescription(theme, post),
                _buildReadMoreButton(viewModel, theme, post),
              ],
            ),
          ),
          _buildPostFooter(viewModel, theme, post),
        ],
      ),
    );
  }

  String? _extractYoutubeVideoId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:watch\?v=|embed\/|v\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  Widget _buildYoutubeThumbnail(
    ThemeData theme,
    CommunityPostResponseApiModel post,
  ) {
    final videoId = _extractYoutubeVideoId(post.youtubeVideoLink!);
    if (videoId == null) {
      return const SizedBox.shrink();
    }

    final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          color: theme.colorScheme.surfaceContainerHighest,
          child: Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
        ),
      ],
    );
  }

  Widget _buildPostDescription(
    ThemeData theme,
    CommunityPostResponseApiModel post,
  ) {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Text(
        post.description,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        maxLines: 7,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPostTypeBadge(ThemeData theme, String typeName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Text(
        typeName.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildPostImage(ThemeData theme, CommunityPostResponseApiModel post) {
    final firstPicture = post.pictureLocations.first;
    final imageUrl =
        "${ApiConstants.baseUrl}/community-posts/get/${post.uuid}/images/${Uri.encodeComponent(firstPicture.pictureLocation)}";

    return Container(
      height: 180,
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      child: ModelImage(imageUrl: imageUrl, fit: BoxFit.cover),
    );
  }

  Widget _buildReadMoreButton(
    CommunityPageViewModel viewModel,
    ThemeData theme,
    CommunityPostResponseApiModel post,
  ) {
    String buttonText;
    switch (post.communityPostType.communityPostName.toLowerCase()) {
      case 'guide':
        buttonText = 'Click to read the full guide.';
        break;
      case 'photo':
        buttonText = 'Click to read the full post.';
        break;
      default:
        buttonText = 'Click to read the full post.';
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: OutlinedButton(
          onPressed: () => viewModel.onPostTap(context, post),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: theme.colorScheme.outlineVariant),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          ),
          child: Text(buttonText, style: theme.textTheme.bodySmall),
        ),
      ),
    );
  }

  Widget _buildPostFooter(
    CommunityPageViewModel viewModel,
    ThemeData theme,
    CommunityPostResponseApiModel post,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _navigateToUserProfile(post.user.uuid),
            child: UserAvatar(
              imageUrl:
                  "${ApiConstants.baseUrl}/users/get/${post.user.uuid}/avatar",
              radius: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToUserProfile(post.user.uuid),
              child: Text(
                post.user.nickName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          _buildStatItem(
            theme,
            Icons.comment_outlined,
            post.communityPostCommentCount.toString(),
          ),
          const SizedBox(width: 16),
          _buildLikeButton(viewModel, theme, post),
          const SizedBox(width: 16),
          _buildDislikeButton(viewModel, theme, post),
        ],
      ),
    );
  }

  Widget _buildLikeButton(
    CommunityPageViewModel viewModel,
    ThemeData theme,
    CommunityPostResponseApiModel post,
  ) {
    final isLiked = viewModel.isPostLiked(post.uuid);
    return GestureDetector(
      onTap: () => viewModel.onLikePressed(post),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            post.communityPostLikes.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.blue,
              fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            size: 22,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildDislikeButton(
    CommunityPageViewModel viewModel,
    ThemeData theme,
    CommunityPostResponseApiModel post,
  ) {
    final isDisliked = viewModel.isPostDisliked(post.uuid);
    return GestureDetector(
      onTap: () => viewModel.onDislikePressed(post),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            post.communityPostDislikes.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red,
              fontWeight: isDisliked ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
            size: 22,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String count, {
    Color? color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color ?? theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          icon,
          size: 22,
          color: color ?? theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  void _navigateToUserProfile(String userUuid) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => UserProfilePageViewModel()..init(userUuid),
          child: UserProfilePageScreen(userUuid: userUuid),
        ),
      ),
    );
  }
}
