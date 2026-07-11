import 'package:flutter/material.dart';

/// A quiz "power-up" button (50-50, Hint, Freeze, …) showing the number of
/// uses left as a badge, disabled once exhausted.
class LifelineButton extends StatelessWidget {
  const LifelineButton({
    super.key,
    required this.icon,
    required this.label,
    required this.usesLeft,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final int usesLeft;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 20, color: enabled ? null : theme.disabledColor),
                Positioned(
                  right: -8,
                  top: -8,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: enabled ? theme.colorScheme.primary : theme.disabledColor,
                    child: Text(
                      '$usesLeft',
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
