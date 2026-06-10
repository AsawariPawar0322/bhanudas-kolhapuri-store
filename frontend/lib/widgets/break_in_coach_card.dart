import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'hover_lift_wrapper.dart';

class BreakInCoachCard extends StatefulWidget {
  const BreakInCoachCard({super.key});

  @override
  State<BreakInCoachCard> createState() => _BreakInCoachCardState();
}

class _BreakInCoachCardState extends State<BreakInCoachCard> {
  // Define emerald green constants
  static const Color _emerald = Color(0xFF10B981);
  static const Color _darkEmerald = Color(0xFF065F46);

  // Store the check status of the 7 days
  final List<bool> _daysCompleted = List.generate(7, (_) => false);

  // Care instructions for each day
  final List<Map<String, String>> _breakInSteps = [
    {
      'day': 'Day 1',
      'title': 'Prep & Short Indoor Wear 🏠',
      'desc': 'Apply a light coat of castor oil or coconut oil to the inner seams of the straps. Wear with thick socks for 15 minutes indoors.'
    },
    {
      'day': 'Day 2',
      'title': 'Flex & Stretch 👐',
      'desc': 'Gently flex the leather sole back and forth with your hands to soften fibers. Wear for 30 minutes indoors without socks.'
    },
    {
      'day': 'Day 3',
      'title': 'First Light Walk 🚶',
      'desc': 'Apply another light layer of oil if straps feel stiff. Walk around the house or office for 45 minutes.'
    },
    {
      'day': 'Day 4',
      'title': 'Short Outdoor Outing 🌳',
      'desc': 'Wear your chappals for a quick 15-minute walk outdoors (like getting the mail). Note any tight spots.'
    },
    {
      'day': 'Day 5',
      'title': 'Molding to Foot Shape 👣',
      'desc': 'Walk for 1-2 hours. The vegetable-tanned leather is now absorbing heat and sweat, molding to your foot arch.'
    },
    {
      'day': 'Day 6',
      'title': 'Half-Day Normal Wear ☕',
      'desc': 'Wear for half a day during light activities. Spot-treat any remaining dry or stiff spots with leather balm.'
    },
    {
      'day': 'Day 7',
      'title': 'Fully Customized Fit ✨',
      'desc': 'Perfect fit achieved! The leather is now soft, beautifully creased, and uniquely molded to your specific gait.'
    },
  ];

  double _calculateProgress() {
    int completed = _daysCompleted.where((c) => c).length;
    return completed / 7.0;
  }

  @override
  Widget build(BuildContext context) {
    double progress = _calculateProgress();
    int completedCount = _daysCompleted.where((c) => c).length;

    return HoverLiftWrapper(
      child: Container(
        decoration: AppDecorations.glassCard,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leather Break-In Coach',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '7-day guide to mold hand-crafted leather to your feet 👣',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _emerald.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _emerald.withOpacity(0.2)),
                  ),
                  child: const Text(
                    'FIT COMPLIANCE',
                    style: TextStyle(fontSize: 10, color: _emerald, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(_emerald),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          completedCount == 7 
                              ? 'Congratulations! 🎉' 
                              : 'Day $completedCount of 7 Completed',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          completedCount == 7
                              ? 'Your chappals are fully broken in and fit like a second skin.'
                              : 'Follow the daily steps to soften the leather and prevent blisters.',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Accordion/List of Days
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 7,
              itemBuilder: (context, index) {
                final step = _breakInSteps[index];
                final isDone = _daysCompleted[index];
                
                // Allow check only if previous days are checked (sequential break-in)
                bool isClickable = index == 0 || _daysCompleted[index - 1];

                return Opacity(
                  opacity: isClickable ? 1.0 : 0.5,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isDone ? _emerald.withOpacity(0.02) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDone ? _emerald.withOpacity(0.2) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Checkbox(
                          value: isDone,
                          activeColor: _emerald,
                          onChanged: isClickable 
                              ? (val) {
                                  setState(() {
                                    if (val == true) {
                                      _daysCompleted[index] = true;
                                    } else {
                                      // Unchecking must uncheck subsequent days
                                      for (int i = index; i < 7; i++) {
                                        _daysCompleted[i] = false;
                                      }
                                    }
                                  });
                                }
                              : null,
                        ),
                        title: Text(
                          '${step['day']}: ${step['title']}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            color: isDone ? _darkEmerald : AppTheme.textPrimary,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 48, right: 16, bottom: 12),
                            child: Text(
                              step['desc']!,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11.5, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
