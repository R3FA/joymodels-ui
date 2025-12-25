import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/ui/form_input_decoration.dart';
import 'package:joymodels_mobile/ui/core/ui/success_snack_bar.dart';
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
        title: const Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
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
                CircleAvatar(
                  radius: 46,
                  child: const Icon(Icons.person, size: 46),
                ),
                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 26),
                TextFormField(
                  controller: viewModel.nicknameController,
                  decoration: formInputDecoration(
                    "Nickname",
                    Icons.person_outline,
                  ),
                  style: const TextStyle(),
                  validator: viewModel.validateNickname,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: viewModel.passwordController,
                  decoration: formInputDecoration(
                    "Password",
                    Icons.lock_outline,
                  ),
                  style: const TextStyle(),
                  obscureText: true,
                  validator: viewModel.validatePassword,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            if (await viewModel.login(context)) {
                              if (context.mounted &&
                                  !viewModel.isVerifyScreenLoading) {
                                showSuccessSnackBar(context, 'Login success!');
                              }
                            }
                          },
                    child: viewModel.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
