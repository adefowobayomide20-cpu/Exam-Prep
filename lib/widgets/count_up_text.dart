import 'package:flutter/material.dart';

/// Animates an integer counting up from 0 to [value] whenever [value]
/// changes, formatted with [format] (defaults to plain digits).
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    this.format,
    this.style,
    this.duration = const Duration(milliseconds: 900),
  });

  final int value;
  final String Function(int)? format;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text(format?.call(animatedValue) ?? '$animatedValue', style: style);
      },
    );
  }
}

/// Animates a percentage (0.0-1.0) counting up, formatted as a rounded "%".
class CountUpPercentText extends StatelessWidget {
  const CountUpPercentText({super.key, required this.value, this.style});

  final double value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text('${(animatedValue * 100).round()}%', style: style);
      },
    );
  }
}
