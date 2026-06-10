import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_orb.dart';
import '../widgets/demand_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/forecast_chart.dart';
import '../widgets/last_order_card.dart';
import '../widgets/orders_list.dart';
import '../widgets/impact_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.bgDark, Color(0xFF12121F), AppTheme.bgDark],
              ),
            ),
          ),
          // Decorative orbs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.primaryColor.withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFFD946EF).withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),
          // Main content
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: AppTheme.bgDark.withOpacity(0.95),
                title: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                      child: Text('Artisan AI', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                actions: [
                  // Connection Status
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOnline ? AppTheme.accentColor.withOpacity(0.1) : AppTheme.dangerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: (isOnline ? AppTheme.accentColor : AppTheme.dangerColor).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline ? AppTheme.accentColor : AppTheme.dangerColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: isOnline ? AppTheme.accentColor : AppTheme.dangerColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // User Account (Profile Icon)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      child: const Text('👨‍🎨', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),

              // Hero Section (Optional, keeping it subtle)
              // SliverToBoxAdapter(child: _buildHeroSection(context)),

              // Main Dashboard Section (Graph + Action Cards)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 320, // Height for the middle section
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left: Graph of last 7 days
                        const Expanded(
                          flex: 3,
                          child: ForecastChart(), // This serves as the graph
                        ),
                        const SizedBox(width: 16),
                        // Right: New Order and In Stock
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // New Order Box (Now Last Order Card)
                              const Expanded(
                                child: LastOrderCard(),
                              ),
                              const SizedBox(height: 16),
                              // In Stock Box
                              Expanded(
                                child: Container(
                                  decoration: AppDecorations.glassCard,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('📦 In Stock', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                      const SizedBox(height: 8),
                                      Text('428 Units', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20, color: AppTheme.accentColor)),
                                      const Text('Ready to ship', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Recent Order Details Section
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Recent Order Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SliverToBoxAdapter(child: OrdersList()),

              // Impact Section
              const SliverToBoxAdapter(child: ImpactSection()),

              // Footer
              SliverToBoxAdapter(child: _buildFooter(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('🚀 Moonshot', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                ),
                const SizedBox(height: 16),
                Text('AI That Understands', style: Theme.of(context).textTheme.displayMedium),
                ShaderMask(
                  shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                  child: Text('Traditional Craft', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                Text('Offline-first intelligence.\nNo internet required.', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
          const SizedBox(width: 100, height: 100, child: AnimatedOrb()),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🧵 ', style: TextStyle(fontSize: 24)),
              Text('Artisan', style: Theme.of(context).textTheme.titleLarge),
              ShaderMask(
                shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                child: Text('AI', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Offline-First • Human-First • Craft-First', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text('🚀 Google Anti-Gravity Moonshot', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primaryLight)),
        ],
      ),
    );
  }

  void _showVoiceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => _buildWave(i)),
            ),
            const SizedBox(height: 24),
            Text('Listening...', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text('Say: "New order, 2 brown chappals"', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWave(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 20, end: 50),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 6,
          height: value,
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(3)),
        );
      },
    );
  }
}
