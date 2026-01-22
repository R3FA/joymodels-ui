import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/model/community_post_type/response_types/community_post_type_response_api_model.dart';
import 'package:joymodels_mobile/ui/community_post_edit_page/view_model/community_post_edit_page_view_model.dart';
import 'package:joymodels_mobile/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/form_input_decoration.dart';
import 'package:joymodels_mobile/ui/core/ui/model_image.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';

class CommunityPostEditPageScreen extends StatefulWidget {
  const CommunityPostEditPageScreen({super.key});

  @override
  State<CommunityPostEditPageScreen> createState() =>
      _CommunityPostEditPageScreenState();
}

class _CommunityPostEditPageScreenState
    extends State<CommunityPostEditPageScreen> {
  late final CommunityPostEditPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<CommunityPostEditPageViewModel>();
    _viewModel.onSessionExpired = _handleSessionExpired;
    _viewModel.onForbidden = _handleForbidden;
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
    final viewModel = context.watch<CommunityPostEditPageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: viewModel.canSave
                    ? () => viewModel.onSubmit(context)
                    : null,
                child: const Text(
                  'Save',
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

  Widget _buildBody(CommunityPostEditPageViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (viewModel.errorMessage != null)
                _buildErrorMessage(viewModel, theme),

              _buildTitleField(viewModel, theme),
              const SizedBox(height: 20),

              _buildDescriptionField(viewModel, theme),
              const SizedBox(height: 20),

              _buildPostTypeSection(viewModel, theme),
              const SizedBox(height: 20),

              _buildYoutubeVideoLinkField(viewModel, theme),
              const SizedBox(height: 20),

              _buildPhotosSection(viewModel, theme),
            ],
          ),
        ),

        if (viewModel.isSubmitting) _buildLoadingOverlay(theme),
      ],
    );
  }

  Widget _buildErrorMessage(
    CommunityPostEditPageViewModel viewModel,
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

  Widget _buildTitleField(
    CommunityPostEditPageViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.titleController,
          decoration: formInputDecoration("Title", Icons.title),
          maxLength: 100,
        ),
      ],
    );
  }

  Widget _buildDescriptionField(
    CommunityPostEditPageViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.descriptionController,
          decoration: formInputDecoration("Description", Icons.description),
          maxLines: 10,
          maxLength: 5000,
        ),
      ],
    );
  }

  Widget _buildPostTypeSection(
    CommunityPostEditPageViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Post Type:', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        if (viewModel.isPostTypesLoading)
          const Center(child: CircularProgressIndicator())
        else
          Row(
            children:
                viewModel.postTypes?.data.map((postType) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: postType != viewModel.postTypes?.data.last
                            ? 8
                            : 0,
                      ),
                      child: _buildPostTypeChip(
                        viewModel: viewModel,
                        theme: theme,
                        postType: postType,
                      ),
                    ),
                  );
                }).toList() ??
                [],
          ),
      ],
    );
  }

  Widget _buildPostTypeChip({
    required CommunityPostEditPageViewModel viewModel,
    required ThemeData theme,
    required CommunityPostTypeResponseApiModel postType,
  }) {
    final isSelected = viewModel.selectedPostType?.uuid == postType.uuid;

    return GestureDetector(
      onTap: () => viewModel.onPostTypeChanged(postType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              Icon(Icons.check, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
            ],
            Text(
              postType.communityPostName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYoutubeVideoLinkField(
    CommunityPostEditPageViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.youtubeVideoLinkController,
          decoration: formInputDecoration(
            "YouTube Video Link (Optional)",
            Icons.video_library,
          ),
          maxLength: 2048,
        ),
      ],
    );
  }

  Widget _buildPhotosSection(
    CommunityPostEditPageViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Photos (Optional):', style: theme.textTheme.titleSmall),
            Text(
              '${viewModel.totalPhotosCount}/${CommunityPostEditPageViewModel.maxPhotos}',
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
            ...viewModel.existingPictureLocations.asMap().entries.map(
              (entry) => _buildExistingPhotoItem(
                viewModel: viewModel,
                theme: theme,
                pictureLocation: entry.value,
                index: entry.key,
              ),
            ),
            ...viewModel.newPhotos.asMap().entries.map(
              (entry) => _buildNewPhotoItem(
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

  Widget _buildExistingPhotoItem({
    required CommunityPostEditPageViewModel viewModel,
    required ThemeData theme,
    required String pictureLocation,
    required int index,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 80,
            height: 80,
            child: ModelImage(
              imageUrl: viewModel.getExistingImageUrl(pictureLocation),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => viewModel.onRemoveExistingPhoto(index),
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

  Widget _buildNewPhotoItem({
    required CommunityPostEditPageViewModel viewModel,
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
            onTap: () => viewModel.onRemoveNewPhoto(index),
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
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'NEW',
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton(
    CommunityPostEditPageViewModel viewModel,
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

  Widget _buildLoadingOverlay(ThemeData theme) {
    return Container(
      color: Colors.black54,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
