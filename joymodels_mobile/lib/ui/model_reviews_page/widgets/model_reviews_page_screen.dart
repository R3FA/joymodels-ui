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
}
