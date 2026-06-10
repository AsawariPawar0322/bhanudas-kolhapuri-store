import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final apiService = ApiService();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('My Shopping Bag 🛍️'),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final item = cart.items.values.toList()[i];
                      return _buildCartItem(context, item, cart);
                    },
                  ),
                ),
                _buildOrderSummary(context, cart, apiService),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎒', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          const Text('Your bag is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Looks like you haven\'t added anything yet.', style: TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: AppDecorations.primaryButton,
            child: const Text('Go Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, dynamic item, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.glassCard,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(item.product.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${item.product.material} • ${item.product.color}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹${item.product.price} x ${item.quantity}', style: const TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold)),
                    Text('₹${item.totalPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => cart.removeItem(item.product.id),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart, ApiService apiService) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow('Subtotal', '₹${cart.totalAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            _summaryRow('Shipping', 'FREE'),
            const Divider(height: 32, color: Colors.white10),
            _summaryRow('Total', '₹${cart.totalAmount.toStringAsFixed(0)}', isTotal: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // In a real app, we'd loop through cart items and create orders
                  // For the prototype, we create one combined order entry for the artisan
                  final firstItem = cart.items.values.first;
                  final success = await apiService.createOrder({
                    'customer_name': 'Sahil', // This would come from auth state
                    'product': cart.items.length > 1 ? '${firstItem.product.name} + others' : firstItem.product.name,
                    'color': firstItem.product.color,
                    'size': 9, // Example size
                    'quantity': cart.items.length,
                    'amount': cart.totalAmount,
                    'status': 'pending',
                    'source': 'online',
                  });

                  if (success) {
                    cart.clear();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppTheme.bgCard,
                        title: const Text('Order Placed! 🎊'),
                        content: const Text('Your order request has been sent to the artisan for approval.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            },
                            child: const Text('Track Order'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                style: AppDecorations.primaryButton,
                child: const Text('Place Order Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.white : AppTheme.textMuted, fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: isTotal ? AppTheme.primaryColor : Colors.white, fontSize: isTotal ? 24 : 16, fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold)),
      ],
    );
  }
}
