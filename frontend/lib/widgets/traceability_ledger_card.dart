import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'hover_lift_wrapper.dart';

class TraceabilityLedgerCard extends StatelessWidget {
  const TraceabilityLedgerCard({super.key});

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
                      'Farm-to-Foot Traceability Ledger',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Trace raw materials, fair wages & craft ethics transparently 🔍',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5E3C).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF8B5E3C).withOpacity(0.2)),
                  ),
                  child: const Text(
                    'ETHICAL LEDGER',
                    style: TextStyle(fontSize: 10, color: Color(0xFF8B5E3C), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Material Timeline
            const Text(
              'Material & Production Journey',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildTimelineNode(
              title: '1. Vegetable-Tanned Leather Sourcing 🐄',
              subtitle: 'Kolhapur Artisanal Tannery Co-op',
              desc: 'Premium full-grain leather, tanned locally using bark extracts (myrobalan & acacia). 100% chrome-free, biodegradable, and non-toxic.',
              isFirst: true,
            ),
            _buildTimelineNode(
              title: '2. Thread & Embroidery Sourcing 🧵',
              subtitle: 'Ichalkaranji Spinning Mills & Artisans',
              desc: 'High-tensile cotton and silk threads, dyed using organic indigo and natural turmeric pigments.',
            ),
            _buildTimelineNode(
              title: '3. Handcrafting & Assembly 🔨',
              subtitle: 'Workshop of Master Artisan Santosh Sawant',
              desc: 'Sole cutting, hand-stitching, and strap braiding completed over 24 man-hours. Stamped with the artisan guild mark.',
              isLast: true,
            ),

            const SizedBox(height: 24),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),

            // Direct Trade Wage Split
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Retail Price Distribution Split',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'DIRECT TRADE',
                    style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWageSplitBar(),
            const SizedBox(height: 16),

            // Legend
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendItem(label: 'Artisan Wage (45%)', color: Colors.blue.shade600),
                _buildLegendItem(label: 'Raw Materials (25%)', color: Colors.amber.shade700),
                _buildLegendItem(label: 'Logistics/Pack (15%)', color: Colors.purple.shade600),
                _buildLegendItem(label: 'Coop Dev Fund (15%)', color: Colors.teal.shade600),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Blockchain Ledger Signature verified: #KOL-772-SHA256 ✅'),
                    backgroundColor: Color(0xFF8B5E3C),
                  ),
                );
              },
              icon: const Icon(Icons.verified_user_outlined, size: 16),
              label: const Text('Verify Batch Blockchain Certificate', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5E3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineNode({
    required String title,
    required String subtitle,
    required String desc,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Visual line column
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5E3C),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5E3C).withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 70,
                color: const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Content column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF8B5E3C), fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.4),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWageSplitBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 16,
        child: Row(
          children: [
            // Artisan Wage 45%
            Expanded(
              flex: 45,
              child: Container(color: Colors.blue.shade600),
            ),
            // Materials 25%
            Expanded(
              flex: 25,
              child: Container(color: Colors.amber.shade700),
            ),
            // Logistics 15%
            Expanded(
              flex: 15,
              child: Container(color: Colors.purple.shade600),
            ),
            // Coop pool 15%
            Expanded(
              flex: 15,
              child: Container(color: Colors.teal.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required String label, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
