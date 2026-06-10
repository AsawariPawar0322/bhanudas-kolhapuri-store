import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'hover_lift_wrapper.dart';

class CoopTrackerCard extends StatelessWidget {
  const CoopTrackerCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                      'Co-op Impact Tracker',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Environmental & fair-trade metrics for your purchases 🌿',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                  ),
                  child: const Text(
                    'FAIR TRADE',
                    style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Metrics Row
            Row(
              children: [
                // Fair wage index gauge
                Expanded(
                  child: _buildMetricItem(
                    title: 'Fair Wage Share',
                    value: '85.2%',
                    emoji: '👨‍🎨',
                    subText: 'Direct artisan payment share',
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                // Carbon Offset
                Expanded(
                  child: _buildMetricItem(
                    title: 'Carbon Offset',
                    value: '-14.8 kg',
                    emoji: '🌿',
                    subText: 'Logistics pool savings',
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // Healthcare fund
                Expanded(
                  child: _buildMetricItem(
                    title: 'Community Fund',
                    value: '₹3,420',
                    emoji: '🏥',
                    subText: 'Allocated to medical checkups',
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(width: 16),
                // Bio-degradable leather rating
                Expanded(
                  child: _buildMetricItem(
                    title: 'Eco Material',
                    value: '100%',
                    emoji: '☀️',
                    subText: 'Veg-tanned organic hides',
                    color: const Color(0xFFEA580C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 20),

            // Logistics Step Progress Tracker
            const Text(
              'Co-operative Distribution Nodes',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.5),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLogisticsNode('Sanand Workshop', 'Stitched', true),
                _buildLogisticsLine(true),
                _buildLogisticsNode('Co-op Hub', 'Consolidated', true),
                _buildLogisticsLine(true),
                _buildLogisticsNode('Transit Depot', 'Dispatched', false),
                _buildLogisticsLine(false),
                _buildLogisticsNode('Buyer Address', 'Pending', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String title,
    required String value,
    required String emoji,
    required String subText,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
              ),
              Text(emoji, style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            subText,
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsNode(String title, String status, bool active) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
            border: Border.all(
              color: active ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
              width: 2.0,
            ),
          ),
          child: active
              ? const Center(child: Icon(Icons.check, size: 10, color: Colors.white))
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: active ? AppTheme.textPrimary : AppTheme.textMuted,
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 8,
            color: active ? const Color(0xFF10B981) : AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildLogisticsLine(bool active) {
    return Expanded(
      child: Container(
        height: 2.0,
        margin: const EdgeInsets.only(bottom: 24),
        color: active ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
      ),
    );
  }
}
