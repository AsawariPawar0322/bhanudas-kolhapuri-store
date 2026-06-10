import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class OrdersList extends StatefulWidget {
  const OrdersList({super.key});

  @override
  State<OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = _apiService.getOrders();
    });
  }

  Future<void> _updateStatus(String orderId, String status) async {
    bool success = await _apiService.updateOrderStatus(orderId, status);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order $status successfully'),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
        ),
      );
      _refreshOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  'Recent Orders',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.primaryLight),
                onPressed: _refreshOrders,
              )
            ],
          ),
          const SizedBox(height: 8),
          Text('Manage orders online or offline', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          FutureBuilder<List<dynamic>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No orders found', style: TextStyle(color: Colors.white54));
              }

              final orders = snapshot.data!; // reversed to show newest first if needed, but API appends
              return Column(
                children: orders.reversed.map((o) => _orderItem(context, o)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _orderItem(BuildContext context, dynamic order) {
    // Handle both straight map and model structure if needed, but raw API returns JSON map
    final String id = order['id'];
    final String name = order['customer_name'];
    final String product = order['product'];
    final String color = order['color'];
    final int qty = order['quantity'];
    final double amount = order['amount'];
    final String status = order['status'];

    Color statusColor;
    String statusText;
    
    switch(status) {
      case 'accepted':
        statusColor = Colors.green;
        statusText = 'Accepted ✅';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rejected ❌';
        break;
      case 'completed':
        statusColor = AppTheme.accentColor;
        statusText = 'Done ✓';
        break;
      default:
        statusColor = AppTheme.secondaryColor;
        statusText = 'Pending ⏳';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text('#${id.substring(id.length - 4)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryLight))),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$product - $color', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                Text('Qty: $qty', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(statusText, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          
          // Action Buttons for Pending Orders
          if (status == 'pending')
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      ),
                      onPressed: () => _updateStatus(id, 'rejected'),
                      child: const Text('Reject', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      ),
                      onPressed: () => _updateStatus(id, 'accepted'),
                      child: const Text('Accept Order', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
