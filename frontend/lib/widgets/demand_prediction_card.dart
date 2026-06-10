import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

import 'hover_lift_wrapper.dart';

class DemandPredictionCard extends StatefulWidget {
  const DemandPredictionCard({super.key});

  @override
  State<DemandPredictionCard> createState() => _DemandPredictionCardState();
}

class _DemandPredictionCardState extends State<DemandPredictionCard> with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final prediction = provider.todayPrediction;
        final demandPercent = prediction?.demandPercentage ?? 73;

        return HoverLiftWrapper(
          child: Container(
            decoration: AppDecorations.glassCard,
            padding: const EdgeInsets.all(20),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Demand",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.2)),
                    ),
                    child: const Text(
                      '🧠 AI ENGINE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Breathtaking Circular AI progress
              Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background Pulse Glow
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.08),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                                          // Background static tracking circle
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 8,
                          backgroundColor: const Color(0xFFF1F5F9), // Slate 100
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFE2E8F0), // Slate 200
                          ),
                        ),
                      ),
                      
                      // Rotating Outer Dash Calibration Ring (Spins continuously)
                      RotationTransition(
                        turns: _spinController,
                        child: CustomPaint(
                          size: const Size(128, 128),
                          painter: _DottedCirclePainter(
                            color: AppTheme.secondaryColor.withOpacity(0.15),
                          ),
                        ),
                      ),
                      
                      // Counter progress circle
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: demandPercent / 100),
                        duration: const Duration(milliseconds: 1600),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                              valueColor: const AlwaysStoppedAnimation(
                                AppTheme.primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Dynamic percentage counter text
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: demandPercent.toDouble()),
                        duration: const Duration(milliseconds: 1600),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${value.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary, // Proper dark slate text
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                prediction?.demandEmoji ?? '📈 HIGH',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryColor), // High-contrast professional blue
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Factor list
              const Text(
                'Contributing Surge Factors',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              
              if (prediction?.factors.festival != null)
                _buildFactor(
                  '🎉',
                  '${prediction!.factors.festival!.name} in ${prediction.factors.festival!.daysUntil}d',
                  '+${(prediction.factors.festival!.impact * 100).toInt()}%',
                  isPositive: true,
                ),
              _buildFactor(
                prediction?.factors.weather.emoji ?? '☀️',
                prediction?.factors.weather.condition ?? 'Clear Tanning Weather',
                '+${prediction?.factors.weather.impact ?? 12}%',
                isPositive: true,
              ),
            ],
          ),
        ));
      },
    );
  }

  Widget _buildFactor(String emoji, String label, String impact, {bool isPositive = true}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Slate 50 background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200 border
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              impact,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isPositive ? AppTheme.accentColor : AppTheme.dangerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  final Color color;
  _DottedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double radius = size.width / 2;

    // Draw little dashboard ticks at 15-degree steps
    for (double i = 0; i < 360; i += 15) {
      final double angle = i * math.pi / 180;
      final double x1 = cx + (radius - 5) * math.cos(angle);
      final double y1 = cy + (radius - 5) * math.sin(angle);
      final double x2 = cx + radius * math.cos(angle);
      final double y2 = cy + radius * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
