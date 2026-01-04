import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/ui/custom_button_style.dart';
import 'package:joymodels_mobile/ui/core/ui/error_message_text.dart';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 40),
              if (viewModel.errorMessage != null)
                ErrorMessageText(message: viewModel.errorMessage!),
              if (viewModel.isLoading) _buildLoadingIndicator(),
              _buildLoginButton(viewModel, context),
              const SizedBox(height: 20),
              _buildRegisterButton(viewModel, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Welcome',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Explore awesome 3D models & artists!',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLoginButton(
    WelcomePageViewModel viewModel,
    BuildContext context,
  ) {
    return SizedBox(
      width: 220,
      child: ElevatedButton(
        style: customButtonStyle(context),
        onPressed: viewModel.isLoading
            ? null
            : () => viewModel.onLoginPressed(context),
        child: const Text('Login'),
      ),
    );
  }

  Widget _buildRegisterButton(
    WelcomePageViewModel viewModel,
    BuildContext context,
  ) {
    return SizedBox(
      width: 220,
      child: FilledButton.tonal(
        style: customButtonStyle(context),
        onPressed: viewModel.isLoading
            ? null
            : () => viewModel.onRegisterPressed(context),
        child: const Text('Register'),
      ),
    );
  }
}
