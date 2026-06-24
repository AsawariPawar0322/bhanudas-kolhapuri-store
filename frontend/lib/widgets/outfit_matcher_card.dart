import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Platform-agnostic conditional imports
import 'webcam_view_stub.dart'
    if (dart.library.js) 'webcam_view_web.dart'
    if (dart.library.io) 'webcam_view_mobile.dart';

import 'outfit_analyzer_stub.dart'
    if (dart.library.js) 'outfit_analyzer_web.dart'
    if (dart.library.io) 'outfit_analyzer_mobile.dart';

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
  dynamic _webcamVideoElement;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionDenied = false;
  bool _isAnalyzing = false;
  bool _isSimulatorMode = false;
  String _selectedSimulatorColor = 'Emerald Green';
  
  // Dynamic analysis results
  Color? _detectedColor;
  String _detectedHex = '';
  Map<String, String>? _aiProduct;
  Map<String, String>? _customerProduct;
  String _analysisStatus = '';

  // Controller for custom hex input
  final TextEditingController _hexController = TextEditingController();

  // Timer for real-time live hover analysis
  Timer? _hoverAnalysisTimer;

  // Preset outfit colors for simulator mode (24+ rich traditional & modern colors)
  final List<Map<String, dynamic>> _outfitColors = [
    {'name': 'Mustard Yellow', 'color': Color(0xFFF59E0B), 'emoji': '💛'},
    {'name': 'Emerald Green', 'color': Color(0xFF10B981), 'emoji': '💚'},
    {'name': 'Bridal Maroon', 'color': Color(0xFF8B0000), 'emoji': '❤️'},
    {'name': 'Royal Indigo', 'color': Color(0xFF1D4ED8), 'emoji': '💙'},
    {'name': 'Charcoal Black', 'color': Color(0xFF374151), 'emoji': '🖤'},
    {'name': 'Ivory White', 'color': Color(0xFFF3F4F6), 'emoji': '🤍'},
    {'name': 'Crimson Red', 'color': Color(0xFFDC2626), 'emoji': '❤️'},
    {'name': 'Rose Pink', 'color': Color(0xFFEC4899), 'emoji': '💗'},
    {'name': 'Coral Orange', 'color': Color(0xFFF97316), 'emoji': '🧡'},
    {'name': 'Golden Amber', 'color': Color(0xFFD97706), 'emoji': '💛'},
    {'name': 'Olive Green', 'color': Color(0xFF65A30D), 'emoji': '💚'},
    {'name': 'Mint Green', 'color': Color(0xFF34D399), 'emoji': '💚'},
    {'name': 'Teal Cyan', 'color': Color(0xFF0D9488), 'emoji': '💙'},
    {'name': 'Sky Blue', 'color': Color(0xFF38BDF8), 'emoji': '💙'},
    {'name': 'Navy Blue', 'color': Color(0xFF1E3A8A), 'emoji': '💙'},
    {'name': 'Deep Purple', 'color': Color(0xFF6D28D9), 'emoji': '💜'},
    {'name': 'Lavender', 'color': Color(0xFFC084FC), 'emoji': '💜'},
    {'name': 'Terracotta Brown', 'color': Color(0xFF9A3412), 'emoji': '🤎'},
    {'name': 'Sand Beige', 'color': Color(0xFFE2B07E), 'emoji': '🤎'},
    {'name': 'Chocolate Brown', 'color': Color(0xFF78350F), 'emoji': '🤎'},
    {'name': 'Slate Grey', 'color': Color(0xFF64748B), 'emoji': '🖤'},
    {'name': 'Silver Metallic', 'color': Color(0xFFCBD5E1), 'emoji': '🤍'},
    {'name': 'Sage Green', 'color': Color(0xFF86EFAC), 'emoji': '💚'},
    {'name': 'Wine Red', 'color': Color(0xFF991B1B), 'emoji': '🍷'},
  ];

  @override
  void initState() {
    super.initState();
    OutfitAnalyzer.init();
    _initializeWebcam();
  }

  @override
  void dispose() {
    _hexController.dispose();
    _hoverAnalysisTimer?.cancel();
    super.dispose();
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
      _hoverAnalysisTimer?.cancel();
    }
  }

  Future<void> _captureAndMatchOutfit() async {
    setState(() {
      _isAnalyzing = true;
      _aiProduct = null;
      _customerProduct = null;
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
        final option = _outfitColors.firstWhere(
          (c) => c['name'] == _selectedSimulatorColor,
          orElse: () => _outfitColors[1], // Emerald Green fallback
        );
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

      OutfitAnalyzer.analyze(_webcamVideoElement, (r, g, b) {
        _processColorMatching(r, g, b);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisStatus = 'Failed to analyze: $e';
        });
      }
    }
  }

  String _getClosestColorName(Color c) {
    double minDistance = double.maxFinite;
    String closestName = 'Custom Shade';
    for (var paletteColor in _outfitColors) {
      final Color pc = paletteColor['color'] as Color;
      double distance = math.sqrt(
        math.pow(c.red - pc.red, 2) +
        math.pow(c.green - pc.green, 2) +
        math.pow(c.blue - pc.blue, 2)
      );
      if (distance < minDistance) {
        minDistance = distance;
        closestName = paletteColor['name'];
      }
    }
    return closestName;
  }

  String _getColorFamily(String colorName) {
    switch (colorName) {
      case 'Bridal Maroon':
      case 'Wine Red':
      case 'Crimson Red':
      case 'Rose Pink':
      case 'Deep Purple':
      case 'Lavender':
        return 'red-pink';
      case 'Emerald Green':
      case 'Olive Green':
      case 'Mint Green':
      case 'Sage Green':
        return 'green';
      case 'Royal Indigo':
      case 'Navy Blue':
      case 'Sky Blue':
      case 'Teal Cyan':
        return 'blue';
      case 'Mustard Yellow':
      case 'Golden Amber':
      case 'Coral Orange':
      case 'Terracotta Brown':
      case 'Sand Beige':
      case 'Chocolate Brown':
        return 'yellow-warm';
      case 'Charcoal Black':
      case 'Slate Grey':
        return 'dark';
      case 'Ivory White':
      case 'Silver Metallic':
      default:
        return 'light';
    }
  }

  void _processColorMatching(int r, int g, int b) {
    if (!mounted) return;

    final Color detectedColor = Color.fromARGB(255, r, g, b);
    final String hexCode = '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
    final String name = _getClosestColorName(detectedColor);
    final String family = _getColorFamily(name);

    Map<String, String> aiProduct = {};
    Map<String, String> customerProduct = {};

    switch (family) {
      case 'red-pink':
        aiProduct = {
          'name': 'Bridal Maroon Velvet',
          'price': '₹2,499',
          'image': 'assets/images/bridal_maroon.png',
          'score': '99%',
          'advice': 'AI Suggestion: Monochromatic wedding elegance! Cushioned maroon velvet straps coordinate beautifully with your rich $name tones.'
        };
        customerProduct = {
          'name': 'Royal Wedding Gold',
          'price': '₹2,500',
          'image': 'assets/images/vibrant_blue.png',
          'score': '95%',
          'advice': 'Customer Choice: 91% of brides style $name outfits with Royal Wedding Gold to match heavy gold embroidery.'
        };
        break;
      case 'green':
        aiProduct = {
          'name': 'Royal Wedding Gold',
          'price': '₹2,500',
          'image': 'assets/images/vibrant_blue.png',
          'score': '97%',
          'advice': 'AI Suggestion: High-contrast elegance! Gleaming gold brocade straps offer a striking, premium contrast to your $name attire.'
        };
        customerProduct = {
          'name': 'Classic Tan Kolhapuri',
          'price': '₹1,200',
          'image': 'assets/images/classic_tan.png',
          'score': '89%',
          'advice': 'Customer Choice: 78% of customers style $name outfits with Classic Tan for grounded daily wear.'
        };
        break;
      case 'blue':
        aiProduct = {
          'name': 'Vibrant Indigo Blue',
          'price': '₹1,599',
          'image': 'assets/images/vibrant_blue.png',
          'score': '96%',
          'advice': 'AI Suggestion: Artistic matching! Modern hand-painted blue details on these chappals pair wonderfully with your cool $name tones.'
        };
        customerProduct = {
          'name': 'Classic Tan Kolhapuri',
          'price': '₹1,200',
          'image': 'assets/images/classic_tan.png',
          'score': '91%',
          'advice': 'Customer Choice: 82% of customers choose a neutral Classic Tan contrast for $name dresses.'
        };
        break;
      case 'yellow-warm':
        aiProduct = {
          'name': 'Classic Tan Kolhapuri',
          'price': '₹1,200',
          'image': 'assets/images/classic_tan.png',
          'score': '98%',
          'advice': 'AI Suggestion: Earthy harmony! The organic tan leather tones perfectly mirror warm $name shades for a traditional look.'
        };
        customerProduct = {
          'name': 'Royal Wedding Gold',
          'price': '₹2,500',
          'image': 'assets/images/vibrant_blue.png',
          'score': '92%',
          'advice': 'Customer Choice: 86% of customers wore Royal Wedding Gold with $name outfits for dynamic festive contrast.'
        };
        break;
      case 'dark':
        aiProduct = {
          'name': 'Daily Walk Black',
          'price': '₹850',
          'image': 'assets/images/modern_black.png',
          'score': '99%',
          'advice': 'AI Suggestion: Modern minimal aesthetic! Sleek black chappals create a continuous clean line matching your dark $name tones.'
        };
        customerProduct = {
          'name': 'Royal Wedding Gold',
          'price': '₹2,500',
          'image': 'assets/images/vibrant_blue.png',
          'score': '93%',
          'advice': 'Customer Choice: 75% of customers pair dark outfits like $name with Royal Wedding Gold for high-end party wear.'
        };
        break;
      case 'light':
      default:
        aiProduct = {
          'name': 'Royal Tan Kolhapuri',
          'price': '₹1,899',
          'image': 'assets/images/royal_tan.jpg',
          'score': '95%',
          'advice': 'AI Suggestion: Sophisticated contrast! The premium double-stitched Royal Tan leather makes a rich statement against light $name garments.'
        };
        customerProduct = {
          'name': 'Daily Walk Black',
          'price': '₹850',
          'image': 'assets/images/modern_black.png',
          'score': '88%',
          'advice': 'Customer Choice: 80% of customers prefer the striking monochrome contrast of Daily Walk Black with white/pastels.'
        };
        break;
    }

    setState(() {
      _isAnalyzing = false;
      _detectedColor = detectedColor;
      _detectedHex = hexCode;
      _selectedSimulatorColor = name;
      _aiProduct = aiProduct;
      _customerProduct = customerProduct;
    });
  }

  void _startLiveHoverAnalysis() {
    _hoverAnalysisTimer?.cancel();
    _hoverAnalysisTimer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (!_isAnalyzing && _isCameraInitialized && !_isSimulatorMode && _webcamVideoElement != null) {
        OutfitAnalyzer.analyze(_webcamVideoElement, (r, g, b) {
          if (mounted && !_isAnalyzing && !_isSimulatorMode) {
            _updateHoverMatch(r, g, b);
          }
        });
      }
    });
  }

  void _updateHoverMatch(int r, int g, int b) {
    final Color hoverColor = Color.fromARGB(255, r, g, b);
    final String hexCode = '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
    final String name = _getClosestColorName(hoverColor);
    final String family = _getColorFamily(name);

    Map<String, String> aiProduct = {};
    Map<String, String> customerProduct = {};

    switch (family) {
      case 'red-pink':
        aiProduct = {
          'name': 'Bridal Maroon Velvet',
          'price': '₹2,499',
          'image': 'assets/images/bridal_maroon.png',
          'score': '99%',
          'advice': 'AI Suggestion: Monochromatic wedding elegance! Cushioned maroon velvet straps coordinate beautifully with your rich $name tones.'
        };
        customerProduct = {
          'name': 'Royal Wedding Gold',
          'price': '₹2,500',
          'image': 'assets/images/vibrant_blue.png',
          'score': '95%',
          'advice': 'Customer Choice: 91% of brides style $name outfits with Royal Wedding Gold to match heavy gold embroidery.'
        };
        break;
      case 'green':
        aiProduct = {
          'name': 'Royal Wedding Gold',
          'price': '₹2,500',
          'image': 'assets/images/vibrant_blue.png',
          'score': '97%',
          'advice': 'AI Suggestion: High-contrast elegance! Gleaming gold brocade straps offer a striking, premium contrast to your $name attire.'
        };
        customerProduct = {
          'name': 'Classic Tan Kolhapuri',
          'price': '₹1,200',
          'image': 'assets/images/classic_tan.png',
          'score': '89%',
          'advice': 'Customer Choice: 78% of customers style $name outfits with Classic Tan for grounded daily wear.'
        };
        break;
      case 'blue':
        aiProduct = {
          'name': 'Vibrant Indigo Blue',
          'price': '₹1,599',
          'image': 'assets/images/vibrant_blue.png',
          'score': '96%',
          'advice': 'AI Suggestion: Artistic matching! Modern hand-painted blue details on these chappals pair wonderfully with your cool $name tones.'
        };
        customerProduct = {
          'name': 'Classic Tan Kolhapuri',
          'price': '₹1,200',
          'image': 'assets/images/classic_tan.png',
          'score': '91%',
          'advice': 'Customer Choice: 82% of customers choose a neutral Classic Tan contrast for $name dresses.'
        };
        break;
      case 'yellow-warm':
        aiProduct = {
          'name': 'Classic Tan Kolhapuri',
          'price': '₹1,200',
          'image': 'assets/images/classic_tan.png',
          'score': '98%',
          'advice': 'AI Suggestion: Earthy harmony! The organic tan leather tones perfectly mirror warm $name shades for a traditional look.'
        };
        customerProduct = {
          'name': 'Royal Wedding Gold',
          'price': '₹2,500',
          'image': 'assets/images/vibrant_blue.png',
          'score': '92%',
          'advice': 'Customer Choice: 86% of customers wore Royal Wedding Gold with $name outfits for dynamic festive contrast.'
        };
        break;
      case 'dark':
        aiProduct = {
          'name': 'Daily Walk Black',
          'price': '₹850',
          'image': 'assets/images/modern_black.png',
          'score': '99%',
          'advice': 'AI Suggestion: Modern minimal aesthetic! Sleek black chappals create a continuous clean line matching your dark $name tones.'
        };
        customerProduct = {
          'name': 'Royal Wedding Gold',
          'price': '₹2,500',
          'image': 'assets/images/vibrant_blue.png',
          'score': '93%',
          'advice': 'Customer Choice: 75% of customers pair dark outfits like $name with Royal Wedding Gold for high-end party wear.'
        };
        break;
      case 'light':
      default:
        aiProduct = {
          'name': 'Royal Tan Kolhapuri',
          'price': '₹1,899',
          'image': 'assets/images/royal_tan.jpg',
          'score': '95%',
          'advice': 'AI Suggestion: Sophisticated contrast! The premium double-stitched Royal Tan leather makes a rich statement against light $name garments.'
        };
        customerProduct = {
          'name': 'Daily Walk Black',
          'price': '₹850',
          'image': 'assets/images/modern_black.png',
          'score': '88%',
          'advice': 'Customer Choice: 80% of customers prefer the striking monochrome contrast of Daily Walk Black with white/pastels.'
        };
        break;
    }

    setState(() {
      _detectedColor = hoverColor;
      _detectedHex = hexCode;
      _selectedSimulatorColor = name;
      _aiProduct = aiProduct;
      _customerProduct = customerProduct;
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
                        _aiProduct = null;
                        _customerProduct = null;
                        _detectedColor = null;
                      });
                      if (_isSimulatorMode) {
                        _hoverAnalysisTimer?.cancel();
                      } else {
                        _startLiveHoverAnalysis();
                      }
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
                                    _aiProduct = null;
                                    _customerProduct = null;
                                    _detectedColor = null;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Or Custom Hex:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: TextField(
                              controller: _hexController,
                              style: const TextStyle(fontSize: 12, fontFamily: 'Courier', color: AppTheme.textPrimary),
                              decoration: InputDecoration(
                                hintText: '#E066FF',
                                hintStyle: const TextStyle(color: AppTheme.textMuted),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            final text = _hexController.text.trim();
                            if (text.isNotEmpty) {
                              try {
                                String cleanHex = text.replaceAll('#', '');
                                if (cleanHex.length == 6) {
                                  int r = int.parse(cleanHex.substring(0, 2), radix: 16);
                                  int g = int.parse(cleanHex.substring(2, 4), radix: 16);
                                  int b = int.parse(cleanHex.substring(4, 6), radix: 16);
                                  
                                  setState(() {
                                    _isAnalyzing = true;
                                    _analysisStatus = 'Analyzing custom shade...';
                                    _aiProduct = null;
                                    _customerProduct = null;
                                  });
                                  
                                  Timer(const Duration(milliseconds: 600), () {
                                    _processColorMatching(r, g, b);
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter a valid 6-character hex code (e.g. #FF5733)')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Invalid hex format. Use #RRGGBB.')),
                                );
                              }
                            }
                          },
                          child: const Text('Match', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
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
                              child: createWebcamPreview(
                                onVideoCreated: (videoElement) {
                                  _webcamVideoElement = videoElement;
                                  if (mounted) {
                                    setState(() {
                                      _isCameraPermissionDenied = false;
                                      _isCameraInitialized = true;
                                    });
                                    _startLiveHoverAnalysis();
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
                  if (_aiProduct != null && _customerProduct != null) ...[
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
                          
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 580;
                              final suggestions = [
                                _buildSuggestionCard(
                                  title: '🤖 AI Suggested',
                                  subtitle: 'Color Theory Match',
                                  product: _aiProduct!,
                                  themeColor: AppTheme.primaryColor,
                                ),
                                if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),
                                _buildSuggestionCard(
                                  title: '👥 Customer Choice',
                                  subtitle: 'Popular Selection',
                                  product: _customerProduct!,
                                  themeColor: AppTheme.secondaryColor,
                                ),
                              ];
                              
                              if (isWide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: suggestions[0]),
                                    suggestions[1],
                                    Expanded(child: suggestions[2]),
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    suggestions[0],
                                    suggestions[1],
                                    suggestions[2],
                                  ],
                                );
                              }
                            },
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

  Widget _buildSuggestionCard({
    required String title,
    required String subtitle,
    required Map<String, String> product,
    required Color themeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: themeColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${product['score']} Match',
                  style: const TextStyle(color: Colors.green, fontSize: 8.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  product['image']!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 48,
                    height: 48,
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(Icons.image, color: AppTheme.textMuted, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppTheme.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product['price']!,
                      style: TextStyle(fontWeight: FontWeight.w800, color: themeColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 8),
          Text(
            product['advice']!,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () {
                widget.onProductSelected(product);
              },
              child: const Text('Select this style', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
