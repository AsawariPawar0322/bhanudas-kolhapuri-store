import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProductGallerySection extends StatefulWidget {
  final Function(Map<String, String>)? onProductTap;
  final String? selectedProductName;

  const ProductGallerySection({
    super.key,
    this.onProductTap,
    this.selectedProductName,
  });

  @override
  State<ProductGallerySection> createState() => _ProductGallerySectionState();
}

class _ProductGallerySectionState extends State<ProductGallerySection> {
  String _selectedCategory = 'All';

  final List<Map<String, String>> _allProducts = [
    {
      'name': 'Classic Tan Kolhapuri',
      'image': 'assets/images/classic_tan.png',
      'price': '₹1,200',
      'category': 'Men',
      'rating': '4.8',
      'tag': '🌿 Organic Leather',
      'description': 'Handcrafted premium leather chappals with custom tan finishes.'
    },
    {
      'name': 'Royal Wedding Gold',
      'image': 'assets/images/vibrant_blue.png',
      'price': '₹2,500',
      'category': 'Women',
      'rating': '4.9',
      'tag': '✨ Gold Brocade',
      'description': 'Elegant metallic brocade weaving for royal wedding occasions.'
    },
    {
      'name': 'Daily Walk Black',
      'image': 'assets/images/modern_black.png',
      'price': '₹850',
      'category': 'Men',
      'rating': '4.5',
      'tag': '👣 Ergonomic Sole',
      'description': 'Durable lightweight chappals with comfort arch support.'
    },
    {
      'name': 'Bridal Maroon Velvet',
      'image': 'assets/images/bridal_maroon.png',
      'price': '₹2,499',
      'category': 'Women',
      'rating': '4.9',
      'tag': '👰 Royal Bridal',
      'description': 'Luxury velvet cushioned straps adorned with golden Zardosi.'
    },
    {
      'name': 'Vibrant Indigo Blue',
      'image': 'assets/images/vibrant_blue.png',
      'price': '₹1,599',
      'category': 'Girls',
      'rating': '4.7',
      'tag': '🎨 Hand-painted',
      'description': 'Modern color combinations hand-stitched by female artisans.'
    },
    {
      'name': 'Royal Tan Kolhapuri',
      'image': 'assets/images/royal_tan.jpg',
      'price': '₹1,899',
      'category': 'Men',
      'rating': '4.8',
      'tag': '👑 Classic Royal',
      'description': 'Authentic double-stitched Kolhapuri leather.'
    },
    {
      'name': 'Kids Comfort Chappal',
      'image': 'assets/images/classic_tan.png',
      'price': '₹590',
      'category': 'Kids',
      'rating': '4.4',
      'tag': '🧸 Soft Inner',
      'description': 'Extra soft lining designed specifically for kids sensitive feet.'
    },
    {
      'name': 'Little Princess Gold',
      'image': 'assets/images/traditional_gold.jpg',
      'price': '₹750',
      'category': 'Girls',
      'rating': '4.8',
      'tag': '⭐ Festive Kids',
      'description': 'Glittering wedding wear details sized for young girls.'
    },
    {
      'name': 'Junior Leather Brown',
      'image': 'assets/images/royal_tan.jpg',
      'price': '₹690',
      'category': 'Boys',
      'rating': '4.5',
      'tag': '🚴 Durable Build',
      'description': 'Sturdy raw leather build capable of handling everyday play.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Men', 'Women', 'Kids', 'Boys', 'Girls'];
    
    // Filter products dynamically based on selected tab category
    final filteredProducts = _selectedCategory == 'All'
        ? _allProducts
        : _allProducts.where((p) => p['category'] == _selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header / Title
        if (widget.onProductTap == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Inventory Showcase',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Text(
                  'View All →',
                  style: TextStyle(color: AppTheme.primaryColor, fontSize: 12),
                ),
              ],
            ),
          ),

        // Horizontal Category Tab Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(
                    cat == 'All' 
                        ? '🏷️ All' 
                        : cat == 'Men' 
                            ? '👨 Men' 
                            : cat == 'Women' 
                                ? '👩 Women' 
                                : cat == 'Kids' 
                                    ? '🧒 Kids' 
                                    : cat == 'Boys' 
                                        ? '👦 Boys' 
                                        : '👧 Girls',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryColor,
                  backgroundColor: const Color(0xFFF1F5F9),
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 8),

        // Premium Cards Grid / List
        filteredProducts.isEmpty
            ? Container(
                height: 250,
                width: double.infinity,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: AppTheme.textMuted, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No products in this category yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              )
            : SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isSelected = widget.selectedProductName == product['name'];

                    return GestureDetector(
                      onTap: () {
                        if (widget.onProductTap != null) {
                          widget.onProductTap!(product);
                        }
                      },
                      child: Container(
                        width: 170,
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        decoration: AppDecorations.glassCard.copyWith(
                          border: Border.all(
                            color: isSelected 
                                ? AppTheme.primaryColor 
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.15),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ] : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image & Custom Tags Overlay
                            Expanded(
                              flex: 5,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                    child: Image.asset(
                                      product['image']!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: const Color(0xFFF8FAFC),
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.image, color: AppTheme.textMuted, size: 36),
                                      ),
                                    ),
                                  ),
                                  // Category mini badge
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        product['category']!.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Selection indicators
                                  if (isSelected)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check, size: 12, color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            
                            // Product Info
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Product Name
                                        Text(
                                          product['name']!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        // Handmade badge/tag
                                        Text(
                                          product['tag']!,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: AppTheme.secondaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Price & Rating Info Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          product['price']!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 10, color: Colors.amber),
                                            const SizedBox(width: 2),
                                            Text(
                                              product['rating']!,
                                              style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
