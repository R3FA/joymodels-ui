import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/data/model/model_availability/response_types/model_availability_response_api_model.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/form_input_decoration.dart';
import 'package:joymodels_mobile/ui/core/ui/model_image.dart';
import 'package:joymodels_mobile/ui/core/ui/navigation_bar/widgets/navigation_bar_screen.dart';
import 'package:joymodels_mobile/ui/menu_drawer/widgets/menu_drawer.dart';
import 'package:joymodels_mobile/ui/model_edit_page/view_model/model_edit_page_view_model.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';

class ModelEditPageScreen extends StatefulWidget {
  final ModelResponseApiModel model;
  const ModelEditPageScreen({super.key, required this.model});

  @override
  State<ModelEditPageScreen> createState() => _ModelEditPageScreenState();
}

class _ModelEditPageScreenState extends State<ModelEditPageScreen> {
  late final ModelEditPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ModelEditPageViewModel>();
    _viewModel.onSessionExpired = _handleSessionExpired;
    _viewModel.onForbidden = _handleForbidden;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init(widget.model);
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
    return ChangeNotifierProvider<ModelEditPageViewModel>.value(
      value: _viewModel,
      child: Consumer<ModelEditPageViewModel>(
        builder: (context, viewModel, _) {
          final theme = Theme.of(context);
          return Scaffold(
            endDrawer: const MenuDrawer(),
            bottomNavigationBar: const NavigationBarScreen(),
            appBar: AppBar(
              title: const Text('Edit model'),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: viewModel.isSaving
                          ? null
                          : () async {
                              await viewModel.onSubmit(context);
                            },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Stack(
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
                    ],
                  ),
                ),

                if (viewModel.isSaving) _buildLoadingOverlay(theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorMessage(ModelEditPageViewModel viewModel, ThemeData theme) {
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

  Widget _buildNameField(ModelEditPageViewModel viewModel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.nameController,
          decoration: formInputDecoration(
            "Name",
            Icons.arrow_forward_ios_rounded,
          ),
          maxLength: 100,
        ),
      ],
    );
  }

  Widget _buildDescriptionField(
    ModelEditPageViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.descriptionController,
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

  Widget _buildPhotosSection(
    ModelEditPageViewModel viewModel,
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
              '${viewModel.modelPictures.length - viewModel.modelPicturesToDelete.length + viewModel.modelPicturesToInsert.length}/${ModelEditPageViewModel.maxPhotos}',
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
            ...viewModel.modelPictures
                .where(
                  (picture) => !viewModel.isPictureMarkedForDelete(
                    picture.pictureLocation,
                  ),
                )
                .map(
                  (picture) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: ModelImage(
                            imageUrl:
                                "${ApiConstants.baseUrl}/models/get/${viewModel.originalModel.uuid}/images/${Uri.encodeComponent(picture.pictureLocation)}",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (viewModel.showRemoveButtonForServerPicture(
                        picture.pictureLocation,
                      ))
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => viewModel.markPictureForDelete(
                              picture.pictureLocation,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ...viewModel.modelPicturesToInsert.map(
              (photo) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      photo.bytes,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => viewModel.onRemovePhoto(photo),
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
              ),
            ),
            if (viewModel.canAddMorePhotos)
              GestureDetector(
                onTap: viewModel.onAddPhotoPressed,
                onLongPress: viewModel.onAddMultiplePhotosPressed,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection(
    ModelEditPageViewModel viewModel,
    ThemeData theme,
  ) {
    final searchText = viewModel.categorySearchController.text.toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          onChanged: (value) => viewModel.getCategories(categoryName: value),
          controller: viewModel.categorySearchController,
          decoration: formInputDecoration("Search a category", Icons.search),
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (context) {
            final displayedCategories = viewModel.combinedCategories(
              searchText,
            );

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.5,
              ),
              itemCount: displayedCategories.length,
              itemBuilder: (context, index) {
                final category = displayedCategories[index];
                final isSelected = viewModel.isCategorySelected(category.uuid);
                final isLimitReached = viewModel.modelsCategories.length >= 5;

                return Opacity(
                  opacity: isLimitReached && !isSelected ? 0.5 : 1.0,
                  child: GestureDetector(
                    onTap: isLimitReached && !isSelected
                        ? null
                        : () => viewModel.onCategoryToggle(category),
                    child: _buildCategoryChip(
                      theme: theme,
                      category: category,
                      isSelected: isSelected,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required ThemeData theme,
    required CategoryResponseApiModel category,
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
              category.categoryName,
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
    ModelEditPageViewModel viewModel,
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
      ],
    );
  }

  Widget _buildAvailabilityChip({
    required ModelEditPageViewModel viewModel,
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

  Widget _buildPriceField(ModelEditPageViewModel viewModel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.priceController,
          decoration: formInputDecoration("Price", Icons.attach_money),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay(ThemeData theme) {
    return Container(
      color: Colors.black54,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
