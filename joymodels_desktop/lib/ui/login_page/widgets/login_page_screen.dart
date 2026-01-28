import 'package:flutter/material.dart';
import 'package:joymodels_desktop/ui/login_page/view_model/login_page_view_model.dart';
import 'package:provider/provider.dart';

class LoginPageScreen extends StatelessWidget {
  const LoginPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Row(
        children: [
          // Left panel - Branding
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.view_in_ar,
                            size: 32,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'JoyModels',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Headline
                    Text(
                      'Admin\nControl Panel',
                      style: TextStyle(
                        fontSize: size.width > 1200 ? 48 : 36,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Manage users, content, and platform\nsettings from one place.',
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    // Features
                    _buildFeatureItem(
                      theme,
                      Icons.admin_panel_settings_outlined,
                      'Full platform administration',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      theme,
                      Icons.manage_accounts_outlined,
                      'User & content moderation',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      theme,
                      Icons.analytics_outlined,
                      'Analytics & reporting tools',
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          // Right panel - Login form
          Expanded(
            flex: 4,
            child: Container(
              color: theme.colorScheme.surface,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: const _LoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.onPrimary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginPageScreenViewModel>();
    final theme = Theme.of(context);

    return Form(
      key: viewModel.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Sign In',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your credentials to access your account',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),

          // Error/Success messages
          if (viewModel.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (viewModel.successMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      viewModel.successMessage!,
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Nickname field
          Text(
            'Nickname',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: viewModel.nicknameController,
            decoration: InputDecoration(
              hintText: 'Enter your nickname',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              errorMaxLines: 3,
            ),
            validator: viewModel.validateNickname,
            maxLength: 50,
            autofillHints: const [AutofillHints.username],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),

          // Password field
          Text(
            'Password',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: viewModel.passwordController,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              errorMaxLines: 3,
            ),
            obscureText: _obscurePassword,
            validator: viewModel.validatePassword,
            maxLength: 50,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => viewModel.login(context),
          ),
          const SizedBox(height: 32),

          // Login button
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async => viewModel.login(context),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
