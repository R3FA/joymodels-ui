import 'package:flutter/material.dart';

InputDecoration formInputDecoration(String label, IconData icon) {
  return InputDecoration(
    prefixIcon: Icon(icon),
    labelText: label,
    labelStyle: const TextStyle(),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    errorMaxLines: 6,
    errorStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      height: 1.0,
    ),
  );
}
