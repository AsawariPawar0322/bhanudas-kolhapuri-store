import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class LastOrderCard extends StatefulWidget {
  const LastOrderCard({super.key});

  @override
  State<LastOrderCard> createState() => _LastOrderCardState();
}

class _LastOrderCardState extends State<LastOrderCard> {
  final ApiService _apiService = ApiService();
  dynamic _lastOrder;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLastOrder();
  }

  Future<void> _fetchLastOrder() async {
    final orders = await _apiService.getOrders();
    if (mounted) {
      setState(() {
        _lastOrder = orders.isNotEmpty ? orders.last : null;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String status) async {
    if (_lastOrder == null) return;
    bool success = await _apiService.updateOrderStatus(_lastOrder['id'], status);
    if (success) {
      _fetchLastOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_lastOrder == null) return _noOrderBox();

    final status = _lastOrder['status'];

    return Container(
      decoration: AppDecorations.glassCard.copyWith(
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🔔 LAST ORDER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryLight, letterSpacing: 1.2)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 14, color: AppTheme.primaryLight),
                    onPressed: _fetchLastOrder,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text('#${_lastOrder['id']}', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_lastOrder['customer_name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text('${_lastOrder['product']} - ${_lastOrder['color']}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 16),
          
          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus('rejected'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.2), foregroundColor: Colors.red, elevation: 0),
                    child: const Text('Reject', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus('accepted'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Accept', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            )
          else if (status == 'accepted')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _updateStatus('completed'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
                child: const Text('Mark Completed', style: TextStyle(fontSize: 12)),
              ),
            )
          else
            Center(
              child: Text(status == 'rejected' ? '❌ Order Rejected' : '✅ Order Completed', 
                style: TextStyle(color: status == 'rejected' ? Colors.red : AppTheme.accentColor, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _noOrderBox() {
    return Container(
      decoration: AppDecorations.glassCard,
      padding: const EdgeInsets.all(16),
      child: const Center(child: Text('No orders yet', style: TextStyle(color: AppTheme.textMuted))),
    );
  }
}
