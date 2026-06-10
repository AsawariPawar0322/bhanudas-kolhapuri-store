import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/hover_lift_wrapper.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Deep Slate 900
              Color(0xFF1E293B), // Slate 800
              Color(0xFF0F172A), // Deep Slate 900
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Navbar
              _buildNavbar(context),

              // Hero Section
              _buildHero(context),

              // Stats Ticker
              _buildStatsTicker(context),

              // Features Grid
              _buildFeaturesGrid(context),

              // Footer
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 750;

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('👞 ', style: TextStyle(fontSize: 24)),
                const Text(
                  'Sanand ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: const Text(
                    'Footwear',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(isArtisan: false),
                        ),
                      );
                    },
                    child: const Text(
                      'Buyer Store',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(isArtisan: true),
                        ),
                      );
                    },
                    child: const Text(
                      'Artisan Hub',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Sign In', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('👞 ', style: TextStyle(fontSize: 32)),
              Text(
                'Sanand ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: Theme.of(context).textTheme.displayLarge?.fontFamily,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: const Text(
                  'Footwear',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(isArtisan: false),
                    ),
                  );
                },
                child: const Text(
                  'Buyer Store',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(isArtisan: true),
                    ),
                  );
                },
                child: const Text(
                  'Artisan Hub',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    final heroContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: const Text(
            '🎨 Traditional Art Meets AI Intelligence',
            style: TextStyle(
              color: AppTheme.primaryLight,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Handcrafted Heritage,\nAI Personalized Fitting.',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Experience authentic Kolhapuri craftsmanship paired with state-of-the-art camera outfit matching, dynamic customizers, and an AI negotiation helper for direct-to-artisan wholesale.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(isArtisan: false),
                  ),
                );
              },
              child: const Text('Start Shopping 🚀'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white30),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(isArtisan: true),
                  ),
                );
              },
              child: const Text('Enter Artisan Portal'),
            ),
          ],
        ),
      ],
    );

    final heroGraphic = HoverLiftWrapper(
      child: Center(
        child: Container(
          height: isMobile ? 260 : 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFFEA580C), Color(0xFFF59E0B)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEA580C).withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                '👞',
                style: TextStyle(fontSize: 140),
              ),
              Positioned(
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Genuine Handcrafted Kolhapuri',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            heroContent,
            const SizedBox(height: 40),
            heroGraphic,
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: heroContent,
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 5,
            child: heroGraphic,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTicker(BuildContext context) {
    return Container(
      color: Colors.black26,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 24,
        runSpacing: 24,
        children: [
          _buildStatItem('500+', 'Artisans Supported'),
          _buildStatItem('100%', 'Fair-Trade Payout'),
          _buildStatItem('98.4%', 'Fitting Match Rate'),
          _buildStatItem('0%', 'Synthetic Plastics'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String label) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.primaryLight,
            fontSize: 36,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    double childAspectRatio = 1.2;
    if (screenWidth < 600) {
      crossAxisCount = 1;
      childAspectRatio = 2.0;
    } else if (screenWidth < 900) {
      crossAxisCount = 2;
      childAspectRatio = 1.3;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: Column(
        children: [
          const Center(
            child: Text(
              'Packed with Premium Features',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'A modern platform bridging rural heritage with deep-learning AI tools.',
              style: TextStyle(color: Colors.white60, fontSize: 15),
            ),
          ),
          const SizedBox(height: 48),
          GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: childAspectRatio,
            children: [
              _buildFeatureCard(
                context,
                '📸 AI Outfit Matcher',
                'Instantly scan your outfit colors with your camera and let our AI suggest the ideal matching chappal shades.',
              ),
              _buildFeatureCard(
                context,
                '🎨 Dynamic 3D Customizer',
                'Select leather finishes, traditional embroideries, and sole profiles with interactive real-time visual renders.',
              ),
              _buildFeatureCard(
                context,
                '📐 AI Foot Sizer Scan',
                'Take a quick photo of your foot to calculate custom width and lengths for the ultimate ergonomic fit.',
              ),
              _buildFeatureCard(
                context,
                '💬 Live Negotiations Hub',
                'Negotiate bulk wholesale orders directly. Includes an automated offline assistant for instant pricing deals.',
              ),
              _buildFeatureCard(
                context,
                '🎪 Artisan Workshop Reels',
                'Watch live crafting stories directly from the master studios and sponsor local traditional workmanship.',
              ),
              _buildFeatureCard(
                context,
                '🌱 Co-op Impact Tracker',
                'Track carbon offsets of regional shipping, direct-to-artisan payouts, and local healthcare funds.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String description) {
    return HoverLiftWrapper(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: const Center(
        child: Text(
          '© 2026 Sanand Footwear Co-operative. All Rights Reserved.',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ),
    );
  }
}
