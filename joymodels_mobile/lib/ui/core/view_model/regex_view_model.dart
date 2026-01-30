class RegexValidationViewModel {
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email cannot be empty string';
    }
    final regex = RegExp(r'^(?=.{1,255})[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(email)) {
      return 'Invalid format. The value must be a valid email address without spaces.';
    }
    return null;
  }

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

  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name cannot be empty string.';
    }
    final regex = RegExp(r'^[A-Z][a-z]{1,}$');
    if (!regex.hasMatch(name)) {
      return 'First or Last name must begin with a capital letter and contain only lowercase letters after.';
    }
    return null;
  }

  static String? validateOtpCode(String? otpCode) {
    if (otpCode == null || otpCode.trim().isEmpty) {
      return 'OTP Code cannot be empty string.';
    }
    final regex = RegExp(r'^[A-Z0-9]{12}$');
    if (!regex.hasMatch(otpCode)) {
      return 'The value must be exactly 12 characters long and contain only uppercase letters and numbers.';
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

  static String? validateYoutubeVideoLink(String? url) {
    if (url == null || url.trim().isEmpty) {
      return 'Url cannot be empty string.';
    }
    final regex = RegExp(
      r'^https:\/\/(www\.)?(youtube\.com|youtu\.be)(\/[-a-zA-Z0-9()@:%_\+.~#?&//=]{0,2025})$',
    );
    if (!regex.hasMatch(url)) {
      return 'Invalid URL format. Please provide a valid YouTube link (youtube.com or youtu.be) starting with https://';
    }
    return null;
  }

  static String? extractYoutubeVideoId(String? url) {
    if (url == null || url.isEmpty) return null;

    final regex = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]+)',
    );
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  static String? validatePrice(String? price) {
    if (price == null || price.trim().isEmpty) {
      return 'Price cannot be empty string.';
    }
    final regex = RegExp(r'^\d*\. ?\d{0,2}');

    if (!regex.hasMatch(price)) {
      return 'Invalid price format. Please provide a valid price with up to two decimal places.';
    }

    final parsed = double.tryParse(price) ?? 0;
    if (parsed <= 0) {
      return 'Price must be greater than 0.';
    }
    if (parsed > 5000) {
      return 'Price must not exceed \$5000.';
    }

    return null;
  }
}
