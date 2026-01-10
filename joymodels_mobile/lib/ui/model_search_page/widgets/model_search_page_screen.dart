import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/ui/model_search_page/view_model/model_search_page_view_model.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';

class ModelsSearchScreen extends StatefulWidget {
  final String? categoryName;

  const ModelsSearchScreen({super.key, this.categoryName});

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init(categoryName: widget.categoryName);
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
    final viewModel = context.watch<ModelSearchPageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(viewModel, theme),
            _buildSortTabs(viewModel, theme),
            const SizedBox(height: 8),
            Expanded(child: _buildBody(viewModel, theme)),
            if (_shouldShowPagination(viewModel))
              _buildPagination(viewModel, theme),
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
              onSubmitted: viewModel.onSearchSubmitted,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => viewModel.onFilterPressed(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSortTabs(ModelSearchPageViewModel viewModel, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildSortTab(
            viewModel: viewModel,
            theme: theme,
            label: 'Best matches',
            sortType: ModelSortType.bestMatches,
          ),
          const SizedBox(width: 24),
          _buildSortTab(
            viewModel: viewModel,
            theme: theme,
            label: 'Top Sales',
            sortType: ModelSortType.topSales,
          ),
          const SizedBox(width: 24),
          _buildSortTab(
            viewModel: viewModel,
            theme: theme,
            label: 'Price',
            sortType: ModelSortType.price,
          ),
        ],
      ),
    );
  }

  Widget _buildSortTab({
    required ModelSearchPageViewModel viewModel,
    required ThemeData theme,
    required String label,
    required ModelSortType sortType,
  }) {
    final isSelected = viewModel.selectedSortType == sortType;

    return GestureDetector(
      onTap: () => viewModel.onSortTypeChanged(sortType),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildBody(ModelSearchPageViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return _buildErrorState(viewModel, theme);
    }

    if (viewModel.models == null || viewModel.models!.data.isEmpty) {
      return _buildEmptyState(theme);
    }

    return _buildModelsList(viewModel, theme);
  }

  Widget _buildErrorState(ModelSearchPageViewModel viewModel, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.errorMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.searchModels(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
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
          index: index,
        );
      },
    );
  }

  Widget _buildModelCard({
    required ModelSearchPageViewModel viewModel,
    required ThemeData theme,
    required ModelResponseApiModel model,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => viewModel.onModelTap(context, model),
          borderRadius: BorderRadius.circular(12),
          splashColor: theme.colorScheme.primary,
          highlightColor: theme.colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModelImage(viewModel, theme, index),
                const SizedBox(width: 12),
                Expanded(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModelImage(
    ModelSearchPageViewModel viewModel,
    ThemeData theme,
    int index,
  ) {
    final picture = (index < viewModel.modelPictures.length)
        ? viewModel.modelPictures[index]
        : null;

    return CircleAvatar(
      radius: 32,
      backgroundColor: theme.colorScheme.primary,
      child: picture != null && picture.fileBytes.isNotEmpty
          ? ClipOval(
              child: Image.memory(
                picture.fileBytes,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, size: 42, color: Colors.white),
              ),
            )
          : const Icon(Icons.person, size: 42, color: Colors.white),
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
      children: [
        Text(
          name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        _buildDescription(theme, description),
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
        maxLines: 3,
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
            Text('Category: ', style: theme.textTheme.bodySmall),
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
          style: theme.textTheme.bodyMedium?.copyWith(
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

  Widget _buildPagination(ModelSearchPageViewModel viewModel, ThemeData theme) {
    final currentPage = viewModel.models!.pageNumber;
    final totalPages = viewModel.models!.totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPaginationArrow(
            viewModel: viewModel,
            theme: theme,
            icon: Icons.chevron_left,
            onPressed: currentPage > 1
                ? () => viewModel.onPageChanged(currentPage - 1)
                : null,
          ),
          const SizedBox(width: 8),
          ..._buildPageNumbers(viewModel, theme, currentPage, totalPages),
          const SizedBox(width: 8),
          _buildPaginationArrow(
            viewModel: viewModel,
            theme: theme,
            icon: Icons.chevron_right,
            onPressed: currentPage < totalPages
                ? () => viewModel.onPageChanged(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationArrow({
    required ModelSearchPageViewModel viewModel,
    required ThemeData theme,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
    );
  }

  List<Widget> _buildPageNumbers(
    ModelSearchPageViewModel viewModel,
    ThemeData theme,
    int currentPage,
    int totalPages,
  ) {
    List<Widget> pages = [];
    List<int> pageNumbers = _getVisiblePageNumbers(currentPage, totalPages);

    int? previousPage;
    for (final page in pageNumbers) {
      if (previousPage != null && page - previousPage > 1) {
        pages.add(_buildEllipsis(theme));
      }

      pages.add(_buildPageButton(viewModel, theme, page, currentPage));
      previousPage = page;
    }

    return pages;
  }

  List<int> _getVisiblePageNumbers(int currentPage, int totalPages) {
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i + 1);
    }

    Set<int> pages = {};

    pages.add(1);

    for (int i = currentPage - 1; i <= currentPage + 1; i++) {
      if (i > 1 && i < totalPages) {
        pages.add(i);
      }
    }

    pages.add(totalPages);

    return pages.toList()..sort();
  }

  Widget _buildEllipsis(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '.. .',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildPageButton(
    ModelSearchPageViewModel viewModel,
    ThemeData theme,
    int page,
    int currentPage,
  ) {
    final isSelected = page == currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: isSelected ? null : () => viewModel.onPageChanged(page),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '$page',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
