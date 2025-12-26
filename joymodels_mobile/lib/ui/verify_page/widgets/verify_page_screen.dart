import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/ui/form_input_decoration.dart';
import 'package:joymodels_mobile/ui/verify_page/view_model/verify_page_view_model.dart';
import 'package:provider/provider.dart';

class VerifyPageScreen extends StatelessWidget {
  const VerifyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VerifyPageScreenViewModel>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(),
        title: const Text(
          'OTP Verification',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              CircleAvatar(radius: 46, child: Icon(Icons.lock, size: 46)),
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
              if (viewModel.successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    viewModel.successMessage!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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
                  style: const TextStyle(),
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  maxLength: 12,
                  buildCounter:
                      (
                        _, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                  obscureText: false,
                  validator: viewModel.validateOtpCode,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: viewModel.isRequestingNewOtpCode
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                              ),
                            )
                          : const Text(
                              'Request new OTP',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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
                      : const Text(
                          'Submit',
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
    );
  }
}
