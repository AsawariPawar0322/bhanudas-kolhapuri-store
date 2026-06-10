import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showNewOrder(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('➕', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            const Text(
              'New Order',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Click to create',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewOrder(BuildContext context) {
    List<int> selectedIndices = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text('➕ New Order', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 4),
                Text('Select types and enter details', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),

                // Chappal Type Selection
                Text('Choose Chappal Types', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: chappalTypes.length,
                    itemBuilder: (context, index) {
                      final type = chappalTypes[index];
                      final isSelected = selectedIndices.contains(index);
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            if (isSelected) {
                              selectedIndices.remove(index);
                            } else {
                              selectedIndices.add(index);
                            }
                          });
                        },
                        child: Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  type.imagePath,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported, size: 40, color: Colors.white24),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                type.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),
                _field('Customer Name'),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _field('Color')),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Size')),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _field('Qty')),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Amount ₹')),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Create Order', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class ChappalType {
  final String name;
  final String imagePath;
  final double price;
  ChappalType({required this.name, required this.imagePath, required this.price});
}

final List<ChappalType> chappalTypes = [
  ChappalType(name: 'Classic Tan', imagePath: 'assets/images/classic_tan.png', price: 1200),
  ChappalType(name: 'Bridal Maroon', imagePath: 'assets/images/bridal_maroon.png', price: 2500),
  ChappalType(name: 'Modern Black', imagePath: 'assets/images/modern_black.png', price: 1500),
  ChappalType(name: 'Vibrant Blue', imagePath: 'assets/images/vibrant_blue.png', price: 1800),
];
