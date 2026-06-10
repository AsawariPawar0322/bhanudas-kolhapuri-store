import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildProductDetails()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      backgroundColor: AppTheme.bgDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: widget.product.id,
              child: Image.network(widget.product.imageUrl, fit: BoxFit.cover),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppTheme.bgDark, Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.product.category.toUpperCase(), style: GoogleFonts.montserrat(color: AppTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
              Row(
                children: [
                  const Icon(Icons.star, color: AppTheme.primaryColor, size: 16),
                  const SizedBox(width: 4),
                  Text('${widget.product.rating}', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.product.name.toUpperCase(), style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
          const SizedBox(height: 24),
          Text(
            widget.product.description,
            style: GoogleFonts.montserrat(color: AppTheme.textSecondary, height: 1.7, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _buildInfoGrid(),
          const SizedBox(height: 40),
          Text('SELECT QUANTITY', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.textMuted, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              _qtyBtn(Icons.remove, () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1)),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text('$_quantity', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800)),
              ),
              _qtyBtn(Icons.add, () => setState(() => _quantity++)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${widget.product.stock} IN STOCK', style: GoogleFonts.montserrat(color: AppTheme.successColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        _infoItem('Material', widget.product.material),
        const SizedBox(width: 40),
        _infoItem('Hue', widget.product.color),
      ],
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('INVESTMENT', style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                Text('₹${(widget.product.price * _quantity).toStringAsFixed(0)}', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false).addItem(widget.product, _quantity);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('RESERVED IN YOUR BAG', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1)),
                    backgroundColor: AppTheme.primaryColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: AppDecorations.primaryButton,
              child: const Text('ADD TO BAG'),
            ),
          ),
        ],
      ),
    );
  }
}
