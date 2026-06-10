import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ImpactSection extends StatelessWidget {
  const ImpactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
            child: Text('Your Impact', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white)),
          ),
          const SizedBox(height: 8),
          Text('Building a sustainable future', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _impactCard('♻️', '127 kg', 'Waste Prevented', AppTheme.accentColor)),
              const SizedBox(width: 12),
              Expanded(child: _impactCard('🎯', '89%', 'Accuracy', AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _impactCard('🌿', '45 kg', 'CO₂ Saved', const Color(0xFF06B6D4))),
              const SizedBox(width: 12),
              Expanded(child: _impactCard('💰', '+23%', 'Income', AppTheme.secondaryColor)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text(
                  '"Technology should preserve traditions, not replace them."',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic, color: AppTheme.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text('— Artisan Intelligence', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _impactCard(String emoji, String value, String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: accentColor)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
