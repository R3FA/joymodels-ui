import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/ui/custom_button_style.dart';
import 'package:joymodels_mobile/ui/core/ui/error_message_text.dart';
import 'package:joymodels_mobile/ui/core/ui/form_input_decoration.dart';
import 'package:joymodels_mobile/ui/core/ui/success_message_text.dart';
import 'package:joymodels_mobile/ui/login_page/view_model/login_page_view_model.dart';
import 'package:provider/provider.dart';

class LoginPageScreen extends StatelessWidget {
  const LoginPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginPageScreenViewModel>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Form(
            key: viewModel.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const CircleAvatar(
                  radius: 46,
                  child: Icon(Icons.person, size: 46),
                ),
                if (viewModel.errorMessage != null)
                  ErrorMessageText(message: viewModel.errorMessage!),
                if (viewModel.successMessage != null)
                  SuccessMessageText(message: viewModel.successMessage!),
                const SizedBox(height: 26),
                TextFormField(
                  controller: viewModel.nicknameController,
                  decoration: formInputDecoration(
                    "Nickname",
                    Icons.person_outline,
                  ),
                  validator: viewModel.validateNickname,
                  autofillHints: const [AutofillHints.username],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: viewModel.passwordController,
                  decoration: formInputDecoration(
                    "Password",
                    Icons.lock_outline,
                  ),
                  obscureText: true,
                  validator: viewModel.validatePassword,
                  autofillHints: const [AutofillHints.password],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: customButtonStyle(context),
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            await viewModel.login(context);
                          },
                    child: viewModel.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : const Text('Login'),
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
