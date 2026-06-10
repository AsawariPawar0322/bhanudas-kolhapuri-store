import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:ui';

class BuyerParallaxStoryCard extends StatefulWidget {
  const BuyerParallaxStoryCard({super.key});

  @override
  State<BuyerParallaxStoryCard> createState() => _BuyerParallaxStoryCardState();
}

class _BuyerParallaxStoryCardState extends State<BuyerParallaxStoryCard> {
  late PageController _pageController;
  double _pageOffset = 0;

  final List<Map<String, String>> _stories = [
    {
      'title': 'The Raw Materials',
      'subtitle': 'Sourced ethically, crafted sustainably.',
      'image': 'assets/images/classic_tan.png',
      'description': 'Every piece begins with organic fibers sourced directly from local farmers in rural India, ensuring fair trade and zero chemical processing.',
    },
    {
      'title': 'The Artisan Touch',
      'subtitle': 'Generations of skill in every thread.',
      'image': 'assets/images/modern_black.png',
      'description': 'Hand-loomed by master weavers whose techniques have been passed down for centuries, preserving cultural heritage.',
    },
    {
      'title': 'The Final Creation',
      'subtitle': 'Ready for your everyday journey.',
      'image': 'assets/images/vibrant_blue.png',
      'description': 'A sustainable, biodegradable masterpiece that tells a story of empowerment and ecological harmony.',
    }
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'The Journey',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _stories.length,
            itemBuilder: (context, index) {
              final story = _stories[index];
              // Calculate the offset for this specific card
              double cardOffset = index - _pageOffset;
              double parallaxOffset = cardOffset * 150;
              
              // Scale effect
              double scale = 1 - (cardOffset.abs() * 0.1);
              scale = scale.clamp(0.8, 1.0);

              return Transform.scale(
                scale: scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Parallax Image
                        Transform.translate(
                          offset: Offset(parallaxOffset, 0),
                          child: Image.asset(
                            story['image']!,
                            fit: BoxFit.cover,
                            color: Colors.black.withOpacity(0.3),
                            colorBlendMode: BlendMode.darken,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppTheme.bgCard,
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 48),
                            ),
                          ),
                        ),
                        // Glass Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                                Colors.black.withOpacity(0.95),
                              ],
                              stops: const [0.4, 0.8, 1.0],
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Text(
                                      'Chapter ${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                story['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                story['subtitle']!,
                                style: const TextStyle(
                                  color: AppTheme.primaryLight,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                story['description']!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
