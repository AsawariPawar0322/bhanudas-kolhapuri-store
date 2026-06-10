import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ActivityFeedSection extends StatelessWidget {
  const ActivityFeedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      _ActivityItem(
        title: 'New Online Order',
        subtitle: 'Rajesh Patil ordered 2 pairs',
        time: '2 min ago',
        emoji: '🛍️',
        color: AppTheme.primaryColor,
      ),
      _ActivityItem(
        title: 'Inventory Alert',
        subtitle: 'Tan leather stock is low (28 sq ft)',
        time: '15 min ago',
        emoji: '⚠️',
        color: AppTheme.secondaryColor,
      ),
      _ActivityItem(
        title: 'Sync Complete',
        subtitle: '12 offline orders synced successfully',
        time: '1 hour ago',
        emoji: '🔄',
        color: AppTheme.accentColor,
      ),
      _ActivityItem(
        title: 'Daily Goal Reached',
        subtitle: 'You completed 10 orders today!',
        time: '3 hours ago',
        emoji: '⭐',
        color: const Color(0xFFD946EF),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All', style: TextStyle(color: AppTheme.primaryLight)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withOpacity(0.05),
                height: 1,
                indent: 70,
              ),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: activity.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            activity.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activity.subtitle,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        activity.time,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final String title;
  final String subtitle;
  final String time;
  final String emoji;
  final Color color;

  _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.emoji,
    required this.color,
  });
}
