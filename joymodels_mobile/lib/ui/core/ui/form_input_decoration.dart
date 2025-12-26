import 'package:flutter/material.dart';

InputDecoration formInputDecoration(String label, IconData icon) {
  return InputDecoration(
    prefixIcon: Icon(icon),
    labelText: label,
    border: const OutlineInputBorder(),
    errorMaxLines: 6,
  );
}
