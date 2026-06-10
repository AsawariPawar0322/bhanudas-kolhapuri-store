import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/order.dart';
import 'hover_lift_wrapper.dart';

class OrdersSection extends StatelessWidget {
  const OrdersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final orders = provider.orders.isNotEmpty
            ? provider.orders
            : _getSampleOrders();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  'Recent Orders',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage orders online or offline',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              // Orders list
              ...orders.take(4).map((order) => _buildOrderItem(context, order)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderItem(BuildContext context, Order order) {
    final isOffline = order.source == 'offline' || order.source == 'voice';
    
    Color statusBgColor;
    Color statusTextColor;
    String statusText;
    
    switch (order.status) {
      case 'pending':
        statusBgColor = const Color(0xFFFEF3C7); // Amber 100
        statusTextColor = const Color(0xFFB45309); // Amber 700
        statusText = 'Pending ⏳';
        break;
      case 'accepted':
      case 'in_production':
        statusBgColor = const Color(0xFFE0F2FE); // Sky 100
        statusTextColor = const Color(0xFF0369A1); // Sky 700
        statusText = order.completionDays != null 
            ? 'Accepted (${order.completionDays}d) 🔨' 
            : 'Accepted 🔨';
        break;
      case 'completed':
        statusBgColor = const Color(0xFFD1FAE5); // Emerald 100
        statusTextColor = const Color(0xFF047857); // Emerald 700
        statusText = 'Done ✓';
        break;
      case 'rejected':
      case 'cancelled':
        statusBgColor = const Color(0xFFFEE2E2); // Red 100
        statusTextColor = const Color(0xFFB91C1C); // Red 700
        statusText = 'Rejected ❌';
        break;
      default:
        statusBgColor = const Color(0xFFF1F5F9); // Slate 100
        statusTextColor = AppTheme.textSecondary;
        statusText = order.status;
    }

    return HoverLiftWrapper(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOffline
                ? AppTheme.secondaryColor.withOpacity(0.4)
                : const Color(0xFFE2E8F0), // Clean light slate border
            width: isOffline ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    // Order ID Box
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '#${order.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Order details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${order.color} × ${order.quantity} (Size ${order.size})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Amount & Actions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${order.amount.toInt()}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // WhatsApp Share Action
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Opening WhatsApp for ${order.customerName}...'),
                                    backgroundColor: AppTheme.accentColor,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF25D366).withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text('💬', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!order.synced)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Text('📴', style: TextStyle(fontSize: 12)),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: statusTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (order.status == 'completed') ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Delivery Partner assigned! 🚚'), backgroundColor: AppTheme.primaryColor),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                                  ),
                                  child: const Text('Deliver 🚚', style: TextStyle(fontSize: 9.5, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (order.status == 'pending') ...[
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Reject Button
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          backgroundColor: const Color(0xFFEF4444).withOpacity(0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          _handleReject(context, order);
                        },
                        icon: const Icon(Icons.close, size: 14),
                        label: const Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      // Accept Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06B6D4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          _showEstimationSheet(context, order);
                        },
                        icon: const Icon(Icons.check, size: 14),
                        label: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ));
  }

  void _handleReject(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        surfaceTintColor: Colors.transparent,
        title: const Text('Reject Order?', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to reject this order from ${order.customerName}? This will notify the buyer and initialize a refund.',
          style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AppProvider>(context, listen: false).updateOrderStatus(order.id!, 'rejected');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order #${order.id} rejected.'),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
            },
            child: const Text('Yes, Reject', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEstimationSheet(BuildContext context, Order order) {
    int days = 5;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          String workloadText = '🔨 Standard Crafting';
          Color workloadColor = const Color(0xFF3B82F6);
          if (days <= 3) {
            workloadText = '⚡ Express Fabrication';
            workloadColor = const Color(0xFFF59E0B);
          } else if (days >= 8) {
            workloadText = '🎨 Masterpiece Craftsmanship';
            workloadColor = const Color(0xFF8B5CF6);
          }

          return Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0), // Light slate dialog handle
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Accept Order Scheduling',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Set estimated completion days to begin fabrication and track progress.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Days Counter Showcase
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC), // Slate 50 background
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$days Days',
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: workloadColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: workloadColor.withOpacity(0.2)),
                          ),
                          child: Text(
                            workloadText,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: workloadColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF06B6D4),
                      inactiveTrackColor: const Color(0xFFE2E8F0),
                      thumbColor: const Color(0xFF06B6D4),
                      overlayColor: const Color(0xFF06B6D4).withOpacity(0.12),
                      valueIndicatorColor: const Color(0xFF06B6D4),
                      valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    child: Slider(
                      value: days.toDouble(),
                      min: 1.0,
                      max: 15.0,
                      divisions: 14,
                      label: '$days Days',
                      onChanged: (val) {
                        setModalState(() {
                          days = val.round();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('1 Day (Express)', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      Text('15 Days (Masterpiece)', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06B6D4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Provider.of<AppProvider>(context, listen: false).updateOrderStatus(order.id!, 'accepted', completionDays: days);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Order #${order.id} accepted with $days days estimation. 🔨'),
                                backgroundColor: const Color(0xFF06B6D4),
                              ),
                            );
                          },
                          child: const Text('Accept & Schedule 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Order> _getSampleOrders() {
    return [
      Order(id: '1248', customerName: 'Rajesh Patil', product: 'Kolhapuri Chappal', color: 'Brown', size: 9, quantity: 2, amount: 1800, status: 'pending', source: 'online', synced: true),
      Order(id: '1247', customerName: 'Suresh More', product: 'Kolhapuri Chappal', color: 'Black', size: 8, quantity: 1, amount: 1200, status: 'pending', source: 'voice', synced: false),
      Order(id: '1246', customerName: 'Priya Deshmukh', product: 'Kolhapuri Chappal', color: 'Tan', size: 6, quantity: 3, amount: 2400, status: 'completed', source: 'online', synced: true),
      Order(id: '1245', customerName: 'Mumbai Wholesale', product: 'Kolhapuri Chappal', color: 'Mixed', size: 0, quantity: 50, amount: 35000, status: 'completed', source: 'online', synced: true),
    ];
  }
}
