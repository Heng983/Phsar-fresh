import 'package:flutter/widgets.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';

/// Gently scales its child down while pressed.
///
/// Uses a [Listener], so it never competes with the child's own tap handling.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.scale = .97});

  final Widget child;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _set(true),
    onPointerUp: (_) => _set(false),
    onPointerCancel: (_) => _set(false),
    child: AnimatedScale(
      scale: _pressed ? widget.scale : 1,
      duration: AppMotion.of(context, AppMotion.fast),
      curve: AppMotion.curve,
      child: widget.child,
    ),
  );
}
