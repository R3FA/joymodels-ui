import 'package:flutter/material.dart';

class SuccessMessageText extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? padding;

  const SuccessMessageText({super.key, required this.message, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 12.0),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
