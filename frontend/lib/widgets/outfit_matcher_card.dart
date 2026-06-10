import 'dart:async';
import 'dart:math' as math;
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'webcam_preview.dart';

// Conditionally import dart:js only on web to avoid compile errors on other platforms
import 'dart:js' as js;

class OutfitMatcherCard extends StatefulWidget {
  final Function(Map<String, String>) onProductSelected;

  const OutfitMatcherCard({
    super.key,
    required this.onProductSelected,
  });

  @override
  State<OutfitMatcherCard> createState() => _OutfitMatcherCardState();
}

class _OutfitMatcherCardState extends State<OutfitMatcherCard> with SingleTickerProviderStateMixin {
  html.VideoElement? _webcamVideoElement;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionDenied = false;
  bool _isAnalyzing = false;
  bool _isSimulatorMode = false;
  String _selectedSimulatorColor = 'Emerald Green';
  
  // Dynamic analysis results
  Color? _detectedColor;
  String _detectedHex = '';
  Map<String, String>? _recommendedProduct;
  String _analysisStatus = '';

  // Preset outfit colors for simulator mode
  final List<Map<String, dynamic>> _outfitColors = [
    {'name': 'Mustard Yellow', 'color': Color(0xFFF59E0B), 'emoji': '💛'},
    {'name': 'Emerald Green', 'color': Color(0xFF10B981), 'emoji': '💚'},
    {'name': 'Bridal Maroon', 'color': Color(0xFF8B0000), 'emoji': '❤️'},
    {'name': 'Royal Indigo', 'color': Color(0xFF1D4ED8), 'emoji': '💙'},
    {'name': 'Charcoal Black', 'color': Color(0xFF374151), 'emoji': '🖤'},
    {'name': 'Ivory White', 'color': Color(0xFFF3F4F6), 'emoji': '🤍'},
  ];

  // Match outfit color to the best chappal from catalog
  final Map<String, Map<String, String>> _matchRules = {
    'Mustard Yellow': {
      'name': 'Classic Tan Kolhapuri',
      'price': '₹1,200',
      'image': 'assets/images/classic_tan.png',
      'score': '96%',
      'advice': 'The warm, earthy tones of Classic Tan complement Mustard Yellow outfits beautifully, creating a perfect traditional look.'
    },
    'Emerald Green': {
      'name': 'Royal Wedding Gold',
      'price': '₹2,500',
      'image': 'assets/images/vibrant_blue.png',
      'score': '98%',
      'advice': 'Gold and Emerald Green represent supreme festive elegance. The gold brocade straps offer high contrast.'
    },
    'Bridal Maroon': {
      'name': 'Bridal Maroon Velvet',
      'price': '₹2,499',
      'image': 'assets/images/bridal_maroon.png',
      'score': '99%',
      'advice': 'Monochrome bridal perfection! Cushioned maroon velvet blends seamlessly with your outfit.'
    },
    'Royal Indigo': {
      'name': 'Vibrant Indigo Blue',
      'price': '₹1,599',
      'image': 'assets/images/vibrant_blue.png',
      'score': '95%',
      'advice': 'Your blue outfit pairs brilliantly with hand-painted blue chappals for a modern, artistic appearance.'
    },
    'Charcoal Black': {
      'name': 'Daily Walk Black',
      'price': '₹850',
      'image': 'assets/images/modern_black.png',
      'score': '94%',
      'advice': 'Sleek black chappals match your dark outfit tones seamlessly, offering a modern minimal daily aesthetic.'
    },
    'Ivory White': {
      'name': 'Royal Tan Kolhapuri',
      'price': '₹1,899',
      'image': 'assets/images/royal_tan.jpg',
      'score': '92%',
      'advice': 'Contrast light white dresses with authentic Royal Tan leather to make a premium design statement.'
    },
  };

