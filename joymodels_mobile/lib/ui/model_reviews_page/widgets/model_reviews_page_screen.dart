import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/enums/model_review_enum.dart';
import 'package:joymodels_mobile/data/model/model_reviews/response_types/model_review_response_api_model.dart';
import 'package:joymodels_mobile/ui/core/ui/error_display.dart';
import 'package:joymodels_mobile/ui/core/ui/pagination_controls.dart';
import 'package:joymodels_mobile/ui/core/ui/user_avatar.dart';
import 'package:joymodels_mobile/ui/model_reviews_page/view_model/model_reviews_page_view_model.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';

class ModelReviewsPageScreen extends StatefulWidget {
  final String modelUuid;

  const ModelReviewsPageScreen({super.key, required this.modelUuid});

  @override
  State<ModelReviewsPageScreen> createState() => _ModelReviewsPageScreenState();
}

class _ModelReviewsPageScreenState extends State<ModelReviewsPageScreen> {
  late final ModelReviewsPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ModelReviewsPageViewModel>();
    _viewModel.onSessionExpired = _handleSessionExpired;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init(widget.modelUuid);
    });
  }

  void _handleSessionExpired() {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePageScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ModelReviewsPageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(viewModel, theme),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(viewModel, theme)),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    ModelReviewsPageViewModel viewModel,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: viewModel.selectedReviewType == ModelReviewEnum.all,
            onSelected: (_) => viewModel.onFilterChanged(ModelReviewEnum.all),
          ),
          FilterChip(
            label: const Text('Positive'),
            selected: viewModel.selectedReviewType == ModelReviewEnum.positive,
            onSelected: (_) =>
                viewModel.onFilterChanged(ModelReviewEnum.positive),
          ),
          FilterChip(
            label: const Text('Negative'),
            selected: viewModel.selectedReviewType == ModelReviewEnum.negative,
            onSelected: (_) =>
                viewModel.onFilterChanged(ModelReviewEnum.negative),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ModelReviewsPageViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading && viewModel.reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return ErrorDisplay(
        message: viewModel.errorMessage!,
        onRetry: () => viewModel.loadReviews(),
      );
    }

    if (viewModel.reviews.isEmpty) {
      return Center(
        child: Text(
          'No reviews yet.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: viewModel.reviews.length,
            itemBuilder: (context, index) {
              return _buildReviewCard(
                viewModel.reviews[index],
                viewModel,
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
    );
  }

  Widget _buildReviewCard(
    ModelReviewResponseApiModel review,
    ModelReviewsPageViewModel viewModel,
    ThemeData theme,
  ) {
    final isOwnReview = viewModel.isOwnReview(review);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(
                  imageUrl:
                      "${ApiConstants.baseUrl}/users/get/${review.usersResponse.uuid}/avatar",
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.usersResponse.nickName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(review.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: viewModel
                        .getReviewTypeColor(
                          context,
                          review.modelReviewTypeResponse.modelReviewTypeName,
                        )
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: viewModel.getReviewTypeColor(
                        context,
                        review.modelReviewTypeResponse.modelReviewTypeName,
                      ),
                    ),
                  ),
                  child: Text(
                    review.modelReviewTypeResponse.modelReviewTypeName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: viewModel.getReviewTypeColor(
                        context,
                        review.modelReviewTypeResponse.modelReviewTypeName,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditReviewDialog(review, viewModel, theme);
                        break;
                      case 'delete':
                        _showDeleteConfirmDialog(review, viewModel, theme);
                        break;
                      case 'report':
                        _showReportDialog(review, theme);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (isOwnReview) ...[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    const PopupMenuItem<String>(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag, size: 18),
                          SizedBox(width: 8),
                          Text('Report'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (review.modelReviewText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(review.modelReviewText, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
    ModelReviewResponseApiModel review,
    ModelReviewsPageViewModel viewModel,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Review'),
          content: const Text(
            'Are you sure you want to delete this review? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await viewModel.deleteReview(context, review);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showEditReviewDialog(
    ModelReviewResponseApiModel review,
    ModelReviewsPageViewModel viewModel,
    ThemeData theme,
  ) async {
    await viewModel.loadReviewTypes();

    if (!mounted) return;

    final reviewTextController = TextEditingController(
      text: review.modelReviewText,
    );
    final formKey = GlobalKey<FormState>();
    String? selectedReviewTypeUuid = review.modelReviewTypeResponse.uuid;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.edit, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  const Text('Edit Review'),
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
                        'Review Type',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (viewModel.isLoadingReviewTypes)
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
                          children: viewModel.reviewTypes.map((reviewType) {
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
                  listenable: viewModel,
                  builder: (context, _) {
                    return ElevatedButton(
                      onPressed:
                          viewModel.isEditing || selectedReviewTypeUuid == null
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                final success = await viewModel.editReview(
                                  this.context,
                                  review.uuid,
                                  selectedReviewTypeUuid,
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
                      child: viewModel.isEditing
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
                          : const Text('Save'),
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

  void _showReportDialog(ModelReviewResponseApiModel review, ThemeData theme) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.flag, color: theme.colorScheme.error),
              const SizedBox(width: 12),
              const Text('Report Review'),
            ],
          ),
          content: const Text(
            'Report functionality will be implemented soon. This review will be flagged for moderator review.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report feature coming soon'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Report'),
            ),
          ],
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
}
