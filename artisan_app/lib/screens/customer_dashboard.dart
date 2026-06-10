import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final ApiService _apiService = ApiService();
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Traditional', 'Wedding', 'Daily Wear', 'Casual'];
  late Future<List<Product>> _productsFuture;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = _apiService.getProducts(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, cart),
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildCategories()),
          _buildProductGrid(),
        ],
      ),
      floatingActionButton: cart.itemCount > 0 
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            backgroundColor: AppTheme.primaryColor,
            icon: const Icon(Icons.shopping_cart),
            label: Text('${cart.itemCount} Items | ₹${cart.totalAmount.toStringAsFixed(0)}'),
          )
        : null,
    );
  }

  Widget _buildAppBar(BuildContext context, CartProvider cart) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.bgDark.withOpacity(0.9),
      title: Text('CEREMONIALS', style: GoogleFonts.playfairDisplay(letterSpacing: 4, fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryColor),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppTheme.secondaryColor, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('${cart.itemCount}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'The ', style: GoogleFonts.playfairDisplay(fontSize: 32, color: Colors.white)),
                TextSpan(text: 'Artisan ', style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
                TextSpan(text: 'Collection', style: GoogleFonts.playfairDisplay(fontSize: 32, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('Hand-stitched authenticity for the modern stride.', style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 13, letterSpacing: 0.5)),
          const SizedBox(height: 24),
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: AppDecorations.inputDecoration('Seek your perfect match...', Icons.search_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                  _loadProducts();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.white10),
                ),
                child: Center(
                  child: Text(
                    cat.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? AppTheme.bgDark : AppTheme.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(child: Center(child: Text('No products found')));
        }

        final products = snapshot.data!
            .where((p) => p.name.toLowerCase().contains(_searchQuery))
            .toList();
            
        if (products.isEmpty) {
          return const SliverToBoxAdapter(child: Center(child: Text('No matches found')));
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ProductCard(product: products[index]),
              childCount: products.length,
            ),
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: AppDecorations.glassCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                   Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Image.network(product.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 10, color: AppTheme.primaryColor),
                          const SizedBox(width: 4),
                          Text('${product.rating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name.toUpperCase(), style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.white, letterSpacing: 1), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(product.category.toUpperCase(), style: GoogleFonts.montserrat(color: AppTheme.primaryColor, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${product.price.toStringAsFixed(0)}', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                      Icon(Icons.add_circle_outline, size: 18, color: AppTheme.primaryColor.withOpacity(0.8)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
