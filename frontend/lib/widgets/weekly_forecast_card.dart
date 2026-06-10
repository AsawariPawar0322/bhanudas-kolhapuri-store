import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'hover_lift_wrapper.dart';

class WeeklyForecastCard extends StatefulWidget {
  const WeeklyForecastCard({super.key});

  @override
  State<WeeklyForecastCard> createState() => _WeeklyForecastCardState();
}

class _WeeklyForecastCardState extends State<WeeklyForecastCard> {
  int _selectedDayIndex = 5; // Default is Saturday (the peak demand day)

  final List<Map<String, dynamic>> _dayInsights = [
    {
      'day': 'Monday',
      'demand': '45 pairs',
      'emoji': '📈',
      'color': AppTheme.primaryColor,
      'text': 'Moderate beginning. Optimal window for machine calibration, thread preparation, and initial leather tanning audits.',
    },
    {
      'day': 'Tuesday',
      'demand': '62 pairs',
      'emoji': '🔨',
      'color': AppTheme.primaryColor,
      'text': 'Crafting speed steady. AI recommends preparing base templates for size 8 & 9 which are highly requested this week.',
    },
    {
      'day': 'Wednesday',
      'demand': '78 pairs',
      'emoji': '🎨',
      'color': AppTheme.primaryColor,
      'text': 'Demand rising. Custom detailing and velvet-lining cuts should be finalized today to meet co-op courier slots.',
    },
    {
      'day': 'Thursday',
      'demand': '73 pairs',
      'emoji': '⚡',
      'color': AppTheme.secondaryColor,
      'text': 'Current Workload is active. Focus on completing pending reviews and scheduling deliveries with co-op partners.',
    },
    {
      'day': 'Friday',
      'demand': '89 pairs',
      'emoji': '📦',
      'color': AppTheme.primaryColor,
      'text': 'Pre-weekend rush build-up. Pre-cut sienna leather borders now to ensure rapid fabrication during Saturday\'s spike.',
    },
    {
      'day': 'Saturday',
      'demand': '95 pairs',
      'emoji': '🔥',
      'color': AppTheme.accentColor,
      'text': 'Peak Diwali Festival demand expected! Keep express fabrication lines active. Estimated dispatch window: 1-3 days.',
    },
    {
      'day': 'Sunday',
      'demand': '67 pairs',
      'emoji': '☕',
      'color': AppTheme.primaryColor,
      'text': 'Post-peak cool down. Perfect window for raw material auditing, restocking leather, and syncing offline queues.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final forecast = provider.weeklyForecast.isNotEmpty
            ? provider.weeklyForecast
            : _getSampleForecast();

        final activeInsight = _dayInsights[_selectedDayIndex.clamp(0, _dayInsights.length - 1)];

        return HoverLiftWrapper(
          child: Container(
            decoration: AppDecorations.glassCard,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '7-Day Forecast',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap bars for dynamic AI scheduling tip 💡',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.2)),
                    ),
                    child: const Text(
                      'Live Forecast',
                      style: TextStyle(fontSize: 10, color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Interactive Chart with Grid Lines
              SizedBox(
                height: 180,
                child: Stack(
                  children: [
                    // Grid background lines
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (index) {
                        return Container(
                          height: 1.0,
                          width: double.infinity,
                          color: const Color(0xFFF1F5F9), // Subtle light slate line
                        );
                      }),
                    ),
                    
                    // Bars Layout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(forecast.length, (index) {
                        return _buildBar(context, forecast[index], index);
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Dynamic Interactive Insight Card
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (activeInsight['color'] as Color).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (activeInsight['color'] as Color).withOpacity(0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (activeInsight['color'] as Color).withOpacity(0.02),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(activeInsight['emoji']!, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Text(
                          '${activeInsight['day']} Plan: ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (activeInsight['color'] as Color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            activeInsight['demand']!,
                            style: TextStyle(
                              fontSize: 10, 
                              fontWeight: FontWeight.w900, 
                              color: activeInsight['color'] as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      activeInsight['text']!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
      },
    );
  }

  Widget _buildBar(BuildContext context, ForecastDay day, int index) {
    final bool isSelected = _selectedDayIndex == index;
    final isToday = day.isToday;
    final isPeak = day.isPeak;

    LinearGradient gradient;
    Color highlightColor;
    
    if (isPeak) {
      gradient = AppTheme.primaryGradient; // Professional blue gradient
      highlightColor = AppTheme.primaryColor;
    } else if (isToday) {
      gradient = AppTheme.accentGradient; // Artisan brown gradient
      highlightColor = AppTheme.secondaryColor;
    } else {
      gradient = const LinearGradient(
        colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)], // Slate 100 to Slate 200
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
      highlightColor = AppTheme.textSecondary;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDayIndex = index;
        });
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: day.demand / 100),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          final barHeight = 110 * value;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Floating Demand Value pill (always visible but glows brighter on selection)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? highlightColor.withOpacity(0.08) 
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? highlightColor.withOpacity(0.3) 
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  '${day.demand}',
                  style: TextStyle(
                    fontSize: 9, 
                    fontWeight: FontWeight.bold, 
                    color: isSelected ? highlightColor : AppTheme.textSecondary,
                  ),
                ),
              ),
              
              // Bar Column
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: isSelected ? 32 : 24,
                height: barHeight,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? highlightColor 
                        : const Color(0xFFCBD5E1),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: highlightColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isToday ? 'Today' : day.day,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected 
                      ? highlightColor 
                      : isToday 
                          ? AppTheme.secondaryColor 
                          : AppTheme.textMuted,
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<ForecastDay> _getSampleForecast() {
    return [
      ForecastDay(date: '', day: 'Mon', isToday: false, demand: 45, isPeak: false),
      ForecastDay(date: '', day: 'Tue', isToday: false, demand: 62, isPeak: false),
      ForecastDay(date: '', day: 'Wed', isToday: false, demand: 78, isPeak: false),
      ForecastDay(date: '', day: 'Thu', isToday: true, demand: 73, isPeak: false),
      ForecastDay(date: '', day: 'Fri', isToday: false, demand: 89, isPeak: false),
      ForecastDay(date: '', day: 'Sat', isToday: false, demand: 95, isPeak: true),
      ForecastDay(date: '', day: 'Sun', isToday: false, demand: 67, isPeak: false),
    ];
  }
}
