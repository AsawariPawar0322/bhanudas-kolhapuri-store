import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import 'hover_lift_wrapper.dart';
import 'webcam_preview.dart';

class FootSizerCard extends StatefulWidget {
  const FootSizerCard({super.key});

  @override
  State<FootSizerCard> createState() => _FootSizerCardState();
}

class _FootSizerCardState extends State<FootSizerCard> with TickerProviderStateMixin {
  bool _isScanning = false;
  bool _scanComplete = false;
  int _currentStep = 0;
  Timer? _scanTimer;

  // Scanning laser animation
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  final List<String> _scanSteps = [
    '🔍 Identifying background floor contrast...',
    '💳 Aligning scale reference (coin/card detected)...',
    '👣 Analyzing foot contours & boundaries...',
    '📐 Measuring: Heel-to-toe length & width spread...',
    '✨ Calibrating authentic Kolhapuri Size Index...',
  ];

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _laserController.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _scanComplete = false;
      _currentStep = 0;
    });

    _laserController.repeat(reverse: true);

    _scanTimer = Timer.periodic(const Duration(milliseconds: 1800), (timer) {
      if (_currentStep < _scanSteps.length - 1) {
        setState(() {
          _currentStep++;
        });
      } else {
        timer.cancel();
        _laserController.stop();
        setState(() {
          _isScanning = false;
          _scanComplete = true;
        });
      }
    });
  }

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
                      'AI Foot Sizer Scan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Scan foot via camera to find exact artisan sizing 📐',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.2)),
                  ),
                  child: const Text(
                    'CAMERA SCANNER',
                    style: TextStyle(fontSize: 10, color: Color(0xFF06B6D4), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (!_isScanning && !_scanComplete) ...[
              // Idle state
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A), // Dark slate
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📐', style: TextStyle(fontSize: 50)),
                    const SizedBox(height: 16),
                    const Text(
                      'Ready to Scan Foot',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Place your foot on a plain floor next to a standard credit card or coin for size reference.',
                        style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06B6D4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _startScan,
                      icon: const Icon(Icons.videocam_outlined, size: 16),
                      label: const Text('Start Camera Scan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ] else if (_isScanning) ...[
              // Scanning state
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF06B6D4), width: 1.5),
                ),
                child: Stack(
                  children: [
                    // Live camera feed
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: WebcamPreview(
                          onVideoCreated: (_) {},
                        ),
                      ),
                    ),
                    // Moving scan laser line
                    AnimatedBuilder(
                      animation: _laserAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 220 * _laserAnimation.value,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFF06B6D4),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF06B6D4).withOpacity(0.8),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Scanning layout focus corners
                    _buildFocusCorner(top: 16, left: 16, isTop: true, isLeft: true),
                    _buildFocusCorner(top: 16, right: 16, isTop: true, isLeft: false),
                    _buildFocusCorner(bottom: 16, left: 16, isTop: false, isLeft: true),
                    _buildFocusCorner(bottom: 16, right: 16, isTop: false, isLeft: false),

                    // Running steps text overlay
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.7),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _scanSteps[_currentStep],
                            key: ValueKey(_currentStep),
                            style: const TextStyle(
                              color: Color(0xFF06B6D4),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Courier',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    const Center(
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(Icons.filter_center_focus, size: 80, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_scanComplete) ...[
              // Scan complete results
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildResultMetric('RECOMMENDED SIZE', 'Size 8', 'EU 42 (Kolhapuri #8)'),
                        const VerticalDivider(width: 1, color: Colors.grey),
                        _buildResultMetric('FOOT WIDTH', 'Medium (D)', 'Fit margin: Perfect'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE2E8F0), height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Length: 26.5 cm  •  Width: 9.8 cm',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                            ),
                            Text('Arch distribution: Normal (Slight high arch)', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                          ],
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: _startScan,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Rescan', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Applied Size 8 fit profile to checkout bag! 📐'),
                                    backgroundColor: Color(0xFF06B6D4),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF06B6D4),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              child: const Text('Apply Size', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultMetric(String label, String value, String sub) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF06B6D4)),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildFocusCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Color(0xFF06B6D4), width: 3.0) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Color(0xFF06B6D4), width: 3.0) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Color(0xFF06B6D4), width: 3.0) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Color(0xFF06B6D4), width: 3.0) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
