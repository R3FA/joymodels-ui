import 'package:flutter/material.dart';

class ErrorMessageText extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? padding;

  const ErrorMessageText({super.key, required this.message, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 12.0),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
