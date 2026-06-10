import 'package:flutter/material.dart';

class HoverLiftWrapper extends StatefulWidget {
  final Widget child;
  const HoverLiftWrapper({super.key, required this.child});

  @override
  State<HoverLiftWrapper> createState() => _HoverLiftWrapperState();
}

class _HoverLiftWrapperState extends State<HoverLiftWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        child: widget.child,
      ),
    );
  }
}
