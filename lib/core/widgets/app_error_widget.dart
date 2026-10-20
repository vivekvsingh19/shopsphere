import 'package:flutter/material.dart';

import '../error/app_error.dart';

/// Reusable error display with retry button.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
    this.compact = false,
  });

  final Object error;
  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = error is AppError
        ? (error as AppError).displayMessage
        : error.toString().replaceAll(RegExp(r'.*Error: '), '');

    final icon = _iconForError(error);

    if (compact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.colorScheme.error, size: 40),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onRetry,
            style: FilledButton.styleFrom(minimumSize: const Size(120, 40)),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _titleForError(error),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(160, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForError(Object error) {
    if (error is NetworkError) return Icons.wifi_off_rounded;
    if (error is TimeoutError) return Icons.timer_off_rounded;
    if (error is AuthError) return Icons.lock_outline_rounded;
    if (error is NotFoundError) return Icons.search_off_rounded;
    if (error is ServerError) return Icons.cloud_off_rounded;
    return Icons.error_outline_rounded;
  }

  String _titleForError(Object error) {
    if (error is NetworkError) return 'No Connection';
    if (error is TimeoutError) return 'Request Timed Out';
    if (error is AuthError) return 'Session Expired';
    if (error is NotFoundError) return 'Not Found';
    if (error is ServerError) return 'Server Error';
    return 'Something Went Wrong';
  }
}
