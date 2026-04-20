import 'package:flutter/material.dart';

enum AppButtonVariant { primary, outline, secondary }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;
  final double? width;
  final double height;
  final bool isDisabled;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = 56,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutline = variant == AppButtonVariant.outline;
    final bool isSecondary = variant == AppButtonVariant.secondary;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: (isLoading || isDisabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Theme.of(context).colorScheme.surface : (isOutline ? Colors.transparent : Theme.of(context).colorScheme.primary),
          foregroundColor: isOutline || isSecondary ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary,
          elevation: isSecondary ? 2 : 0,
          shadowColor: isSecondary ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          side: isOutline ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2) : (isSecondary ? BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)) : null),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(isOutline || isSecondary ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
