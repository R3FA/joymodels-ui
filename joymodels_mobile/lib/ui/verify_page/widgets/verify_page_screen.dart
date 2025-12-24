import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/themes/color_palette.dart';
import 'package:joymodels_mobile/ui/core/ui/form_input_decoration.dart';
import 'package:joymodels_mobile/ui/verify_page/view_model/verify_page_view_model.dart';
import 'package:provider/provider.dart';

class VerifyPageScreen extends StatelessWidget {
  const VerifyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VerifyPageScreenViewModel>();

    return Scaffold(
      backgroundColor: ColorPallete.darkBackground,
      appBar: AppBar(
        backgroundColor: ColorPallete.darkBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'OTP Verification',
          style: TextStyle(
            color: ColorPallete.accent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
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
              CircleAvatar(
                radius: 46,
                backgroundColor: ColorPallete.accent,
                child: Icon(
                  Icons.lock,
                  color: ColorPallete.darkBackground,
                  size: 46,
                ),
              ),
              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
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
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 26),
              TextFormField(
                key: viewModel.formKey,
                controller: viewModel.otpCodeController,
                decoration: formInputDecoration(
                  "Enter OTP code",
                  Icons.vpn_key,
                ),
                style: const TextStyle(color: Colors.white),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.refresh,
                        color: ColorPallete.darkBackground,
                      ),
                      label: viewModel.isRequestingNewOtpCode
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: ColorPallete.darkBackground,
                                strokeWidth: 2.2,
                              ),
                            )
                          : const Text(
                              'Request new OTP',
                              style: TextStyle(
                                color: ColorPallete.darkBackground,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPallete.accent,
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
                    backgroundColor: ColorPallete.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: viewModel.isVerifying
                      ? null
                      : () async {
                          await viewModel.verify();
                        },
                  child: viewModel.isVerifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: ColorPallete.darkBackground,
                            strokeWidth: 2.4,
                          ),
                        )
                      : const Text(
                          'Submit',
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
    );
  }
}
