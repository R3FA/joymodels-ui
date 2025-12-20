import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/themes/color_palette.dart';

InputDecoration formInputDecoration(String label, IconData icon) {
  return InputDecoration(
    prefixIcon: Icon(icon, color: ColorPallete.accent),
    labelText: label,
    labelStyle: const TextStyle(color: ColorPallete.accent),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: ColorPallete.accent),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: ColorPallete.accent, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    errorMaxLines: 6,
    errorStyle: const TextStyle(
      color: Colors.redAccent,
      fontWeight: FontWeight.bold,
      fontSize: 14,
      height: 1.0,
    ),
  );
}
