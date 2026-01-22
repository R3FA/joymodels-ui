import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/community_post/response_types/community_post_response_api_model.dart';
import 'package:joymodels_mobile/ui/community_post_detail_page/view_model/community_post_detail_page_view_model.dart';
import 'package:joymodels_mobile/ui/community_post_edit_page/view_model/community_post_edit_page_view_model.dart';
import 'package:joymodels_mobile/ui/community_post_edit_page/widgets/community_post_edit_page_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/error_display.dart';
import 'package:joymodels_mobile/ui/core/ui/model_image.dart';
import 'package:joymodels_mobile/ui/core/ui/pagination_controls.dart';
import 'package:joymodels_mobile/ui/core/ui/user_avatar.dart';
import 'package:joymodels_mobile/ui/user_profile_page/view_model/user_profile_page_view_model.dart';
import 'package:joymodels_mobile/ui/user_profile_page/widgets/user_profile_page_screen.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityPostDetailPageScreen extends StatefulWidget {
  const CommunityPostDetailPageScreen({super.key});

  @override
  State<CommunityPostDetailPageScreen> createState() =>
      _CommunityPostDetailPageScreenState();
}

class _CommunityPostDetailPageScreenState
    extends State<CommunityPostDetailPageScreen> {
  late final CommunityPostDetailPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<CommunityPostDetailPageViewModel>();
    _viewModel.onSessionExpired = _handleSessionExpired;
    _viewModel.onForbidden = _handleForbidden;
    _viewModel.onPostDeleted = _handlePostDeleted;
  }

  void _handlePostDeleted() {
    if (!mounted) return;
    Navigator.of(context).pop(true);
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
    final viewModel = context.watch<CommunityPostDetailPageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewModel.post?.communityPostType.communityPostName.toUpperCase() ??
              '',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!viewModel.isLoading && viewModel.post != null)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  _navigateToEditPost(viewModel);
                } else if (value == 'delete') {
                  _showDeletePostConfirmation(viewModel);
                } else if (value == 'report') {
                  _showReportPostDialog();
                }
              },
              itemBuilder: (context) {
                if (viewModel.isPostOwner) {
                  return [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Edit',
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
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
                  ];
                } else {
                  return [
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          const Text('Report'),
                        ],
                      ),
                    ),
                  ];
                }
              },
            ),
        ],
      ),
      body: _buildBody(viewModel, theme),
    );
  }

  Widget _buildBody(
    CommunityPostDetailPageViewModel viewModel,
    ThemeData theme,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return ErrorDisplay(message: viewModel.errorMessage!, onRetry: () {});
    }

    if (viewModel.post == null) {
      return const Center(child: Text('Post not found'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(viewModel, theme),
          _buildDescription(viewModel, theme),
          if (viewModel.hasImages) _buildImageGallery(viewModel, theme),
          if (viewModel.hasYoutubeLink) _buildYoutubeSection(viewModel, theme),
          _buildAuthorHeader(viewModel, theme),
          _buildInteractionBar(viewModel, theme),
          _buildQuestionsSection(viewModel, theme),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAuthorHeader(
    CommunityPostDetailPageViewModel viewModel,
    ThemeData theme,
  ) {
    final post = viewModel.post!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _navigateToUserProfile(post.user.uuid),
            child: UserAvatar(
              imageUrl:
                  "${ApiConstants.baseUrl}/users/get/${post.user.uuid}/avatar",
              radius: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _navigateToUserProfile(post.user.uuid),
                  child: Text(
                    post.user.nickName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Text(
                  post.communityPostType.communityPostName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(
    CommunityPostDetailPageViewModel viewModel,
    ThemeData theme,
  ) {
    final pictures = viewModel.post!.pictureLocations;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: viewModel.galleryController,
                      onPageChanged: viewModel.onGalleryPageChanged,
                      itemCount: pictures.length,
                      itemBuilder: (context, index) {
                        final imageUrl =
                            "${ApiConstants.baseUrl}/community-posts/get/${viewModel.post!.uuid}/images/${Uri.encodeComponent(pictures[index].pictureLocation)}";
                        return ModelImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                    if (pictures.length > 1 && viewModel.currentImageIndex > 0)
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            onPressed: viewModel.previousImage,
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withValues(
                                  alpha: 0.8,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chevron_left,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (pictures.length > 1 &&
                        viewModel.currentImageIndex < pictures.length - 1)
                      Positioned(
                        right: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            onPressed: viewModel.nextImage,
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withValues(
                                  alpha: 0.8,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chevron_right,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (pictures.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pictures.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == viewModel.currentImageIndex
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildYoutubeSection(
    CommunityPostDetailPageViewModel viewModel,
    ThemeData theme,
  ) {
    final videoId = viewModel.extractYoutubeVideoId(
      viewModel.post!.youtubeVideoLink!,
    );
    if (videoId == null) return const SizedBox.shrink();

    final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => _openYoutubeVideo(viewModel.post!.youtubeVideoLink!),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_circle_filled,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Watch on YouTube',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(
    CommunityPostDetailPageViewModel viewModel,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        viewModel.post!.title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildDescription(
    CommunityPostDetailPageViewModel viewModel,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        viewModel.post!.description,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildInteractionBar(
    CommunityPostDetailPageViewModel viewModel,
    ThemeData theme,
  ) {
    final post = viewModel.post!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInteractionItem(
            theme,
            Icons.comment_outlined,
            post.communityPostCommentCount.toString(),
            'Comments',
            null,
            null,
          ),
          Container(
            width: 1,
            height: 32,
            color: theme.colorScheme.outlineVariant,
          ),
          _buildInteractionItem(
            theme,
            viewModel.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            post.communityPostLikes.toString(),
            'Likes',
            Colors.blue,
            viewModel.onLikePressed,
          ),
          Container(
            width: 1,
            height: 32,
            color: theme.colorScheme.outlineVariant,
          ),
          _buildInteractionItem(
            theme,
            viewModel.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
            post.communityPostDislikes.toString(),
            'Dislikes',
            Colors.red,
            viewModel.onDislikePressed,
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionItem(
    ThemeData theme,
    IconData icon,
    String count,
    String label,
    Color? activeColor,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: activeColor ?? theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                count,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: activeColor ?? theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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

  Future<void> _navigateToEditPost(
    CommunityPostDetailPageViewModel viewModel,
  ) async {
    if (viewModel.post == null) return;

    final result = await Navigator.of(context)
        .push<CommunityPostResponseApiModel>(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) =>
                  CommunityPostEditPageViewModel()..init(viewModel.post!),
              child: const CommunityPostEditPageScreen(),
            ),
          ),
        );

    if (result != null) {
      viewModel.updatePost(result);
    }
  }

  Future<void> _openYoutubeVideo(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open YouTube video')),
          );
        }
      }
    }
  }

  Widget _buildQuestionsSection(
    CommunityPostDetailPageViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.question_answer_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Questions & Answers',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        _buildQuestionInput(viewModel, theme),
        if (viewModel.isLoadingQuestions)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (viewModel.questions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No questions yet. Be the first to ask!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.questions.length,
            itemBuilder: (context, index) {
              final question = viewModel.questions[index];
              return _buildQuestionCard(viewModel, theme, question);
            },
          ),
        PaginationControls(
          currentPage: viewModel.currentPage,
          totalPages: viewModel.totalPages,
          hasPreviousPage: viewModel.hasPreviousPage,
          hasNextPage: viewModel.hasNextPage,
          onPreviousPage: viewModel.onPreviousPage,
          onNextPage: viewModel.onNextPage,
          isLoading: viewModel.isLoadingQuestions,
        ),
      ],
    );
  }

  Widget _buildQuestionInput(
    CommunityPostDetailPageViewModel viewModel,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: viewModel.questionController,
              decoration: InputDecoration(
                hintText: 'Ask a question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: viewModel.isSubmittingQuestion
                ? null
                : viewModel.submitQuestion,
            icon: viewModel.isSubmittingQuestion
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.send, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    CommunityPostDetailPageViewModel viewModel,
    ThemeData theme,
    dynamic question,
  ) {
    final hasReplies = question.replies != null && question.replies!.isNotEmpty;
    final isExpanded = viewModel.isRepliesExpanded(question.uuid);
    final totalReplies = hasReplies ? question.replies!.length : 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _navigateToUserProfile(question.user.uuid),
                  child: UserAvatar(
                    imageUrl:
                        "${ApiConstants.baseUrl}/users/get/${question.user.uuid}/avatar",
                    radius: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _navigateToUserProfile(question.user.uuid),
                        child: Text(
                          question.user.nickName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(question.createdAt),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(viewModel, question.uuid);
                    } else if (value == 'report') {
                      _showReportDialog(question.uuid);
                    }
                  },
                  itemBuilder: (context) {
                    if (viewModel.isOwner(question.user.uuid)) {
                      return [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    } else {
                      return [
                        PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              Icon(
                                Icons.flag,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              const Text('Report'),
                            ],
                          ),
                        ),
                      ];
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(question.messageText, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showReplyInput(viewModel, question.uuid),
                  icon: const Icon(Icons.reply, size: 20),
                  label: Text('Reply', style: theme.textTheme.bodyMedium),
                ),
                if (hasReplies) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => viewModel.toggleReplies(question.uuid),
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                    ),
                    label: Text(
                      isExpanded
                          ? 'Hide replies'
                          : 'Show $totalReplies ${totalReplies == 1 ? 'reply' : 'replies'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ],
            ),
            if (hasReplies && isExpanded)
              _buildRepliesList(
                viewModel,
                theme,
                question.uuid,
                question.replies!,
              ),
            if (viewModel.replyingToQuestionUuid == question.uuid)
              _buildReplyInput(viewModel, theme, question.uuid),
          ],
        ),
      ),
    );
  }

  Widget _buildRepliesList(
    CommunityPostDetailPageViewModel viewModel,
    ThemeData theme,
    String questionUuid,
    List<dynamic> replies,
  ) {
    final visibleCount = viewModel.getVisibleRepliesCount(questionUuid);
    final visibleReplies = replies.take(visibleCount).toList();
    final hasMore = replies.length > visibleCount;

    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...visibleReplies.map((reply) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _navigateToUserProfile(reply.user.uuid),
                    child: UserAvatar(
                      imageUrl:
                          "${ApiConstants.baseUrl}/users/get/${reply.user.uuid}/avatar",
                      radius: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  _navigateToUserProfile(reply.user.uuid),
                              child: Text(
                                reply.user.nickName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(reply.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              padding: EdgeInsets.zero,
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _showDeleteConfirmation(
                                    viewModel,
                                    reply.uuid,
                                  );
                                } else if (value == 'report') {
                                  _showReportDialog(reply.uuid);
                                }
                              },
                              itemBuilder: (context) {
                                if (viewModel.isOwner(reply.user.uuid)) {
                                  return [
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: theme.colorScheme.error,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ];
                                } else {
                                  return [
                                    PopupMenuItem(
                                      value: 'report',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.flag,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('Report'),
                                        ],
                                      ),
                                    ),
                                  ];
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reply.messageText,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          if (hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => viewModel.loadMoreReplies(questionUuid),
                child: Text(
                  'Load more replies (${replies.length - visibleCount} remaining)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReplyInput(
    CommunityPostDetailPageViewModel viewModel,
    ThemeData theme,
    String questionUuid,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: viewModel.replyController,
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                isDense: true,
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: viewModel.isSubmittingReply
                ? null
                : () => viewModel.submitReply(questionUuid),
            icon: viewModel.isSubmittingReply
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.send, size: 20, color: theme.colorScheme.primary),
          ),
          IconButton(
            onPressed: viewModel.cancelReply,
            icon: Icon(Icons.close, size: 20, color: theme.colorScheme.error),
          ),
        ],
      ),
    );
  }

  void _showReplyInput(
    CommunityPostDetailPageViewModel viewModel,
    String questionUuid,
  ) {
    viewModel.startReply(questionUuid);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showDeleteConfirmation(
    CommunityPostDetailPageViewModel viewModel,
    String uuid,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Are you sure you want to delete this?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteQuestion(uuid);
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

  void _showReportDialog(String uuid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report'),
        content: const Text('Report this content as inappropriate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Report submitted')));
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showDeletePostConfirmation(CommunityPostDetailPageViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deletePost();
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

  void _showReportPostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: const Text('Report this post as inappropriate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Report submitted')));
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}
