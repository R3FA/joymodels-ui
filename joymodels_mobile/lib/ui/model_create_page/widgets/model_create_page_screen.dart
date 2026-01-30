import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joymodels_mobile/data/model/model_availability/response_types/model_availability_response_api_model.dart';
import 'package:joymodels_mobile/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/error_display.dart';
import 'package:joymodels_mobile/ui/core/ui/currency_input_formatter.dart';
import 'package:joymodels_mobile/ui/core/ui/form_input_decoration.dart';
import 'package:joymodels_mobile/ui/core/ui/navigation_bar/widgets/navigation_bar_screen.dart';
import 'package:joymodels_mobile/ui/menu_drawer/widgets/menu_drawer.dart';
import 'package:joymodels_mobile/ui/model_create_page/view_model/model_create_page_view_model.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';

class ModelCreatePageScreen extends StatefulWidget {
  const ModelCreatePageScreen({super.key});

  @override
  State<ModelCreatePageScreen> createState() => _ModelCreatePageScreenState();
}

class _ModelCreatePageScreenState extends State<ModelCreatePageScreen> {
  late final ModelCreatePageViewModel _viewModel;

  final _nameKey = GlobalKey();
  final _descriptionKey = GlobalKey();
  final _photosKey = GlobalKey();
  final _categoriesKey = GlobalKey();
  final _availabilityKey = GlobalKey();
  final _priceKey = GlobalKey();
  final _modelFileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ModelCreatePageViewModel>();
    _viewModel.onSessionExpired = _handleSessionExpired;
    _viewModel.onForbidden = _handleForbidden;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  void _scrollToFirstError() {
    final vm = _viewModel;
    GlobalKey? targetKey;

    if (vm.nameError != null) {
      targetKey = _nameKey;
    } else if (vm.descriptionError != null) {
      targetKey = _descriptionKey;
    } else if (vm.photosError != null) {
      targetKey = _photosKey;
    } else if (vm.categoriesError != null) {
      targetKey = _categoriesKey;
    } else if (vm.availabilityError != null) {
      targetKey = _availabilityKey;
    } else if (vm.priceError != null) {
      targetKey = _priceKey;
    } else if (vm.modelFileError != null) {
      targetKey = _modelFileKey;
    }

    if (targetKey?.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
    final viewModel = context.watch<ModelCreatePageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      endDrawer: const MenuDrawer(),
      bottomNavigationBar: const NavigationBarScreen(),
      appBar: AppBar(
        title: const Text('Add model'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: viewModel.isSubmitting || !viewModel.isFormComplete
                    ? null
                    : () async {
                        final success = await viewModel.onSubmit(context);
                        if (!success) _scrollToFirstError();
                      },
                child: const Text(
                  'Create',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(viewModel, theme),
    );
  }

  Widget _buildBody(ModelCreatePageViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return ErrorDisplay(
        message: viewModel.errorMessage!,
        onRetry: viewModel.clearError,
        retryButtonText: 'Retry',
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KeyedSubtree(
                key: _nameKey,
                child: _buildNameField(viewModel, theme),
              ),
              const SizedBox(height: 20),

              KeyedSubtree(
                key: _descriptionKey,
                child: _buildDescriptionField(viewModel, theme),
              ),
              const SizedBox(height: 20),

              KeyedSubtree(
                key: _photosKey,
                child: _buildPhotosSection(viewModel, theme),
              ),
              const SizedBox(height: 20),

              KeyedSubtree(
                key: _categoriesKey,
                child: _buildCategorySection(viewModel, theme),
              ),
              const SizedBox(height: 20),

              KeyedSubtree(
                key: _availabilityKey,
                child: _buildAvailabilitySection(viewModel, theme),
              ),
              const SizedBox(height: 20),

              KeyedSubtree(
                key: _priceKey,
                child: _buildPriceField(viewModel, theme),
              ),
              const SizedBox(height: 32),

              KeyedSubtree(
                key: _modelFileKey,
                child: _buildAddModelFileButton(viewModel, theme),
              ),
            ],
          ),
        ),

        if (viewModel.isSubmitting) _buildLoadingOverlay(theme),
      ],
    );
  }

  Widget _buildNameField(ModelCreatePageViewModel viewModel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.modelNameController,
          decoration: formInputDecoration(
            "Name",
            Icons.arrow_forward_ios_rounded,
          ).copyWith(errorText: viewModel.nameError),
          maxLength: 100,
        ),
      ],
    );
  }

  Widget _buildDescriptionField(
    ModelCreatePageViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.modelDescriptionController,
          decoration: formInputDecoration(
            "Model description",
            Icons.description,
          ).copyWith(errorText: viewModel.descriptionError),
          maxLines: 10,
          maxLength: 5000,
        ),
      ],
    );
  }

  Widget _buildPhotosSection(
    ModelCreatePageViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Photos:', style: theme.textTheme.titleSmall),
            Text(
              '${viewModel.selectedPhotos.length}/${ModelCreatePageViewModel.maxPhotos}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...viewModel.selectedPhotos.asMap().entries.map(
              (entry) => _buildPhotoItem(
                viewModel: viewModel,
                theme: theme,
                photo: entry.value,
                index: entry.key,
              ),
            ),

            if (viewModel.canAddMorePhotos)
              _buildAddPhotoButton(viewModel, theme),
          ],
        ),
        if (viewModel.photosError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              viewModel.photosError!,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoItem({
    required ModelCreatePageViewModel viewModel,
    required ThemeData theme,
    required Uint8List photo,
    required int index,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(photo, width: 80, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => viewModel.onRemovePhoto(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 14,
                color: theme.colorScheme.onError,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton(
    ModelCreatePageViewModel viewModel,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: viewModel.onAddPhotoPressed,
      onLongPress: viewModel.onAddMultiplePhotosPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.add, color: theme.colorScheme.primary, size: 32),
      ),
    );
  }

  Widget _buildCategorySection(
    ModelCreatePageViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          onChanged: (value) => viewModel.getCategories(categoryName: value),
          controller: viewModel.modelCategorySearchController,
          decoration: formInputDecoration("Search a category", Icons.search),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.5,
          ),
          itemCount: viewModel
              .filteredCategories(
                viewModel.modelCategorySearchController.text.toLowerCase(),
              )
              .length,
          itemBuilder: (context, index) {
            final category = viewModel.filteredCategories(
              viewModel.modelCategorySearchController.text.toLowerCase(),
            )[index];

            final uuid = category['uuid'];
            final name = category['name'];

            if (uuid == null) return const SizedBox.shrink();

            final isSelected = viewModel.isCategorySelected(uuid);
            final isLimitReached = viewModel.selectedCategories.length >= 5;

            return Opacity(
              opacity: isLimitReached && !isSelected ? 0.5 : 1.0,
              child: GestureDetector(
                onTap: isLimitReached && !isSelected
                    ? null
                    : () => viewModel.onCategoryToggle(uuid, name!),
                child: _buildCategoryChip(
                  viewModel: viewModel,
                  theme: theme,
                  category: category,
                  isSelected: isSelected,
                ),
              ),
            );
          },
        ),
        if (viewModel.categoriesError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              viewModel.categoriesError!,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required ModelCreatePageViewModel viewModel,
    required ThemeData theme,
    required Map<String, String> category,
    required bool isSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            Icon(Icons.check, size: 16, color: theme.colorScheme.onPrimary),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              category['name']!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(
    ModelCreatePageViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Availability:', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children:
              viewModel.modelAvailabilities?.data.map((availability) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildAvailabilityChip(
                      viewModel: viewModel,
                      theme: theme,
                      availability: availability,
                    ),
                  ),
                );
              }).toList() ??
              [],
        ),
        if (viewModel.availabilityError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              viewModel.availabilityError!,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildAvailabilityChip({
    required ModelCreatePageViewModel viewModel,
    required ThemeData theme,
    required ModelAvailabilityResponseApiModel availability,
  }) {
    final isSelected =
        viewModel.selectedAvailability?.uuid == availability.uuid;

    return GestureDetector(
      onTap: () => viewModel.onAvailabilityChanged(availability),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          availability.availabilityName,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPriceField(ModelCreatePageViewModel viewModel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.modelPriceController,
          decoration: formInputDecoration(
            "Price",
            Icons.attach_money,
          ).copyWith(errorText: viewModel.priceError),
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
        ),
      ],
    );
  }

  Widget _buildAddModelFileButton(
    ModelCreatePageViewModel viewModel,
    ThemeData theme,
  ) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => viewModel.onAddModelFilePressed(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add,
                color: theme.colorScheme.onPrimary,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add model from your phone directory',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (viewModel.selectedModelFileName != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      viewModel.selectedModelFileName!,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: viewModel.onRemoveModelFile,
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (viewModel.modelFileError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                viewModel.modelFileError!,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(ThemeData theme) {
    return Container(
      color: Colors.black54,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
