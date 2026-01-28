import 'package:flutter/material.dart';

class CommunityPageViewModel with ChangeNotifier {
  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  bool _isInitialized = false;
  bool isLoading = false;
  String? errorMessage;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  void clearErrorMessage() {
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}
