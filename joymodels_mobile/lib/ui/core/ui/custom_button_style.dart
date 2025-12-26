import 'package:flutter/material.dart';

ButtonStyle customButtonStyle(BuildContext context) {
  return ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
  );
}
