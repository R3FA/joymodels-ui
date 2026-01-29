import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplay({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_outlined,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Connection Error',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
