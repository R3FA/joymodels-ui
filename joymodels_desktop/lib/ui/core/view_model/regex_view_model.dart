class RegexValidationViewModel {
  static String? validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return 'Password cannot be empty string';
    }
    final regex = RegExp(
      r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
    );
    if (!regex.hasMatch(password)) {
      return 'Password must be at least 8 characters long and include at least one uppercase letter, one number, and one special character (@\$!%*#?&).';
    }
    return null;
  }

  static String? validateNickname(String? nickname) {
    if (nickname == null || nickname.trim().isEmpty) {
      return 'Nickname cannot be empty string.';
    }
    final regex = RegExp(r'^[a-z0-9]{3,}$');
    if (!regex.hasMatch(nickname)) {
      return 'Nickname must be at least 3 characters long and contain only lowercase letters and numbers.';
    }
    return null;
  }

  static String? validateText(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'Text cannot be empty string.';
    }
    final regex = RegExp(
      r"^[\p{L}\p{Nd}!@#$%^&*()_+/\\<>.,?:;\-' ]+$",
      unicode: true,
    );
    if (!regex.hasMatch(text)) {
      return "Invalid value: Must contain only letters (any language), digits, and the following characters: !@#\$%^&*()_+/\\<>.,?:;-'";
    }
    return null;
  }
}
