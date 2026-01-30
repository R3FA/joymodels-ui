import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/ui/custom_button_style.dart';
import 'package:joymodels_mobile/ui/core/ui/error_message_text.dart';
import 'package:joymodels_mobile/ui/core/ui/form_input_decoration.dart';
import 'package:joymodels_mobile/ui/core/ui/success_message_text.dart';
import 'package:joymodels_mobile/ui/register_page/view_model/register_page_view_model.dart';
import 'package:provider/provider.dart';

class RegisterPageScreen extends StatelessWidget {
  const RegisterPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterPageScreenViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Register'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Form(
            key: viewModel.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProfilePicture(viewModel),
                if (viewModel.profilePictureErrorMessage != null)
                  ErrorMessageText(
                    message: viewModel.profilePictureErrorMessage!,
                  ),
                if (viewModel.successMessage != null)
                  SuccessMessageText(message: viewModel.successMessage!),
                const SizedBox(height: 18),
                _buildFirstNameField(viewModel),
                const SizedBox(height: 12),
                _buildLastNameField(viewModel),
                const SizedBox(height: 12),
                _buildNicknameField(viewModel),
                const SizedBox(height: 12),
                _buildEmailField(viewModel),
                const SizedBox(height: 12),
                _buildPasswordField(viewModel),
                const SizedBox(height: 12),
                _buildConfirmPasswordField(viewModel, context),
                const SizedBox(height: 24),
                if (viewModel.responseErrorMessage != null)
                  _buildResponseError(viewModel, theme),
                _buildRegisterButton(viewModel, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(RegisterPageScreenViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.pickUserProfilePicture,
      child: CircleAvatar(
        radius: 44,
        backgroundImage: viewModel.userProfilePicture != null
            ? FileImage(viewModel.userProfilePicture!)
            : null,
        child: viewModel.userProfilePicture == null
            ? const Icon(Icons.camera_alt, size: 38)
            : null,
      ),
    );
  }

  Widget _buildFirstNameField(RegisterPageScreenViewModel viewModel) {
    return TextFormField(
      controller: viewModel.firstNameController,
      decoration: formInputDecoration('First name', Icons.person_outline),
      validator: viewModel.validateName,
      maxLength: 100,
      autofillHints: const [AutofillHints.givenName],
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildLastNameField(RegisterPageScreenViewModel viewModel) {
    return TextFormField(
      controller: viewModel.lastNameController,
      decoration: formInputDecoration('Last name', Icons.person_outline),
      validator: viewModel.validateName,
      maxLength: 100,
      autofillHints: const [AutofillHints.familyName],
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildNicknameField(RegisterPageScreenViewModel viewModel) {
    return TextFormField(
      controller: viewModel.nicknameController,
      decoration: formInputDecoration('Nickname', Icons.face),
      validator: viewModel.validateNickname,
      maxLength: 50,
      autofillHints: const [AutofillHints.nickname],
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildEmailField(RegisterPageScreenViewModel viewModel) {
    return TextFormField(
      controller: viewModel.emailController,
      decoration: formInputDecoration('Email', Icons.email_outlined),
      keyboardType: TextInputType.emailAddress,
      validator: viewModel.validateEmail,
      maxLength: 100,
      autofillHints: const [AutofillHints.email],
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPasswordField(RegisterPageScreenViewModel viewModel) {
    return TextFormField(
      controller: viewModel.passwordController,
      decoration: formInputDecoration('Password', Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: viewModel.togglePasswordVisibility,
        ),
      ),
      obscureText: viewModel.obscurePassword,
      validator: viewModel.validatePassword,
      maxLength: 50,
      autofillHints: const [AutofillHints.newPassword],
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildConfirmPasswordField(
    RegisterPageScreenViewModel viewModel,
    BuildContext context,
  ) {
    return TextFormField(
      controller: viewModel.confirmPasswordController,
      decoration: formInputDecoration('Confirm Password', Icons.lock_outline)
          .copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: viewModel.toggleConfirmPasswordVisibility,
            ),
          ),
      obscureText: viewModel.obscureConfirmPassword,
      validator: viewModel.validateConfirmPassword,
      maxLength: 50,
      autofillHints: const [AutofillHints.newPassword],
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => viewModel.submitForm(context),
    );
  }

  Widget _buildResponseError(
    RegisterPageScreenViewModel viewModel,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        viewModel.responseErrorMessage!,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRegisterButton(
    RegisterPageScreenViewModel viewModel,
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: customButtonStyle(context),
        onPressed: viewModel.isLoading
            ? null
            : () async => viewModel.submitForm(context),
        child: viewModel.isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              )
            : const Text('Register'),
      ),
    );
  }
}
