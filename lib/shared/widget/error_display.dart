import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/internalization/app_strings.dart';

/// Common error display widget
class ErrorDisplay extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorDisplay({
    super.key,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message ?? AppStrings.genericErrorMessage.tr,
            style: Styles.mediumTextStyle(),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Retry"),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact error message for inline use
class InlineError extends StatelessWidget {
  final String message;
  final IconData icon;

  const InlineError({
    super.key,
    required this.message,
    this.icon = Icons.error,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.red,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
