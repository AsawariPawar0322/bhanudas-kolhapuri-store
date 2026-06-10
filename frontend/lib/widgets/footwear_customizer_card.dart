import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import 'hover_lift_wrapper.dart';

class FootwearCustomizerCard extends StatefulWidget {
  const FootwearCustomizerCard({super.key});

  @override
  State<FootwearCustomizerCard> createState() => _FootwearCustomizerCardState();
}

class _FootwearCustomizerCardState extends State<FootwearCustomizerCard> {
  // Customization Options
  String _selectedLeather = 'Sienna Tan';
  String _selectedEmbroidery = 'Gold Brocade';
  String _selectedSole = 'Double Leather';
  String _engravingText = '';

  final Map<String, Color> _leatherColors = {
    'Sienna Tan': const Color(0xFFC27D38),
    'Charcoal Black': const Color(0xFF1E293B),
    'Honey Brown': const Color(0xFF854D0E),
    'Mustard Gold': const Color(0xFFD97706),
  };

  final Map<String, Color> _embroideryColors = {
    'Gold Brocade': const Color(0xFFFBBF24),
    'Silver Thread': const Color(0xFFCBD5E1),
    'Silk Maroon': const Color(0xFFB91C1C),
    'Silk Blue': const Color(0xFF1D4ED8),
  };

  int _calculatePrice() {
    int basePrice = 1800;
    if (_selectedSole == 'Double Leather') basePrice += 200;
    if (_selectedSole == 'Cushioned Rubber') basePrice += 150;
    if (_selectedEmbroidery != 'Silver Thread') basePrice += 100;
    if (_engravingText.isNotEmpty) basePrice += 150; // Custom engraving fee
    return basePrice;
  }

