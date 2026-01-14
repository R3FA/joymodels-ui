import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/ui/core/ui/navigation_bar/widgets/navigation_bar_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ModelPageViewModel>();
    final theme = Theme.of(context);

    if (viewModel.isModelBeingDeleted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: NavigationBarScreen(),
      );
    }

    if (viewModel.isLoading || viewModel.loadedModel == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: NavigationBarScreen(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  if (!context.mounted) return;
                  viewModel.onEditModel();
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
                            onPressed: () => Navigator.of(dialogContext).pop(),
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
                return Image.network(
                  "${ApiConstants.baseUrl}/models/get/${vm.loadedModel?.uuid}/images/${Uri.encodeComponent(vm.loadedModel?.modelPictures[i].pictureLocation ?? '')}",
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.person, size: 42, color: Colors.white),
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
          Text(
            "REVIEWS",
            style: theme.textTheme.labelMedium?.copyWith(
              letterSpacing: 1.05,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border.all(color: theme.colorScheme.secondary),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: theme.textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text:
                                  vm.calculatedReviews?.modelReviewResponse ??
                                  '',
                              style: TextStyle(
                                color: vm.getReviewColor(
                                  vm.calculatedReviews?.modelReviewResponse ??
                                      '',
                                  context,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "(${vm.calculatedReviews?.reviewPercentage ?? ''})",
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            TextSpan(
                              children: [
                                if (vm.calculatedReviews?.reviewPercentage !=
                                    'No reviews yet.')
                                  const TextSpan(text: " ALL TIME"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: vm.onViewAllReviews,
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "View All",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: vm.onAddToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text("Add to Cart"),
            ),
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
          Text(
            "FAQ",
            style: theme.textTheme.labelMedium?.copyWith(
              letterSpacing: 1.08,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.secondary),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.surface,
                  foregroundImage: NetworkImage(vm.faqUserAvatar),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vm.faqUsername, style: theme.textTheme.labelLarge),
                      const SizedBox(height: 2),
                      Text(
                        vm.faqQuestion,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: vm.onViewAllFAQ,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.secondary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  child: const Text("View All", style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
