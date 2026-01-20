import 'dart:io';

import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/ui/core/ui/user_avatar.dart';
import 'package:joymodels_mobile/ui/settings_page/view_model/settings_page_view_model.dart';
import 'package:joymodels_mobile/ui/home_page/widgets/home_page_screen.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';

class SettingsPageScreen extends StatefulWidget {
  const SettingsPageScreen({super.key});

  @override
  State<SettingsPageScreen> createState() => _SettingsPageScreenState();
}

class _SettingsPageScreenState extends State<SettingsPageScreen>
    with SingleTickerProviderStateMixin {
  late final SettingsPageViewModel _viewModel;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<SettingsPageViewModel>();
    _viewModel.onSessionExpired = _handleSessionExpired;
    _viewModel.onProfileSaved = _handleProfileSaved;
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleProfileSaved() {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePageScreen()),
      (route) => false,
    );
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
    final viewModel = context.watch<SettingsPageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Edit Profile'),
            Tab(text: 'Change Password'),
          ],
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEditProfileTab(viewModel, theme),
                _buildChangePasswordTab(viewModel, theme),
              ],
            ),
    );
  }

  Widget _buildEditProfileTab(
    SettingsPageViewModel viewModel,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfilePicture(viewModel, theme),
          const SizedBox(height: 24),
          _buildTextField(
            controller: viewModel.firstNameController,
            label: 'First Name',
            maxLength: 100,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: viewModel.lastNameController,
            label: 'Last Name',
            maxLength: 100,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: viewModel.nicknameController,
            label: 'Nickname',
            maxLength: 50,
          ),
          const SizedBox(height: 24),
          _buildMessageDisplay(viewModel, theme),
          const SizedBox(height: 16),
          _buildSaveButton(viewModel, theme),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(
    SettingsPageViewModel viewModel,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: viewModel.pickImage,
      child: Stack(
        children: [
          if (viewModel.selectedImagePath != null)
            CircleAvatar(
              radius: 50,
              backgroundImage: FileImage(File(viewModel.selectedImagePath!)),
            )
          else if (viewModel.userUuid != null)
            UserAvatar(
              imageUrl:
                  "${ApiConstants.baseUrl}/users/get/${viewModel.userUuid}/avatar",
              radius: 50,
            )
          else
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.person,
                size: 50,
                color: theme.colorScheme.onSurface,
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordTab(
    SettingsPageViewModel viewModel,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Change Your Password',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your new password below',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildPasswordField(
            controller: viewModel.newPasswordController,
            label: 'New Password',
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: viewModel.confirmPasswordController,
            label: 'Confirm New Password',
          ),
          const SizedBox(height: 24),
          _buildMessageDisplay(viewModel, theme),
          const SizedBox(height: 16),
          _buildChangePasswordButton(viewModel, theme),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        counterText: '',
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      maxLength: 50,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        counterText: '',
      ),
    );
  }

  Widget _buildMessageDisplay(
    SettingsPageViewModel viewModel,
    ThemeData theme,
  ) {
    if (viewModel.errorMessage != null) {
      return Container(
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
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: viewModel.clearMessages,
              iconSize: 18,
            ),
          ],
        ),
      );
    }

    if (viewModel.successMessage != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                viewModel.successMessage!,
                style: const TextStyle(color: Colors.green),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: viewModel.clearMessages,
              iconSize: 18,
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSaveButton(SettingsPageViewModel viewModel, ThemeData theme) {
    final isDisabled = viewModel.isSaving || !viewModel.hasProfileChanges;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : viewModel.saveProfile,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        child: viewModel.isSaving
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : const Text('Save Changes'),
      ),
    );
  }

  Widget _buildChangePasswordButton(
    SettingsPageViewModel viewModel,
    ThemeData theme,
  ) {
    final isDisabled =
        viewModel.isChangingPassword || !viewModel.canChangePassword;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : viewModel.changePassword,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        child: viewModel.isChangingPassword
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : const Text('Change Password'),
      ),
    );
  }
}
