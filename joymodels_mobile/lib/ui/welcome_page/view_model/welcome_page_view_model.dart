import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/login_page/widgets/login_page_screen.dart';
import 'package:joymodels_mobile/ui/register_page/widgets/register_page_screen.dart';

class WelcomePageViewModel with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> onLoginPressed(BuildContext context) async {
    _setError(null);
    _setLoading(true);
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPageScreen()),
      );
    } catch (e) {
      _setError("Error while opening LoginPageScreen");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> onRegisterPressed(BuildContext context) async {
    _setError(null);
    _setLoading(true);
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegisterPageScreen()),
      );
    } catch (e) {
      _setError("Error while opening RegisterPageScreen");
    } finally {
      _setLoading(false);
    }
  }
}
