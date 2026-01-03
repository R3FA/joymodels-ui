import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/ui/custom_button_style.dart';
import 'package:joymodels_mobile/ui/core/ui/error_message_text.dart';
import 'package:joymodels_mobile/ui/core/ui/form_input_decoration.dart';
import 'package:joymodels_mobile/ui/core/ui/success_message_text.dart';
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
              _buildAvatar(theme),
              if (viewModel.errorMessage != null)
                ErrorMessageText(message: viewModel.errorMessage!),
              if (viewModel.successMessage != null)
                SuccessMessageText(message: viewModel.successMessage!),
              const SizedBox(height: 26),
              _buildOtpForm(viewModel, context),
              const SizedBox(height: 16),
              _buildRequestNewOtpButton(viewModel, context),
              const SizedBox(height: 20),
              _buildVerifyButton(viewModel, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: CircleAvatar(radius: 46, child: Icon(Icons.lock, size: 46)),
    );
  }

  Widget _buildOtpForm(
    VerifyPageScreenViewModel viewModel,
    BuildContext context,
  ) {
    return Form(
      key: viewModel.formKey,
      child: TextFormField(
        controller: viewModel.otpCodeController,
        decoration: formInputDecoration('Enter OTP code', Icons.vpn_key),
        maxLength: 12,
        buildCounter:
            (_, {required currentLength, required isFocused, maxLength}) =>
                null,
        keyboardType: TextInputType.text,
        textAlign: TextAlign.left,
        validator: viewModel.validateOtpCode,
        autofillHints: const [AutofillHints.oneTimeCode],
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => viewModel.verify(context),
      ),
    );
  }

  Widget _buildRequestNewOtpButton(
    VerifyPageScreenViewModel viewModel,
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: customButtonStyle(context),
        icon: viewModel.isRequestingNewOtpCode
            ? const SizedBox.shrink()
            : const Icon(Icons.refresh),
        label: viewModel.isRequestingNewOtpCode
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              )
            : const Text('Request new OTP'),
        onPressed: viewModel.isRequestingNewOtpCode
            ? null
            : () async => viewModel.requestNewOtpCode(context),
      ),
    );
  }

  Widget _buildVerifyButton(
    VerifyPageScreenViewModel viewModel,
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: customButtonStyle(context),
        onPressed: viewModel.isVerifying
            ? null
            : () async => viewModel.verify(context),
        child: viewModel.isVerifying
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            : const Text('Verify'),
      ),
    );
  }
}
