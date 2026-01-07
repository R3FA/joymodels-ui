import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joymodels_mobile/ui/core/ui/form_input_decoration.dart';
import 'package:joymodels_mobile/ui/core/ui/navigation_bar/widgets/navigation_bar_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ModelCreatePageViewModel>();
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
    final viewModel = context.watch<ModelCreatePageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: const NavigationBarScreen(),
      appBar: AppBar(title: const Text('Add model'), centerTitle: true),
      body: _buildBody(viewModel, theme),
    );
  }

  Widget _buildBody(ModelCreatePageViewModel viewModel, ThemeData theme) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (viewModel.errorMessage != null)
                _buildErrorMessage(viewModel, theme),

              _buildNameField(viewModel, theme),
              const SizedBox(height: 20),

              _buildDescriptionField(viewModel, theme),
              const SizedBox(height: 20),

              _buildPhotosSection(viewModel, theme),
              const SizedBox(height: 20),

              _buildCategorySection(viewModel, theme),
              const SizedBox(height: 20),

              _buildAvailabilitySection(viewModel, theme),
              const SizedBox(height: 20),

              _buildPriceField(viewModel, theme),
              const SizedBox(height: 32),

              _buildAddModelFileButton(viewModel, theme),
            ],
          ),
        ),

        if (viewModel.isSubmitting) _buildLoadingOverlay(theme),
      ],
    );
  }

  // ==================== ERROR MESSAGE ====================

  Widget _buildErrorMessage(
    ModelCreatePageViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              viewModel.errorMessage!,
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: viewModel.clearError,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ==================== NAME FIELD ====================

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
          ),
          maxLength: 100,
        ),
      ],
    );
  }

  // ==================== DESCRIPTION FIELD ====================

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
          ),
          maxLines: 10,
          maxLength: 5000,
        ),
      ],
    );
  }

  // ==================== PHOTOS SECTION ====================

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

  // ==================== CATEGORY SECTION ====================

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

  // ==================== AVAILABILITY SECTION ====================

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
          children: [
            Expanded(
              child: _buildAvailabilityChip(
                viewModel: viewModel,
                theme: theme,
                availability: ModelAvailability.store,
                label: 'Store',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAvailabilityChip(
                viewModel: viewModel,
                theme: theme,
                availability: ModelAvailability.communityChallenge,
                label: 'Community\nChallenge',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailabilityChip({
    required ModelCreatePageViewModel viewModel,
    required ThemeData theme,
    required ModelAvailability availability,
    required String label,
  }) {
    final isSelected = viewModel.selectedAvailability == availability;

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
          label,
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

  // ==================== PRICE FIEL221D ====================

  Widget _buildPriceField(ModelCreatePageViewModel viewModel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.modelPriceController,
          decoration: formInputDecoration("Price", Icons.attach_money),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  // ==================== ADD MODEL FILE BUTTON ====================

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
        ],
      ),
    );
  }

  // ==================== LOADING OVERLAY ====================

  Widget _buildLoadingOverlay(ThemeData theme) {
    return Container(
      color: Colors.black54,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
