import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import 'hover_lift_wrapper.dart';

class Story {
  final String title;
  final String emoji;
  final String subtitle;
  final String details;
  final String imagePlaceholderText;

  Story({
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.details,
    required this.imagePlaceholderText,
  });
}

class ArtisanStoriesSection extends StatelessWidget {
  ArtisanStoriesSection({super.key});

  final List<Story> _stories = [
    Story(
      title: 'Dyeing Base',
      emoji: '🎨',
      subtitle: 'Walnut Bark extract',
      details: 'Master Sanand applying natural organic walnut bark extract to sienna leather templates. This process ensures a rich, non-synthetic patina that ages beautifully.',
      imagePlaceholderText: 'WALNUT DYE PATINA',
    ),
    Story(
      title: 'Sole Punch',
      emoji: '🔨',
      subtitle: 'Double Leather cut',
      details: 'Sourcing coordinator audits direct double-layer leather cuts. Stitched with high-tensile waxed cotton thread for traditional durability.',
      imagePlaceholderText: 'SOLE PUNCH TEMPLATE',
    ),
    Story(
      title: 'Gold Braid',
      emoji: '✨',
      subtitle: 'Zari weaving',
      details: 'Artisan Priya hand-threading gold brocade wire along the Y-strap borders. Standard speed: 3 hours per pair of master embroidery.',
      imagePlaceholderText: 'GOLD ZARI WEAVE',
    ),
    Story(
      title: 'Quality Check',
      emoji: '🔍',
      subtitle: 'Ergonomic alignment',
      details: 'Auditing flat arch thickness and comfort cushioning before packaging in eco-friendly jute bags for direct shipping.',
      imagePlaceholderText: 'ERGONOMIC QA SIGN',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Live Workshop Stories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _stories.length,
            itemBuilder: (context, index) {
              final story = _stories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: HoverLiftWrapper(
                  child: GestureDetector(
                    onTap: () => _openStory(context, story),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(story.emoji, style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          story.title,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
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

  void _openStory(BuildContext context, Story story) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Story Viewer',
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return StoryViewerModal(story: story);
      },
    );
  }
}

class StoryViewerModal extends StatefulWidget {
  final Story story;
  const StoryViewerModal({super.key, required this.story});

  @override
  State<StoryViewerModal> createState() => _StoryViewerModalState();
}

class _StoryViewerModalState extends State<StoryViewerModal> {
  double _progressValue = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 50);
    int elapsed = 0;
    const totalTime = 4000; // 4 seconds

    _timer = Timer.periodic(duration, (timer) {
      elapsed += 50;
      if (elapsed >= totalTime) {
        timer.cancel();
        Navigator.pop(context);
      } else {
        setState(() {
          _progressValue = elapsed / totalTime;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 360,
          height: 600,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Dark slate
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator bar
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progressValue,
                    minHeight: 4,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(widget.story.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.story.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            widget.story.subtitle,
                            style: const TextStyle(color: Colors.white60, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Mock Image/Video Player Area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.story.emoji, style: const TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.story.imagePlaceholderText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Description Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.story.details,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close Viewer', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sponsorship of ₹500 committed to ${widget.story.title}! 💖'),
                                  backgroundColor: Colors.pinkAccent,
                                ),
                              );
                            },
                            child: const Text('Sponsor Craft 💖', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