  @override
  void initState() {
    super.initState();
    _injectJSAnalyzer();
    _initializeWebcam();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _injectJSAnalyzer() {
    if (kIsWeb) {
      js.context.callMethod('eval', ["""
        window.analyzeOutfitVideoColor = function(videoElement, callback) {
          try {
            var canvas = document.createElement('canvas');
            canvas.width = 10;
            canvas.height = 10;
            var ctx = canvas.getContext('2d');
            ctx.drawImage(videoElement, 0, 0, 10, 10);
            var data = ctx.getImageData(5, 5, 1, 1).data;
            callback(data[0], data[1], data[2]);
          } catch(e) {
            callback(16, 185, 129); // Fallback emerald green
          }
        };
      """]);
    }
  }

  Future<void> _initializeWebcam() async {
    setState(() {
      _isCameraInitialized = true;
      _isCameraPermissionDenied = false;
      _isSimulatorMode = false;
    });
  }

  void _enableSimulatorFallback() {
    if (mounted) {
      setState(() {
        _isCameraPermissionDenied = true;
        _isCameraInitialized = false;
        _isSimulatorMode = true; // Auto fallback to simulator
      });
    }
  }

  Future<void> _captureAndMatchOutfit() async {
    setState(() {
      _isAnalyzing = true;
      _recommendedProduct = null;
      _detectedColor = null;
      _analysisStatus = _isSimulatorMode ? 'Scanning matching color...' : 'Capturing outfit frame...';
    });

    if (_isSimulatorMode) {
      // Simulator Match Flow
      Timer(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() => _analysisStatus = 'Calculating matching chappal...');
        }
      });
      Timer(const Duration(milliseconds: 2400), () {
        final option = _outfitColors.firstWhere((c) => c['name'] == _selectedSimulatorColor);
        final rgb = option['color'] as Color;
        _processColorMatching(rgb.red, rgb.green, rgb.blue);
      });
      return;
    }

    if (_webcamVideoElement == null) {
      setState(() {
        _isAnalyzing = false;
        _analysisStatus = 'Webcam not active. Use Simulator.';
      });
      return;
    }

    try {
      if (mounted) {
        setState(() => _analysisStatus = 'Analyzing pixels & textures...');
      }

      if (kIsWeb) {
        js.context.callMethod('window.analyzeOutfitVideoColor', [
          _webcamVideoElement,
          js.allowInterop((r, g, b) {
            _processColorMatching(r, g, b);
          })
        ]);
      } else {
        Timer(const Duration(seconds: 1), () {
          _processColorMatching(16, 185, 129); // Mock green
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisStatus = 'Failed to analyze: $e';
        });
      }
    }
  }

  void _processColorMatching(int r, int g, int b) {
    if (!mounted) return;

    double minDistance = double.maxFinite;
    Map<String, dynamic>? bestMatchOption;

    for (var option in _outfitColors) {
      final Color color = option['color'] as Color;
      double distance = math.sqrt(
        math.pow(r - color.red, 2) +
        math.pow(g - color.green, 2) +
        math.pow(b - color.blue, 2)
      );
      if (distance < minDistance) {
        minDistance = distance;
        bestMatchOption = option;
      }
    }

    final hexCode = '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

    setState(() {
      _isAnalyzing = false;
      _detectedColor = Color.fromARGB(255, r, g, b);
      _detectedHex = hexCode;
      
      if (bestMatchOption != null) {
        final String matchedColorName = bestMatchOption['name'] ?? 'Emerald Green';
        final productData = _matchRules[matchedColorName];
        if (productData != null) {
          _recommendedProduct = Map<String, String>.from(productData);
          final distanceFactor = (1.0 - (minDistance / 441.0)).clamp(0.85, 0.99);
          _recommendedProduct!['score'] = '${(distanceFactor * 100).toInt()}%';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: AppDecorations.glassCard,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Row(
                children: [
                  const Icon(Icons.videocam, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    _isSimulatorMode ? 'AI Outfit Matcher (Simulator)' : 'AI Outfit Live Scanner',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  // Toggle Mode Button
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isSimulatorMode = !_isSimulatorMode;
                        _recommendedProduct = null;
                        _detectedColor = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _isSimulatorMode ? 'Switch to Live 📷' : 'Switch to Demo 🎭',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isSimulatorMode 
                        ? 'Simulated Outfit Style Recommendation' 
                        : 'Real-time Outfit Suggestion Tool',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isSimulatorMode 
                        ? 'Choose your outfit color, click capture, and witness the matching suggestions.'
                        : 'Position your outfit in the camera frame, tap analyze, and we will find the ideal chappal.',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Simulator Color Picker Mode
                  if (_isSimulatorMode) ...[
                    if (_isCameraPermissionDenied) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Live camera stream could not be accessed. Switched to Simulator mode.',
                                style: TextStyle(color: Color(0xFF92400E), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Text('Select your outfit color:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textPrimary)),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _outfitColors.map((colorMap) {
                          final name = colorMap['name']!;
                          final color = colorMap['color'] as Color;
                          final emoji = colorMap['emoji']!;
                          final isSelected = _selectedSimulatorColor == name;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Row(
                                children: [
                                  Text(emoji),
                                  const SizedBox(width: 6),
                                  Text(name),
                                ],
                              ),
                              selected: isSelected,
                              selectedColor: color.withOpacity(0.2),
                              backgroundColor: const Color(0xFFF1F5F9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: isSelected ? color : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedSimulatorColor = name;
                                    _recommendedProduct = null;
                                    _detectedColor = null;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Camera Viewfinder Box
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isAnalyzing ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Live Webcam or Simulator Graphic
                        if (!_isSimulatorMode)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: WebcamPreview(
                                onVideoCreated: (videoElement) {
                                  _webcamVideoElement = videoElement;
                                  if (mounted) {
                                    setState(() {
                                      _isCameraPermissionDenied = false;
                                      _isCameraInitialized = true;
                                    });
                                  }
                                },
                                onError: (errorMsg) {
                                  _enableSimulatorFallback();
                                },
                              ),
                            ),
                          )
                        else if (_isSimulatorMode)
                          // Simulator background scanner graphic
                          Positioned.fill(
                            child: Container(
                              color: const Color(0xFF1E293B),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.style_outlined, color: Colors.white24, size: 52),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Selected Outfit: $_selectedSimulatorColor',
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('Click Analyze below to scan this shade.', style: TextStyle(color: Colors.white38, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                          
                        // Scanner line overlay during analysis
                        if (_isAnalyzing)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOut,
                            builder: (context, animVal, child) {
                              return Align(
                                alignment: Alignment(0, (animVal * 2) - 1),
                                child: Container(
                                  height: 3,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.8),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                        // Viewport Borders
                        Positioned(
                          top: 15, left: 15,
                          child: Container(width: 15, height: 15, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white70, width: 3), left: BorderSide(color: Colors.white70, width: 3)))),
                        ),
                        Positioned(
                          top: 15, right: 15,
                          child: Container(width: 15, height: 15, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white70, width: 3), right: BorderSide(color: Colors.white70, width: 3)))),
                        ),
                        Positioned(
                          bottom: 15, left: 15,
                          child: Container(width: 15, height: 15, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white70, width: 3), left: BorderSide(color: Colors.white70, width: 3)))),
                        ),
                        Positioned(
                          bottom: 15, right: 15,
                          child: Container(width: 15, height: 15, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white70, width: 3), right: BorderSide(color: Colors.white70, width: 3)))),
                        ),

                        // Scanning Overlay Text
                        if (_isAnalyzing)
                          Positioned(
                            bottom: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _analysisStatus,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Trigger Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: (_isSimulatorMode || (_isCameraInitialized && !_isAnalyzing))
                          ? _captureAndMatchOutfit
                          : null,
                      icon: const Icon(Icons.camera, size: 20),
                      label: const Text(
                        'Capture & Match Outfit',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ),

                  // Dynamic Results Card
                  if (_recommendedProduct != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.color_lens_outlined, color: AppTheme.secondaryColor, size: 22),
                              const SizedBox(width: 8),
                              const Text(
                                'Matched Outfit Shade',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                              ),
                              const Spacer(),
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _detectedColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _detectedHex,
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 12),
                          
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  _recommendedProduct!['image']!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 60,
                                    height: 60,
                                    color: const Color(0xFFF1F5F9),
                                    child: const Icon(Icons.image, color: AppTheme.textMuted),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _recommendedProduct!['name']!,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          _recommendedProduct!['price']!,
                                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryColor, fontSize: 13),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${_recommendedProduct!['score']} Match',
                                            style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  minimumSize: Size.zero,
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  widget.onProductSelected(_recommendedProduct!);
                                },
                                child: const Text('Buy Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 6),
                          
                          Text(
                            _recommendedProduct!['advice']!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
