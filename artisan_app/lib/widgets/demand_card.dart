import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DemandCard extends StatelessWidget {
  const DemandCard({super.key});

  @override
  Widget build(BuildContext context) {
    const demandPercent = 73;

    return Container(
      decoration: AppDecorations.glassCard,
      padding: const EdgeInsets.all(12),  // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Today's Demand", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('🧠 AI', style: TextStyle(fontSize: 9)),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: demandPercent / 100),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 6,
                            strokeCap: StrokeCap.round,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                          ),
                        );
                      },
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('$demandPercent%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const Text('📈', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          _factor('🎉', 'Festival in 3 days', '+23%'),
          const SizedBox(height: 4),
          _factor('☀️', 'Clear weather', '+12%'),
        ],
      ),
    );
  }

  Widget _factor(String emoji, String label, String impact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary))),
          Text(impact, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accentColor)),
        ],
      ),
    );
  }
}
