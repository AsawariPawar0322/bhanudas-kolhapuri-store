import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'animated_orb.dart';
import 'dart:ui';

class VoiceAiOrbButton extends StatefulWidget {
  final VoidCallback onPressed;
  const VoiceAiOrbButton({super.key, required this.onPressed});

  @override
  State<VoiceAiOrbButton> createState() => _VoiceAiOrbButtonState();
}

class _VoiceAiOrbButtonState extends State<VoiceAiOrbButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.4 * _pulseController.value),
                  blurRadius: 20 + (10 * _pulseController.value),
                  spreadRadius: 5 * _pulseController.value,
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.8),
                        AppTheme.primaryDark.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const AnimatedOrb(),
                      const Icon(Icons.mic, color: Colors.white, size: 28),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
