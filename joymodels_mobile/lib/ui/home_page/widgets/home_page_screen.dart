import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/ui/navigation_bar/widgets/navigation_bar_screen.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';
import '../view_model/home_page_view_model.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late final HomePageScreenViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<HomePageScreenViewModel>();
    _viewModel.onSessionExpired = _handleSessionExpired;
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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomePageScreenViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: viewModel.isLoading
          ? null
          : const NavigationBarScreen(),
      body: SafeArea(child: _buildBody(viewModel, theme)),
    );
  }

  // ==================== BODY ====================

  Widget _buildBody(HomePageScreenViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return _buildErrorState(viewModel, theme);
    }

    return _buildContent(viewModel, theme);
  }

  Widget _buildErrorState(HomePageScreenViewModel viewModel, ThemeData theme) {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              viewModel.errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.init(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(HomePageScreenViewModel viewModel, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 32, 14, 0),
      physics: const ClampingScrollPhysics(),
      children: [
        _buildHeader(viewModel, theme),
        const SizedBox(height: 28),
        _buildCategoriesGrid(viewModel, theme, context),
        const SizedBox(height: 24),
        _buildTopArtists(viewModel, theme),
        const SizedBox(height: 24),
        _buildRecommendedModels(viewModel, theme),
      ],
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader(HomePageScreenViewModel viewModel, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: theme.colorScheme.primary,
          child: viewModel.loggedUserAvatarUrl.isNotEmpty
              ? ClipOval(
                  child: Image.memory(
                    viewModel.loggedUserAvatarUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.person, size: 42, color: Colors.white),
                  ),
                )
              : const Icon(Icons.person, size: 42, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: viewModel.isSearching
              ? _buildSearchBar(viewModel, theme)
              : _buildWelcomeText(viewModel, theme),
        ),
        if (viewModel.isSearching)
          TextButton(
            onPressed: viewModel.onSearchCancelled,
            child: const Text('Cancel'),
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: viewModel.onSearchPressed,
          ),
        ],
      ],
    );
  }

  Widget _buildWelcomeText(HomePageScreenViewModel viewModel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Hi, ', style: theme.textTheme.titleLarge),
            Flexible(
              child: Text(
                viewModel.loggedUsername,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Text('Welcome back! ', style: theme.textTheme.labelLarge),
      ],
    );
  }

  Widget _buildSearchBar(HomePageScreenViewModel viewModel, ThemeData theme) {
    return TextField(
      controller: viewModel.searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search models, artists.. .',
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
        prefixIcon: const Icon(Icons.search),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (query) => viewModel.onSearchSubmitted(context, query),
    );
  }

  // ==================== CATEGORIES ====================

  Widget _buildCategoriesGrid(
    HomePageScreenViewModel viewModel,
    ThemeData theme,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.55,
        children: [
          ...(viewModel.categories?.data ?? [])
              .take(8)
              .map(
                (cat) => _buildCategoryItem(
                  viewModel: viewModel,
                  theme: theme,
                  categoryName: cat.categoryName,
                  isSelected: cat.uuid == viewModel.selectedCategory,
                  onTap: () => viewModel.onCategoryTap(context, cat),
                ),
              ),
          _buildCategoryItem(
            viewModel: viewModel,
            theme: theme,
            categoryName: 'View All',
            isSelected: viewModel.selectedCategory == 'View All',
            onTap: () => viewModel.onViewAllCategoriesPressed(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required HomePageScreenViewModel viewModel,
    required ThemeData theme,
    required String categoryName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              viewModel.iconForCategory(categoryName),
              size: 32,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color,
            ),
            const SizedBox(height: 5),
            Flexible(
              child: Text(
                categoryName,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.textTheme.labelLarge?.color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TOP ARTISTS ====================

  Widget _buildTopArtists(HomePageScreenViewModel viewModel, ThemeData theme) {
    final hasArtists = (viewModel.topArtists?.data.isNotEmpty ?? false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopArtistsHeader(viewModel, theme, hasArtists),
        const SizedBox(height: 10),
        _buildTopArtistsList(viewModel, theme),
      ],
    );
  }

  Widget _buildTopArtistsHeader(
    HomePageScreenViewModel viewModel,
    ThemeData theme,
    bool hasArtists,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Top Artists', style: theme.textTheme.titleMedium),
        if (hasArtists)
          TextButton(
            onPressed: () => viewModel.onViewAllArtistsPressed(context),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('View All >'),
          ),
      ],
    );
  }

  Widget _buildTopArtistsList(
    HomePageScreenViewModel viewModel,
    ThemeData theme,
  ) {
    final hasArtists = (viewModel.topArtists?.data.isNotEmpty ?? false);

    if (!hasArtists) {
      return Container(
        height: 105,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 38,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              "No top artists yet",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.topArtists?.data.length ?? 0,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final artist = viewModel.topArtists?.data[i];
          final avatar = viewModel.topArtistsAvatars[artist?.uuid];
          final hasAvatar = avatar != null && avatar.isNotEmpty;

          return GestureDetector(
            onTap: () => viewModel.onArtistTap(context, artist),
            child: Container(
              width: 95,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: hasAvatar ? MemoryImage(avatar) : null,
                    child: hasAvatar ? null : const Icon(Icons.person),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    artist?.nickName ?? '',
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${artist?.userModelsCount ?? 0} models',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== RECOMMENDED MODELS ====================

  Widget _buildRecommendedModels(
    HomePageScreenViewModel viewModel,
    ThemeData theme,
  ) {
    final hasModels = (viewModel.recommendedModels?.data.isNotEmpty ?? false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRecommendedModelsHeader(viewModel, theme, hasModels),
        const SizedBox(height: 10),
        _buildRecommendedModelsList(viewModel, theme, hasModels),
      ],
    );
  }

  Widget _buildRecommendedModelsHeader(
    HomePageScreenViewModel viewModel,
    ThemeData theme,
    bool hasModels,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Recommended Models', style: theme.textTheme.titleMedium),
        if (hasModels)
          TextButton(
            onPressed: () => viewModel.onViewAllModelsPressed(context),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('View All >'),
          ),
      ],
    );
  }

  Widget _buildRecommendedModelsList(
    HomePageScreenViewModel viewModel,
    ThemeData theme,
    bool hasModels,
  ) {
    if (!hasModels) {
      return Container(
        height: 115,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_in_ar,
              size: 42,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              "No recommended models yet.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 115,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.recommendedModels?.data.length ?? 0,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          return Container(
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Text(
                'Placeholder for model name',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
