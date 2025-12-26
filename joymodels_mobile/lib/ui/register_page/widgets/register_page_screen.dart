import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/ui/custom_button_style.dart';
import 'package:joymodels_mobile/ui/core/ui/form_input_decoration.dart';
import 'package:joymodels_mobile/ui/core/ui/success_snack_bar.dart';
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
                GestureDetector(
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
                ),
                if (viewModel.profilePictureErrorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: Text(
                        viewModel.profilePictureErrorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: viewModel.firstNameController,
                  decoration: formInputDecoration(
                    'First name',
                    Icons.person_outline,
                  ),
                  validator: viewModel.validateName,
                  autofillHints: const [AutofillHints.givenName],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: viewModel.lastNameController,
                  decoration: formInputDecoration(
                    'Last name',
                    Icons.person_outline,
                  ),
                  validator: (lastName) =>
                      (lastName == null || lastName.trim().isEmpty)
                      ? null
                      : viewModel.validateName(lastName),
                  autofillHints: const [AutofillHints.familyName],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: viewModel.nicknameController,
                  decoration: formInputDecoration('Nickname', Icons.face),
                  validator: viewModel.validateNickname,
                  autofillHints: const [AutofillHints.nickname],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: viewModel.emailController,
                  decoration: formInputDecoration(
                    'Email',
                    Icons.email_outlined,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: viewModel.validateEmail,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: viewModel.passwordController,
                  decoration: formInputDecoration(
                    'Password',
                    Icons.lock_outline,
                  ),
                  obscureText: true,
                  validator: viewModel.validatePassword,
                  autofillHints: const [AutofillHints.newPassword],
                ),
                const SizedBox(height: 24),
                if (viewModel.responseErrorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      viewModel.responseErrorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: customButtonStyle(context),
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            final success = await viewModel.submitForm(context);
                            if (!context.mounted) return;
                            if (success) {
                              showSuccessSnackBar(
                                context,
                                'Registration success',
                              );
                            }
                          },
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.6),
                          )
                        : const Text('Register'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
