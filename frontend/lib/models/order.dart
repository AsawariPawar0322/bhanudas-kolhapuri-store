class Order {
  final String? id;
  final String customerName;
  final String product;
  final String color;
  final int size;
  final int quantity;
  final double amount;
  String status;
  int? completionDays;
  final String source;
  final DateTime? createdAt;
  bool synced;

  Order({
    this.id,
    required this.customerName,
    required this.product,
    required this.color,
    required this.size,
    required this.quantity,
    required this.amount,
    this.status = 'pending',
    this.completionDays,
    this.source = 'online',
    this.createdAt,
    this.synced = true,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customer_name'],
      product: json['product'],
      color: json['color'],
      size: json['size'],
      quantity: json['quantity'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] ?? 'pending',
      completionDays: json['completion_days'],
      source: json['source'] ?? 'online',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      synced: json['synced'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'product': product,
      'color': color,
      'size': size,
      'quantity': quantity,
      'amount': amount,
      'status': status,
      'completion_days': completionDays,
      'source': source,
      'created_at': createdAt?.toIso8601String(),
      'synced': synced,
    };
  }

  String get statusEmoji {
    switch (status) {
      case 'pending':
        return '⏳';
      case 'accepted':
      case 'in_production':
        return '🔨';
      case 'completed':
        return '✅';
      case 'rejected':
      case 'cancelled':
        return '❌';
      default:
        return '📦';
    }
  }

  String get sourceEmoji {
    switch (source) {
      case 'voice':
        return '🎙️';
      case 'offline':
        return '📴';
      default:
        return '🌐';
    }
  }
}
