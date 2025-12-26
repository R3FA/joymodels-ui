import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/ui/custom_button_style.dart';
import 'package:joymodels_mobile/ui/core/ui/form_input_decoration.dart';
import 'package:joymodels_mobile/ui/verify_page/view_model/verify_page_view_model.dart';
import 'package:provider/provider.dart';

class VerifyPageScreen extends StatelessWidget {
  const VerifyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VerifyPageScreenViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('OTP Verification'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const CircleAvatar(radius: 46, child: Icon(Icons.lock, size: 46)),
              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    viewModel.errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (viewModel.successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    viewModel.successMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 26),
              Form(
                key: viewModel.formKey,
                child: TextFormField(
                  controller: viewModel.otpCodeController,
                  decoration: formInputDecoration(
                    "Enter OTP code",
                    Icons.vpn_key,
                  ),
                  maxLength: 12,
                  buildCounter:
                      (
                        _, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  obscureText: false,
                  validator: viewModel.validateOtpCode,
                  autofillHints: const [AutofillHints.oneTimeCode],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: customButtonStyle(context),
                      icon: const Icon(Icons.refresh),
                      label: viewModel.isRequestingNewOtpCode
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                              ),
                            )
                          : const Text('Request new OTP'),
                      onPressed: viewModel.isRequestingNewOtpCode
                          ? null
                          : () async {
                              await viewModel.requestNewOtpCode();
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: customButtonStyle(context),
                  onPressed: viewModel.isVerifying
                      ? null
                      : () async {
                          await viewModel.verify(context);
                        },
                  child: viewModel.isVerifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : const Text('Verify'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
