import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ForecastChart extends StatelessWidget {
  const ForecastChart({super.key});

  @override
  Widget build(BuildContext context) {
    final forecast = [
      {'day': 'Mon', 'value': 45, 'today': false, 'peak': false},
      {'day': 'Tue', 'value': 62, 'today': false, 'peak': false},
      {'day': 'Wed', 'value': 78, 'today': false, 'peak': false},
      {'day': 'Thu', 'value': 73, 'today': true, 'peak': false},
      {'day': 'Fri', 'value': 89, 'today': false, 'peak': false},
      {'day': 'Sat', 'value': 95, 'today': false, 'peak': true},
      {'day': 'Sun', 'value': 67, 'today': false, 'peak': false},
    ];

    return Container(
      decoration: AppDecorations.glassCard,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('7-Day Forecast', style: Theme.of(context).textTheme.titleMedium),
              Text('Updated 2m ago', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: forecast.map((day) {
                final isToday = day['today'] as bool;
                final isPeak = day['peak'] as bool;
                final value = day['value'] as int;

                LinearGradient gradient;
                if (isPeak) {
                  gradient = AppTheme.warmGradient;
                } else if (isToday) {
                  gradient = AppTheme.accentGradient;
                } else {
                  gradient = AppTheme.primaryGradient;
                }

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: value / 100),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, animValue, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isPeak) const Padding(padding: EdgeInsets.only(bottom: 4), child: Text('🔥', style: TextStyle(fontSize: 12))),
                        Container(
                          width: 32,
                          height: 90 * animValue,
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            boxShadow: [BoxShadow(color: gradient.colors.first.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isToday ? 'Today' : day['day'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: isToday ? AppTheme.accentColor : AppTheme.textSecondary,
                            fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      children: [
                        TextSpan(text: 'Prepare '),
                        TextSpan(text: '23 extra pairs', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        TextSpan(text: " for Saturday's rush"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
