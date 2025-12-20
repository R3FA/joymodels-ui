import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/register_page/view_model/register_page_view_model.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:joymodels_mobile/ui/core/themes/color_palette.dart';

class RegisterPageScreen extends StatelessWidget {
  const RegisterPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterPageScreenViewModel>();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: ColorPallete.darkBackground,
      appBar: AppBar(
        backgroundColor: ColorPallete.darkBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Register',
          style: TextStyle(
            color: ColorPallete.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) {
                      viewModel.setAvatar(File(picked.path));
                    }
                  },
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: ColorPallete.accent,
                    backgroundImage: viewModel.avatarImage != null
                        ? FileImage(viewModel.avatarImage!)
                        : null,
                    child: viewModel.avatarImage == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 38,
                            color: ColorPallete.darkBackground,
                          )
                        : null,
                  ),
                ),
                if (viewModel.avatarError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      viewModel.avatarError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: viewModel.firstNameController,
                  decoration: _inputDecoration(
                    'First name',
                    Icons.person_outline,
                  ),
                  validator: viewModel.validateName,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: viewModel.lastNameController,
                  decoration: _inputDecoration(
                    'Last name (optional)',
                    Icons.person_outline,
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (lastName) =>
                      (lastName == null || lastName.trim().isEmpty)
                      ? null
                      : viewModel.validateName(lastName),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: viewModel.nicknameController,
                  decoration: _inputDecoration('Nickname', Icons.face),
                  validator: viewModel.validateNickname,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: viewModel.emailController,
                  decoration: _inputDecoration('Email', Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: viewModel.validateEmail,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: viewModel.passwordController,
                  decoration: _inputDecoration('Šifra', Icons.lock_outline),
                  obscureText: true,
                  validator: viewModel.validatePassword,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 24),
                if (viewModel.submitError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      viewModel.submitError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPallete.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            if (formKey.currentState?.validate() ?? false) {
                              final success = await viewModel.submitForm(
                                context,
                              );
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Registration success!'),
                                  ),
                                );
                              }
                            }
                          },
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: ColorPallete.darkBackground,
                              strokeWidth: 2.6,
                            ),
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(
                              color: ColorPallete.darkBackground,
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: ColorPallete.accent),
      labelText: label,
      labelStyle: const TextStyle(color: ColorPallete.accent),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: ColorPallete.accent),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: ColorPallete.accent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorMaxLines: 6,
      errorStyle: TextStyle(
        color: Colors.redAccent,
        fontWeight: FontWeight.bold,
        fontSize: 14, // Povećaj font
        height: 1.0,
      ),
    );
  }
}
