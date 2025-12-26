import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/ui/custom_button_style.dart';
import 'package:provider/provider.dart';
import '../view_model/welcome_page_view_model.dart';

class WelcomePageScreen extends StatelessWidget {
  const WelcomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WelcomePageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Explore awesome 3D models & artists!",
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  viewModel.errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: CircularProgressIndicator(),
              ),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                style: customButtonStyle(context),
                onPressed: viewModel.isLoading
                    ? null
                    : () => viewModel.onLoginPressed(context),
                child: const Text("Login"),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: FilledButton.tonal(
                style: customButtonStyle(context),
                onPressed: viewModel.isLoading
                    ? null
                    : () => viewModel.onRegisterPressed(context),
                child: const Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