  @override
  Widget build(BuildContext context) {
    final leatherColor = _leatherColors[_selectedLeather] ?? const Color(0xFFC27D38);
    final embroideryColor = _embroideryColors[_selectedEmbroidery] ?? const Color(0xFFFBBF24);
    final isDoubleSole = _selectedSole == 'Double Leather';

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
                      '3D Craft Customizer',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Configure materials, sole engraving & detailing in real-time 🎨',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: const Text(
                    '3D INTERACTIVE',
                    style: TextStyle(fontSize: 10, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Live Vector Preview Box
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(180, 240),
                        painter: ChappalPainter(
                          leatherColor: leatherColor,
                          embroideryColor: embroideryColor,
                          isDoubleSole: isDoubleSole,
                          engravingText: _engravingText,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Controls
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leather finish selection
                      const Text('Leather Finish', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                      const SizedBox(height: 8),
                      _buildOptionsRow(
                        options: _leatherColors.keys.toList(),
                        selected: _selectedLeather,
                        onSelected: (val) => setState(() => _selectedLeather = val),
                      ),
                      const SizedBox(height: 16),

                      // Embroidery Selection
                      const Text('Embroidery Accent', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                      const SizedBox(height: 8),
                      _buildOptionsRow(
                        options: _embroideryColors.keys.toList(),
                        selected: _selectedEmbroidery,
                        onSelected: (val) => setState(() => _selectedEmbroidery = val),
                      ),
                      const SizedBox(height: 16),

                      // Sole Selection
                      const Text('Sole Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                      const SizedBox(height: 8),
                      _buildOptionsRow(
                        options: const ['Single Leather', 'Double Leather', 'Cushioned Rubber'],
                        selected: _selectedSole,
                        onSelected: (val) => setState(() => _selectedSole = val),
                      ),
                      const SizedBox(height: 16),

                      // Custom Engraving
                      const Text('Monogram Engraving (Max 3 Letters)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                      const SizedBox(height: 8),
                      TextField(
                        maxLength: 3,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'e.g. ARS',
                          counterText: '',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.primaryColor),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _engravingText = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 16),

            // Cart Checkout Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estimated Cost', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_calculatePrice()}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final suffix = _engravingText.isNotEmpty ? ' with monogram "$_engravingText"' : '';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Custom $_selectedLeather pair$suffix added to checkout bag! 🛒'),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                  label: const Text('Checkout Design', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsRow({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSel = opt == selected;
        return ChoiceChip(
          label: Text(opt, style: TextStyle(fontSize: 10, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
          selected: isSel,
          onSelected: (_) => onSelected(opt),
          selectedColor: AppTheme.primaryColor.withOpacity(0.12),
          checkmarkColor: AppTheme.primaryColor,
          labelStyle: TextStyle(color: isSel ? AppTheme.primaryColor : AppTheme.textSecondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: isSel ? AppTheme.primaryColor.withOpacity(0.3) : const Color(0xFFE2E8F0)),
          ),
        );
      }).toList(),
    );
  }
}

class ChappalPainter extends CustomPainter {
  final Color leatherColor;
  final Color embroideryColor;
  final bool isDoubleSole;
  final String engravingText;

  ChappalPainter({
    required this.leatherColor,
    required this.embroideryColor,
    required this.isDoubleSole,
    required this.engravingText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = leatherColor;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black.withOpacity(0.15)
      ..strokeWidth = 1.0;

    final stitchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFF1E4C3).withOpacity(0.7) // Cream stitching
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // 1. Draw Sole Base (Left foot shape)
    final solePath = Path();
    solePath.moveTo(cx - 30, cy - 80); // Top left curve
    solePath.quadraticBezierTo(cx - 45, cy - 20, cx - 35, cy + 40); // Left arch
    solePath.quadraticBezierTo(cx - 25, cy + 90, cx, cy + 90); // Heel curve
    solePath.quadraticBezierTo(cx + 25, cy + 90, cx + 30, cy + 40); // Right heel
    solePath.quadraticBezierTo(cx + 20, cy - 20, cx + 35, cy - 60); // Right arch
    solePath.quadraticBezierTo(cx + 40, cy - 90, cx, cy - 90); // Toe front curve
    solePath.close();

    // Sole shadow
    canvas.drawPath(
      solePath.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withOpacity(0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Sole Leather Fill
    canvas.drawPath(solePath, paint);
    canvas.drawPath(solePath, strokePaint);

    // Double Sole Line
    if (isDoubleSole) {
      canvas.drawPath(
        solePath.shift(const Offset(0, 2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.black.withOpacity(0.3)
          ..strokeWidth = 1.5,
      );
    }

    // Sole Stitching (Dotted boundary inset)
    final stitchPath = Path();
    stitchPath.moveTo(cx - 26, cy - 76);
    stitchPath.quadraticBezierTo(cx - 39, cy - 20, cx - 31, cy + 38);
    stitchPath.quadraticBezierTo(cx - 21, cy + 84, cx, cy + 84);
    stitchPath.quadraticBezierTo(cx + 21, cy + 84, cx + 26, cy + 38);
    stitchPath.quadraticBezierTo(cx + 17, cy - 20, cx + 31, cy - 58);
    stitchPath.quadraticBezierTo(cx + 34, cy - 84, cx, cy - 84);
    stitchPath.close();

    // Draw little dashes manually for realistic stitching
    canvas.drawPath(stitchPath, stitchPaint);

    // 2. Draw Heel Pad
    final heelPadPath = Path();
    heelPadPath.moveTo(cx - 20, cy + 20);
    heelPadPath.quadraticBezierTo(cx - 25, cy + 50, cx - 18, cy + 80);
    heelPadPath.quadraticBezierTo(cx, cy + 88, cx + 18, cy + 80);
    heelPadPath.quadraticBezierTo(cx + 25, cy + 50, cx + 20, cy + 20);
    heelPadPath.quadraticBezierTo(cx, cy + 15, cx - 20, cy + 20);
    heelPadPath.close();

    canvas.drawPath(
      heelPadPath,
      Paint()
        ..style = PaintingStyle.fill
        ..color = leatherColor.withRed(math.max(0, leatherColor.red - 20)),
    );
    canvas.drawPath(heelPadPath, strokePaint);

    // 3. Draw Side Flaps
    final leftFlap = Path()
      ..moveTo(cx - 32, cy - 20)
      ..lineTo(cx - 15, cy - 10)
      ..lineTo(cx - 20, cy + 10)
      ..lineTo(cx - 32, cy + 15)
      ..close();

    final rightFlap = Path()
      ..moveTo(cx + 32, cy - 20)
      ..lineTo(cx + 15, cy - 10)
      ..lineTo(cx + 20, cy + 10)
      ..lineTo(cx + 32, cy + 15)
      ..close();

    canvas.drawPath(leftFlap, paint);
    canvas.drawPath(leftFlap, strokePaint);
    canvas.drawPath(rightFlap, paint);
    canvas.drawPath(rightFlap, strokePaint);

    // 4. Draw Y-Strap (Embroidery cross overlay)
    final strapPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = leatherColor;

    final yStrapLeft = Path()
      ..moveTo(cx - 30, cy - 35)
      ..quadraticBezierTo(cx - 10, cy - 40, cx, cy - 65)
      ..lineTo(cx + 5, cy - 62)
      ..quadraticBezierTo(cx - 8, cy - 35, cx - 26, cy - 30)
      ..close();

    final yStrapRight = Path()
      ..moveTo(cx + 30, cy - 35)
      ..quadraticBezierTo(cx + 10, cy - 40, cx, cy - 65)
      ..lineTo(cx - 5, cy - 62)
      ..quadraticBezierTo(cx + 8, cy - 35, cx + 26, cy - 30)
      ..close();

    canvas.drawPath(yStrapLeft, strapPaint);
    canvas.drawPath(yStrapLeft, strokePaint);
    canvas.drawPath(yStrapRight, strapPaint);
    canvas.drawPath(yStrapRight, strokePaint);

    // 5. Draw Embroidery Accent (Pattern overlay along Y-strap)
    final embroideryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = embroideryColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final embLeft = Path()
      ..moveTo(cx - 26, cy - 33)
      ..quadraticBezierTo(cx - 9, cy - 38, cx + 2, cy - 63);

    final embRight = Path()
      ..moveTo(cx + 26, cy - 33)
      ..quadraticBezierTo(cx + 9, cy - 38, cx - 2, cy - 63);

    canvas.drawPath(embLeft, embroideryPaint);
    canvas.drawPath(embRight, embroideryPaint);

    // 6. Draw Toe Loop & Knot (Classic Kolhapuri detailing)
    final toeLoop = Path();
    toeLoop.addOval(Rect.fromCircle(center: Offset(cx - 12, cy - 65), radius: 10));
    canvas.drawPath(
      toeLoop,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = leatherColor
        ..strokeWidth = 4.0,
    );
    canvas.drawPath(
      toeLoop,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black.withOpacity(0.3)
        ..strokeWidth = 1.0,
    );

    // Toe loop center dot
    canvas.drawCircle(Offset(cx - 12, cy - 65), 3, Paint()..color = embroideryColor);

    // 7. Draw Monogram Engraving on Heel Pad
    if (engravingText.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: engravingText.toUpperCase(),
          style: TextStyle(
            color: Colors.black.withOpacity(0.35),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            fontFamily: 'Courier',
            letterSpacing: 2.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(cx - textPainter.width / 2, cy + 50),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ChappalPainter oldDelegate) {
    return oldDelegate.leatherColor != leatherColor ||
        oldDelegate.embroideryColor != embroideryColor ||
        oldDelegate.isDoubleSole != isDoubleSole ||
        oldDelegate.engravingText != engravingText;
  }
}
