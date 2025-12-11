import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ActionButtonVariant.filled,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final ActionButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      ActionButtonVariant.filled =>
        icon != null
            ? FilledButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(label),
              )
            : FilledButton(
                onPressed: onPressed,
                child: Text(label),
              ),
      ActionButtonVariant.outlined =>
        icon != null
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(label),
              )
            : OutlinedButton(
                onPressed: onPressed,
                child: Text(label),
              ),
      ActionButtonVariant.text =>
        icon != null
            ? TextButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(label),
              )
            : TextButton(
                onPressed: onPressed,
                child: Text(label),
              ),
    };
  }
}

/// Button variant types
enum ActionButtonVariant {
  filled,
  outlined,
  text,
}
