import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/error_display.dart';
import 'package:joymodels_mobile/ui/core/ui/model_image.dart';
import 'package:joymodels_mobile/ui/core/ui/navigation_bar/widgets/navigation_bar_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/user_avatar.dart';
import 'package:joymodels_mobile/ui/menu_drawer/widgets/menu_drawer.dart';
import 'package:joymodels_mobile/ui/model_page/view_model/model_page_view_model.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';

class ModelPageScreen extends StatefulWidget {
  final ModelResponseApiModel? loadedModel;
  const ModelPageScreen({super.key, required this.loadedModel});

  @override
  State<ModelPageScreen> createState() => _ModelPageScreenState();
}

class _ModelPageScreenState extends State<ModelPageScreen> {
  late final ModelPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ModelPageViewModel>();
    _viewModel.onSessionExpired = _handleSessionExpired;
    _viewModel.onForbidden = _handleForbidden;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init(loadedModel: widget.loadedModel);
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
    final viewModel = context.watch<ModelPageViewModel>();
    final theme = Theme.of(context);

    if (viewModel.isModelBeingDeleted) {
      return Scaffold(
        endDrawer: const MenuDrawer(),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: const NavigationBarScreen(),
      );
    }

    if (viewModel.isLoading || viewModel.loadedModel == null) {
      return Scaffold(
        endDrawer: const MenuDrawer(),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: const NavigationBarScreen(),
      );
    }

    if (viewModel.errorMessage != null) {
      return Scaffold(
        endDrawer: const MenuDrawer(),
        body: ErrorDisplay(
          message: viewModel.errorMessage!,
          onRetry: () => viewModel.init(loadedModel: widget.loadedModel),
        ),
        bottomNavigationBar: const NavigationBarScreen(),
      );
    }

