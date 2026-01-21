import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/error_display.dart';
import 'package:joymodels_mobile/ui/core/ui/model_image.dart';
import 'package:joymodels_mobile/ui/core/ui/navigation_bar/widgets/navigation_bar_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/pagination_controls.dart';
import 'package:joymodels_mobile/ui/menu_drawer/widgets/menu_drawer.dart';
import 'package:joymodels_mobile/ui/model_search_page/view_model/model_search_page_view_model.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';

class ModelsSearchScreen extends StatefulWidget {
  final CategoryResponseApiModel? selectedCategory;
  final String? modelName;

  const ModelsSearchScreen({super.key, this.selectedCategory, this.modelName});

  @override
  State<ModelsSearchScreen> createState() => _ModelsSearchScreenState();
}

class _ModelsSearchScreenState extends State<ModelsSearchScreen> {
  late final ModelSearchPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ModelSearchPageViewModel>();
    _viewModel.onSessionExpired = _handleSessionExpired;
    _viewModel.onForbidden = _handleForbidden;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init(
        selectedCategory: widget.selectedCategory,
        modelName: widget.modelName,
      );
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
    final viewModel = context.watch<ModelSearchPageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      endDrawer: const MenuDrawer(),
      bottomNavigationBar: const NavigationBarScreen(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(viewModel, theme),
            const SizedBox(height: 8),
            Expanded(child: _buildBody(viewModel, theme)),
            if (_shouldShowPagination(viewModel))
              PaginationControls(
                currentPage: viewModel.currentPage,
                totalPages: viewModel.totalPages,
                hasPreviousPage: viewModel.hasPreviousPage,
                hasNextPage: viewModel.hasNextPage,
                onPreviousPage: viewModel.onPreviousPage,
                onNextPage: viewModel.onNextPage,
                isLoading: viewModel.areModelsLoading,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ModelSearchPageViewModel viewModel, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => viewModel.onBackPressed(context),
          ),
          Expanded(
            child: TextField(
              controller: viewModel.searchController,
              decoration: InputDecoration(
                hintText: 'Search models...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => viewModel.onFilterSubmit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => viewModel.onFilterPressed(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ModelSearchPageViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return ErrorDisplay(
        message: viewModel.errorMessage!,
        onRetry: () => viewModel.searchModels(
          ModelSearchRequestApiModel(pageNumber: 1, pageSize: 10),
        ),
      );
    }

    if (viewModel.models == null || viewModel.models!.data.isEmpty) {
      return _buildEmptyState(theme);
    }

    return _buildModelsList(viewModel, theme);
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No models found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords\nor browse other categories',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModelsList(ModelSearchPageViewModel viewModel, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.models!.data.length,
      itemBuilder: (_, index) {
        final model = viewModel.models!.data[index];
        return _buildModelCard(
          viewModel: viewModel,
          theme: theme,
          model: model,
        );
      },
    );
  }

  Widget _buildModelCard({
    required ModelSearchPageViewModel viewModel,
    required ThemeData theme,
    required ModelResponseApiModel model,
  }) {
    final hasImage = model.modelPictures.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => viewModel.onModelTap(context, model),
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildModelImage(theme, model, hasImage),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _buildModelInfo(
                      theme: theme,
                      name: model.name,
                      description: model.description,
                      category: model.modelCategories.isNotEmpty
                          ? model.modelCategories[0].categoryName
                          : 'Unknown',
                      price: model.price,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModelImage(
    ThemeData theme,
    ModelResponseApiModel model,
    bool hasImage,
  ) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
      child: SizedBox(
        width: 110,
        child: hasImage
            ? ModelImage(
                imageUrl:
                    "${ApiConstants.baseUrl}/models/get/${model.uuid}/images/${Uri.encodeComponent(model.modelPictures[0].pictureLocation)}",
                fit: BoxFit.cover,
              )
            : Container(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }

  Widget _buildModelInfo({
    required ThemeData theme,
    required String name,
    String? description,
    required String category,
    required double price,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            _buildDescription(theme, description),
          ],
        ),
        const SizedBox(height: 8),
        _buildCategoryAndPrice(theme, category, price),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme, String? description) {
    if (description != null && description.isNotEmpty) {
      return Text(
        description,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text(
      'No description found',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildCategoryAndPrice(
    ThemeData theme,
    String category,
    double price,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Category: ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              category,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          '${price.toStringAsFixed(2)}\$',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  bool _shouldShowPagination(ModelSearchPageViewModel viewModel) {
    return !viewModel.areModelsLoading &&
        viewModel.errorMessage == null &&
        viewModel.models != null &&
        viewModel.models!.totalPages > 1;
  }
}
