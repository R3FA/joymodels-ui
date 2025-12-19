import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/themes/color_palette.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_constants.dart';
import 'package:provider/provider.dart';
import '../view_model/welcome_page_view_model.dart';

class WelcomePageScreen extends StatelessWidget {
  const WelcomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WelcomePageViewModel>();

    return Scaffold(
      backgroundColor: ColorPallete.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              WelcomePageConstants.welcomePageMainTextConstant,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: ColorPallete.accent,
                letterSpacing: 1.3,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              WelcomePageConstants.welcomePageDescriptionTextConstant,
              style: TextStyle(fontSize: 18, color: Colors.white70),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: CircularProgressIndicator(color: ColorPallete.accent),
              ),

            SizedBox(
              width: 220,
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
                    : () => viewModel.onLoginPressed(context),
                child: Text(
                  WelcomePageConstants.welcomePageLoginTextConstant,
                  style: TextStyle(
                    color: ColorPallete.darkBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 220,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ColorPallete.accent, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: viewModel.isLoading
                    ? null
                    : () => viewModel.onRegisterPressed(context),
                child: Text(
                  WelcomePageConstants.welcomePageRegisterTextConstant,
                  style: TextStyle(
                    color: ColorPallete.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
