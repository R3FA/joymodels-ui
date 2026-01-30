import 'package:flutter/services.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final cents = int.tryParse(digits) ?? 0;
    final formatted = (cents / 100).toStringAsFixed(2);

    if (RegexValidationViewModel.validatePrice(formatted) != null) {
      return oldValue;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
