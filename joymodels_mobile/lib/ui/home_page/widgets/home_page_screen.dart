import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/error_display.dart';
import 'package:joymodels_mobile/ui/core/ui/model_image.dart';
import 'package:joymodels_mobile/ui/core/ui/navigation_bar/widgets/navigation_bar_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/pagination_controls.dart';
import 'package:joymodels_mobile/ui/menu_drawer/widgets/menu_drawer.dart';
import 'package:joymodels_mobile/ui/notification_page/view_model/notification_page_view_model.dart';
import 'package:joymodels_mobile/ui/notification_page/widgets/notification_page_screen.dart';
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

  void _navigateToNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => NotificationPageViewModel(),
          child: const NotificationPageScreen(),
        ),
      ),
    );
    _viewModel.fetchUnreadNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomePageScreenViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      endDrawer: const MenuDrawer(),
      bottomNavigationBar: viewModel.isLoading
          ? null
          : const NavigationBarScreen(),
      body: SafeArea(child: _buildBody(viewModel, theme)),
    );
  }

  Widget _buildBody(HomePageScreenViewModel viewModel, ThemeData theme) {
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

  Widget _buildContent(HomePageScreenViewModel viewModel, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 32, 14, 24),
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

  Widget _buildHeader(HomePageScreenViewModel viewModel, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => viewModel.onOwnProfileTap(context),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.primary,
            child: viewModel.loggedUserAvatarUrl.isNotEmpty
                ? ClipOval(
                    child: Image.memory(
                      viewModel.loggedUserAvatarUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const Icon(Icons.person, size: 42, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: viewModel.isSearching
              ? _buildSearchBar(viewModel, theme)
              : _buildWelcomeText(viewModel, theme, context),
        ),
        if (viewModel.isSearching)
          TextButton(
            onPressed: viewModel.onSearchCancelled,
            child: const Text('Cancel'),
          )
        else ...[
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => _navigateToNotifications(),
              ),
              if (viewModel.unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: viewModel.onSearchPressed,
          ),
        ],
      ],
    );
  }

  Widget _buildWelcomeText(
    HomePageScreenViewModel viewModel,
    ThemeData theme,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Hi, ', style: theme.textTheme.titleLarge),
            Flexible(
              child: GestureDetector(
                onTap: () => viewModel.onOwnProfileTap(context),
                child: Text(
                  viewModel.loggedUsername,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        Text('Welcome back! ', style: theme.textTheme.labelLarge),
      ],
    );
  }

  Widget _buildSearchBar(HomePageScreenViewModel viewModel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: viewModel.searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search models',
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
              vertical: 12,
            ),
            prefixIcon: const Icon(Icons.search),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (query) => viewModel.onSearchSubmitted(context, query),
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
            onPressed: () => _showTopArtistsModal(viewModel, theme),
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
            onPressed: () => _showRecommendedModelsModal(viewModel, theme),
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
        height: 140,
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
              "No recommended models yet",
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
      height: 165,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.recommendedModels?.data.length ?? 0,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final model = viewModel.recommendedModels?.data[i];
          final hasPicture = model?.modelPictures.isNotEmpty ?? false;
          final imageUrl = hasPicture
              ? '${ApiConstants.baseUrl}/models/get/${model?.uuid}/images/${Uri.encodeComponent(model?.modelPictures.first.pictureLocation ?? '')}'
              : '';

          return GestureDetector(
            onTap: () => viewModel.onModelTap(context, model),
            child: Container(
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: hasPicture
                          ? ModelImage(imageUrl: imageUrl, fit: BoxFit.cover)
                          : Icon(
                              Icons.view_in_ar,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              model?.name ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${model?.price.toStringAsFixed(2) ?? '0.00'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

  void _showTopArtistsModal(
    HomePageScreenViewModel viewModel,
    ThemeData theme,
  ) {
    viewModel.onViewAllArtistsPressed(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Top Artists',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTopArtistsSearchField(viewModel, theme),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildTopArtistsModalList(
                          viewModel,
                          theme,
                          scrollController,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).then((_) {
      viewModel.onTopArtistsModalClosed();
    });
  }

  Widget _buildTopArtistsSearchField(
    HomePageScreenViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: viewModel.topArtistsSearchController,
          decoration: InputDecoration(
            hintText: 'Search by nickname...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: viewModel.topArtistsSearchError != null
                  ? BorderSide(color: theme.colorScheme.error)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: viewModel.topArtistsSearchError != null
                  ? BorderSide(color: theme.colorScheme.error)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: viewModel.topArtistsSearchError != null
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
          onChanged: (value) => viewModel.searchTopArtistsModal(value),
        ),
        if (viewModel.topArtistsSearchError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              viewModel.topArtistsSearchError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTopArtistsModalList(
    HomePageScreenViewModel viewModel,
    ThemeData theme,
    ScrollController scrollController,
  ) {
    if (viewModel.isTopArtistsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final artists = viewModel.topArtists?.data ?? [];

    if (artists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No artists found',
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
          child: ListView.separated(
            controller: scrollController,
            itemCount: artists.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final artist = artists[index];
              final avatar = viewModel.topArtistsAvatars[artist.uuid];
              final hasAvatar = avatar != null && avatar.isNotEmpty;

              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: hasAvatar ? MemoryImage(avatar) : null,
                  child: hasAvatar ? null : const Icon(Icons.person),
                ),
                title: Text(
                  artist.nickName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${artist.userModelsCount} models',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pop();
                  viewModel.onArtistTap(context, artist);
                },
              );
            },
          ),
        ),
        PaginationControls(
          currentPage: viewModel.topArtistsModalCurrentPage,
          totalPages: viewModel.topArtistsModalTotalPages,
          hasPreviousPage: viewModel.topArtistsModalHasPreviousPage,
          hasNextPage: viewModel.topArtistsModalHasNextPage,
          onPreviousPage: viewModel.onTopArtistsModalPreviousPage,
          onNextPage: viewModel.onTopArtistsModalNextPage,
          isLoading: viewModel.isTopArtistsLoading,
        ),
      ],
    );
  }

  void _showRecommendedModelsModal(
    HomePageScreenViewModel viewModel,
    ThemeData theme,
  ) {
    viewModel.onViewAllModelsPressed(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Recommended Models',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRecommendedModelsSearchField(viewModel, theme),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildRecommendedModelsModalList(
                          viewModel,
                          theme,
                          scrollController,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).then((_) {
      viewModel.onRecommendedModelsModalClosed();
    });
  }

  Widget _buildRecommendedModelsSearchField(
    HomePageScreenViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: viewModel.recommendedModelsSearchController,
          decoration: InputDecoration(
            hintText: 'Search by model name...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: viewModel.recommendedModelsSearchError != null
                  ? BorderSide(color: theme.colorScheme.error)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: viewModel.recommendedModelsSearchError != null
                  ? BorderSide(color: theme.colorScheme.error)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: viewModel.recommendedModelsSearchError != null
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
          onChanged: (value) => viewModel.searchRecommendedModelsModal(value),
        ),
        if (viewModel.recommendedModelsSearchError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              viewModel.recommendedModelsSearchError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendedModelsModalList(
    HomePageScreenViewModel viewModel,
    ThemeData theme,
    ScrollController scrollController,
  ) {
    if (viewModel.isRecommendedModelsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final models = viewModel.recommendedModels?.data ?? [];

    if (models.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_in_ar_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No models found',
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
          child: ListView.separated(
            controller: scrollController,
            itemCount: models.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final model = models[index];
              final hasPicture = model.modelPictures.isNotEmpty;
              final imageUrl = hasPicture
                  ? '${ApiConstants.baseUrl}/models/get/${model.uuid}/images/${Uri.encodeComponent(model.modelPictures.first.pictureLocation)}'
                  : '';

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: hasPicture
                        ? ModelImage(imageUrl: imageUrl, fit: BoxFit.cover)
                        : Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.view_in_ar,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                title: Text(
                  model.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '\$${model.price.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pop();
                  viewModel.onModelTap(context, model);
                },
              );
            },
          ),
        ),
        PaginationControls(
          currentPage: viewModel.recommendedModelsModalCurrentPage,
          totalPages: viewModel.recommendedModelsModalTotalPages,
          hasPreviousPage: viewModel.recommendedModelsModalHasPreviousPage,
          hasNextPage: viewModel.recommendedModelsModalHasNextPage,
          onPreviousPage: viewModel.onRecommendedModelsModalPreviousPage,
          onNextPage: viewModel.onRecommendedModelsModalNextPage,
          isLoading: viewModel.isRecommendedModelsLoading,
        ),
      ],
    );
  }
}