    return Scaffold(
      endDrawer: const MenuDrawer(),
      appBar: AppBar(
        actions: [
          if (viewModel.isModelOwner)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    if (!context.mounted) return;
                    viewModel.onEditModel(context);
                    break;
                  case 'delete':
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Confirm delete'),
                          content: const Text(
                            'Are you sure you want to delete this model?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
                                await viewModel.onDeleteModel(context);
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModelGallery(viewModel, theme),
              const SizedBox(height: 16),
              _buildModelTitleRow(viewModel, theme),
              const SizedBox(height: 6),
              _buildMetaInfo(viewModel, theme),
              const SizedBox(height: 16),
              _buildDescription(viewModel, theme),
              const SizedBox(height: 18),
              _buildCategories(viewModel, theme),
              const SizedBox(height: 18),
              _buildReviews(viewModel, theme),
              const SizedBox(height: 12),
              _buildBuySection(viewModel, theme),
              const SizedBox(height: 20),
              _buildFAQSection(viewModel, theme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavigationBarScreen(),
    );
  }

  Widget _buildModelGallery(ModelPageViewModel vm, ThemeData theme) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              itemCount: vm.loadedModel?.modelPictures.length ?? 0,
              controller: vm.galleryController,
              onPageChanged: vm.onGalleryPageChanged,
              itemBuilder: (context, i) {
                return ModelImage(
                  imageUrl:
                      "${ApiConstants.baseUrl}/models/get/${vm.loadedModel?.uuid}/images/${Uri.encodeComponent(vm.loadedModel?.modelPictures[i].pictureLocation ?? '')}",
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                );
              },
            ),
          ),
        ),
        if ((vm.loadedModel?.modelPictures.length ?? 0) > 1 &&
            vm.galleryIndex > 0)
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              onTap: vm.previousGallery,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Icon(
                  Icons.chevron_left,
                  color: theme.colorScheme.onSurface,
                  size: 32,
                ),
              ),
            ),
          ),
        if ((vm.loadedModel?.modelPictures.length ?? 0) > 1 &&
            vm.galleryIndex < (vm.loadedModel?.modelPictures.length ?? 0) - 1)
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              onTap: vm.nextGallery,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface,
                  size: 32,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 8,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${vm.galleryIndex + 1} / ${(vm.loadedModel?.modelPictures.length ?? 0)}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModelTitleRow(ModelPageViewModel vm, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              vm.loadedModel?.name ?? '',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              vm.isModelLiked ? Icons.favorite : Icons.favorite_border,
              color: vm.isModelLiked ? Colors.red : theme.iconTheme.color,
            ),
            tooltip: vm.isModelLiked ? 'Unlike' : 'Like',
            onPressed: vm.onLikeModel,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(ModelPageViewModel vm, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Row(
        children: [
          Text(
            'CREATOR:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            vm.loadedModel?.user.nickName ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 14),
          const Spacer(),
          Text(
            'RELEASED:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            DateFormat(
              'dd. MMMM yyyy.',
            ).format(vm.loadedModel?.createdAt ?? DateTime.now()),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ModelPageViewModel vm, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        vm.loadedModel?.description ?? '',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildCategories(ModelPageViewModel vm, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CATEGORIES",
            style: theme.textTheme.labelMedium?.copyWith(
              letterSpacing: 1.1,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [
              ...(vm.loadedModel?.modelCategories ?? []).map(
                (cat) => Chip(
                  label: Text(
                    cat.categoryName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviews(ModelPageViewModel vm, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "REVIEWS",
                style: theme.textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.05,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
              if (vm.hasReviews)
                TextButton(
                  onPressed: () => vm.onViewAllReviews(context),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.secondary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  child: const Text("View All", style: TextStyle(fontSize: 13)),
                ),
            ],
          ),
          const SizedBox(height: 7),
          vm.hasReviews
              ? _buildReviewsSummary(vm, theme)
              : _buildEmptyReviews(vm, theme),
        ],
      ),
    );
  }

  Widget _buildReviewsSummary(ModelPageViewModel vm, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(color: theme.colorScheme.secondary),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: vm.calculatedReviews?.modelReviewResponse ?? '',
                    style: TextStyle(
                      color: vm.getReviewColor(
                        vm.calculatedReviews?.modelReviewResponse ?? '',
                        context,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " (${vm.calculatedReviews?.reviewPercentage ?? ''})",
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                  const TextSpan(text: " ALL TIME"),
                ],
              ),
            ),
          ),
          if (!vm.hasUserReviewed && !vm.isModelOwner)
            IconButton(
              onPressed: () => _showAddReviewDialog(vm, theme),
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add Review',
              color: theme.colorScheme.secondary,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviews(ModelPageViewModel vm, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 22,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "No reviews yet",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (!vm.hasUserReviewed && !vm.isModelOwner)
            TextButton.icon(
              onPressed: () => _showAddReviewDialog(vm, theme),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add Review"),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddReviewDialog(ModelPageViewModel vm, ThemeData theme) async {
    await vm.loadReviewTypes();

    if (!mounted) return;

    final reviewTextController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedReviewTypeUuid;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text('Add Review'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review "${vm.loadedModel?.name}"',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Review Type',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (vm.isLoadingReviewTypes)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: vm.reviewTypes.map((reviewType) {
                            final isSelected =
                                selectedReviewTypeUuid == reviewType.uuid;
                            return ChoiceChip(
                              label: Text(reviewType.modelReviewTypeName),
                              selected: isSelected,
                              onSelected: (selected) {
                                setDialogState(() {
                                  selectedReviewTypeUuid = selected
                                      ? reviewType.uuid
                                      : null;
                                });
                              },
                              selectedColor: _getReviewTypeColor(
                                reviewType.modelReviewTypeName,
                                theme,
                              ).withValues(alpha: 0.3),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? _getReviewTypeColor(
                                        reviewType.modelReviewTypeName,
                                        theme,
                                      )
                                    : theme.colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: reviewTextController,
                        maxLines: 4,
                        maxLength: 5000,
                        decoration: InputDecoration(
                          hintText: 'Write your review here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your review';
                          }
                          if (value.trim().length < 10) {
                            return 'Review must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ListenableBuilder(
                  listenable: vm,
                  builder: (context, _) {
                    return ElevatedButton(
                      onPressed:
                          vm.isCreatingReview || selectedReviewTypeUuid == null
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                final success = await vm.submitReview(
                                  this.context,
                                  selectedReviewTypeUuid!,
                                  reviewTextController.text.trim(),
                                );
                                if (success && dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: vm.isCreatingReview
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Submit'),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getReviewTypeColor(String reviewType, ThemeData theme) {
    switch (reviewType.toLowerCase()) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      case 'mixed':
        return Colors.orange;
      default:
        return theme.colorScheme.primary;
    }
  }

  Widget _buildBuySection(ModelPageViewModel vm, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.colorScheme.secondary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Buy ",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    TextSpan(
                      text: vm.loadedModel?.name ?? '',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              vm.loadedModel != null
                  ? "\$${vm.loadedModel!.price.toStringAsFixed(2)}"
                  : "\$0.00",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            if (!vm.isModelOwner) ...[
              const SizedBox(width: 6),
              IconButton(
                onPressed: vm.isAddingToCart
                    ? null
                    : () => vm.onToggleCart(context),
                icon: vm.isAddingToCart
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            vm.isInCart
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Icon(
                        vm.isInCart
                            ? Icons.remove_shopping_cart
                            : Icons.add_shopping_cart,
                      ),
                tooltip: vm.isInCart ? 'Remove from Cart' : 'Add to Cart',
                color: vm.isInCart
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                style: IconButton.styleFrom(
                  backgroundColor: vm.isInCart
                      ? theme.colorScheme.errorContainer.withValues(alpha: 0.5)
                      : theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(ModelPageViewModel vm, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "FAQ",
                style: theme.textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.08,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
              if (vm.hasFAQ)
                TextButton(
                  onPressed: () => vm.onViewAllFAQ(context),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.secondary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  child: const Text("View All", style: TextStyle(fontSize: 13)),
                ),
            ],
          ),
          const SizedBox(height: 7),
          vm.hasFAQ ? _buildFAQList(vm, theme) : _buildEmptyFAQ(vm, theme),
        ],
      ),
    );
  }

  Widget _buildEmptyFAQ(ModelPageViewModel vm, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          Icon(
            Icons.question_answer_outlined,
            size: 22,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "No FAQ yet",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => _showAskQuestionDialog(vm, theme),
            icon: const Icon(Icons.add, size: 16),
            label: const Text("Ask Question"),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQList(ModelPageViewModel vm, ThemeData theme) {
    final faq = vm.faqList.first;
    final hasReplies = faq.replies != null && faq.replies!.isNotEmpty;
    final replyCount = faq.replies?.length ?? 0;

    return InkWell(
      onTap: () => vm.onOpenFAQDetail(context, faq),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.secondary),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(
                  imageUrl:
                      "${ApiConstants.baseUrl}/users/get/${faq.user.uuid}/avatar",
                  radius: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        faq.user.nickName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        faq.messageText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasReplies) ...[
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(left: 46),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.reply,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        faq.replies!.first.messageText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.comment_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '$replyCount ${replyCount == 1 ? 'answer' : 'answers'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showAskQuestionDialog(vm, theme),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Ask Question',
                  color: theme.colorScheme.secondary,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAskQuestionDialog(ModelPageViewModel vm, ThemeData theme) {
    final questionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.question_answer_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text('Ask a Question'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ask about "${vm.loadedModel?.name}"',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: questionController,
                        maxLines: 4,
                        maxLength: 5000,
                        decoration: InputDecoration(
                          hintText: 'Type your question here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your question';
                          }
                          if (value.trim().length < 10) {
                            return 'Question must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ListenableBuilder(
                  listenable: vm,
                  builder: (context, _) {
                    return ElevatedButton(
                      onPressed: vm.isCreatingFAQ
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                final success = await vm.submitFAQQuestion(
                                  this.context,
                                  questionController.text.trim(),
                                );
                                if (success && dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: vm.isCreatingFAQ
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Submit'),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
