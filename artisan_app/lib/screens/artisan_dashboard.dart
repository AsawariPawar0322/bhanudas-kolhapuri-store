import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class StockItem {
  String type;
  String size;
  String fabric;
  String color;
  int quantity;
  double price;

  StockItem({
    required this.type,
    required this.size,
    required this.fabric,
    required this.color,
    required this.quantity,
    required this.price,
  });
}

class RawMaterialOrder {
  String material;
  String type;
  double quantity;
  String unit;
  double pricePerUnit;
  String sellerName;
  String status;

  RawMaterialOrder({
    required this.material,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.sellerName,
    this.status = 'Pending',
  });

  double get totalPrice => quantity * pricePerUnit;
}

class DeliveryRequest {
  String type; // 'customer' or 'raw_material'
  String from;
  String to;
  String status;
  String partner;

  DeliveryRequest({
    required this.type,
    required this.from,
    required this.to,
    this.status = 'Available',
    this.partner = '',
  });
}

// ─── Artisan Dashboard ───────────────────────────────────────────────────────

class ArtisanDashboard extends StatefulWidget {
  const ArtisanDashboard({super.key});

  @override
  State<ArtisanDashboard> createState() => _ArtisanDashboardState();
}

class _ArtisanDashboardState extends State<ArtisanDashboard> {
  int _currentTab = 0;

  final List<StockItem> _stockItems = [
    StockItem(type: 'Kolhapuri', size: '8', fabric: 'Leather', color: 'Brown', quantity: 24, price: 850),
    StockItem(type: 'Mojari', size: '7', fabric: 'Suede', color: 'Black', quantity: 12, price: 1200),
    StockItem(type: 'Jutti', size: '9', fabric: 'Velvet', color: 'Red', quantity: 8, price: 950),
  ];

  final List<RawMaterialOrder> _rawOrders = [
    RawMaterialOrder(material: 'Leather', type: 'Full Grain', quantity: 10, unit: 'sq ft', pricePerUnit: 120, sellerName: 'Raza Traders', status: 'Delivered'),
    RawMaterialOrder(material: 'Thread', type: 'Waxed Cotton', quantity: 5, unit: 'rolls', pricePerUnit: 80, sellerName: 'Suresh Suppliers', status: 'Pending'),
  ];

  final List<DeliveryRequest> _deliveries = [
    DeliveryRequest(type: 'customer', from: 'Workshop, Agra', to: 'Customer, Delhi', status: 'In Transit', partner: 'Delhivery'),
    DeliveryRequest(type: 'raw_material', from: 'Raza Traders, Kanpur', to: 'Workshop, Agra', status: 'Available', partner: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: IndexedStack(
        index: _currentTab,
        children: [
          _StockTab(stockItems: _stockItems, onAdd: _addStockItem),
          _RawMaterialTab(orders: _rawOrders, onAdd: _addRawOrder),
          _DeliveryTab(deliveries: _deliveries, onAdd: _addDelivery),
          _AccountTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final tabs = [
      (Icons.inventory_2_outlined, Icons.inventory_2, 'Stock'),
      (Icons.grass_outlined, Icons.grass, 'Raw Material'),
      (Icons.local_shipping_outlined, Icons.local_shipping, 'Delivery'),
      (Icons.person_outline, Icons.person, 'Account'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (i) {
              final isActive = _currentTab == i;
              return GestureDetector(
                onTap: () => setState(() => _currentTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primaryColor.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isActive ? tabs[i].$2 : tabs[i].$1,
                          color: isActive ? AppTheme.primaryColor : AppTheme.textMuted,
                          size: 22),
                      const SizedBox(height: 4),
                      Text(tabs[i].$3,
                          style: GoogleFonts.montserrat(
                              color: isActive ? AppTheme.primaryColor : AppTheme.textMuted,
                              fontSize: 10,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _addStockItem(StockItem item) => setState(() => _stockItems.insert(0, item));
  void _addRawOrder(RawMaterialOrder order) => setState(() => _rawOrders.insert(0, order));
  void _addDelivery(DeliveryRequest delivery) => setState(() => _deliveries.insert(0, delivery));
}

// ─── Stock Tab ───────────────────────────────────────────────────────────────

class _StockTab extends StatelessWidget {
  final List<StockItem> stockItems;
  final void Function(StockItem) onAdd;
  const _StockTab({required this.stockItems, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          _artisanAppBar(context, 'Stock Management', '📦'),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Summary row
                Row(
                  children: [
                    _summaryCard('Total Items', '${stockItems.length}', Icons.inventory_2_outlined),
                    const SizedBox(width: 12),
                    _summaryCard('Total Units',
                        '${stockItems.fold(0, (s, i) => s + i.quantity)}',
                        Icons.numbers_outlined),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Stock',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    ElevatedButton.icon(
                      onPressed: () => _showAddStockSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.bgDark,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text('Add Stock',
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...stockItems.map((item) => _StockCard(item: item)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.glassCard,
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 22),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: GoogleFonts.montserrat(
                        color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                Text(label,
                    style: GoogleFonts.montserrat(
                        color: AppTheme.textMuted, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStockSheet(BuildContext context) {
    final typeCtrl = TextEditingController();
    final sizeCtrl = TextEditingController();
    final fabricCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    final types = ['Kolhapuri', 'Mojari', 'Jutti', 'Sandal', 'Chappal', 'Slipper'];
    final sizes = ['5', '6', '7', '8', '9', '10', '11'];
    final fabrics = ['Leather', 'Suede', 'Velvet', 'Jute', 'Canvas', 'Rubber'];
    final colors = ['Brown', 'Black', 'Tan', 'Red', 'White', 'Beige', 'Navy'];

    String selectedType = types[0];
    String selectedSize = sizes[2];
    String selectedFabric = fabrics[0];
    String selectedColor = colors[0];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24,
              MediaQuery.of(ctx).viewInsets.bottom + 40),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(),
                const SizedBox(height: 16),
                Text('Add New Stock',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 24),

                _dropdownField('Type', types, selectedType,
                    (v) => setSheet(() => selectedType = v!)),
                const SizedBox(height: 14),
                _dropdownField('Size', sizes, selectedSize,
                    (v) => setSheet(() => selectedSize = v!)),
                const SizedBox(height: 14),
                _dropdownField('Fabric / Material', fabrics, selectedFabric,
                    (v) => setSheet(() => selectedFabric = v!)),
                const SizedBox(height: 14),
                _dropdownField('Color', colors, selectedColor,
                    (v) => setSheet(() => selectedColor = v!)),
                const SizedBox(height: 14),
                _textField(qtyCtrl, 'Quantity', Icons.numbers, TextInputType.number),
                const SizedBox(height: 14),
                _textField(priceCtrl, 'Price per pair (₹)', Icons.currency_rupee, TextInputType.number),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final qty = int.tryParse(qtyCtrl.text) ?? 0;
                      final price = double.tryParse(priceCtrl.text) ?? 0;
                      if (qty > 0 && price > 0) {
                        onAdd(StockItem(
                          type: selectedType,
                          size: selectedSize,
                          fabric: selectedFabric,
                          color: selectedColor,
                          quantity: qty,
                          price: price,
                        ));
                        Navigator.pop(ctx);
                      }
                    },
                    style: AppDecorations.primaryButton,
                    child: Text('Add to Stock',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  final StockItem item;
  const _StockCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.glassCard,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('👟', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.type} — Size ${item.size}',
                    style: GoogleFonts.montserrat(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _tag(item.fabric),
                    const SizedBox(width: 6),
                    _tag(item.color),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item.quantity} pairs',
                  style: GoogleFonts.montserrat(
                      color: AppTheme.accentColor, fontWeight: FontWeight.w700, fontSize: 13)),
              Text('₹${item.price.toStringAsFixed(0)}/pair',
                  style: GoogleFonts.montserrat(
                      color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: GoogleFonts.montserrat(
              color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Raw Material Tab ────────────────────────────────────────────────────────

class _RawMaterialTab extends StatelessWidget {
  final List<RawMaterialOrder> orders;
  final void Function(RawMaterialOrder) onAdd;
  const _RawMaterialTab({required this.orders, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          _artisanAppBar(context, 'Raw Materials', '🌿'),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Material Orders',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    ElevatedButton.icon(
                      onPressed: () => _showOrderSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.bgDark,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text('Order',
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...orders.map((o) => _RawMaterialCard(order: o)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderSheet(BuildContext context) {
    final materialCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final sellerCtrl = TextEditingController();

    final units = ['sq ft', 'kg', 'meters', 'rolls', 'pieces', 'liters'];
    String selectedUnit = units[0];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24,
              MediaQuery.of(ctx).viewInsets.bottom + 40),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(),
                const SizedBox(height: 16),
                Text('Order Raw Material',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Request materials from sellers',
                    style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 24),

                _textField(materialCtrl, 'Material (e.g. Leather, Thread)', Icons.grass_outlined, TextInputType.text),
                const SizedBox(height: 14),
                _textField(typeCtrl, 'Type / Grade (e.g. Full Grain)', Icons.category_outlined, TextInputType.text),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _textField(qtyCtrl, 'Quantity', Icons.numbers, TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _dropdownField('Unit', units, selectedUnit,
                        (v) => setSheet(() => selectedUnit = v!))),
                  ],
                ),
                const SizedBox(height: 14),
                _textField(priceCtrl, 'Price per unit (₹)', Icons.currency_rupee, TextInputType.number),
                const SizedBox(height: 14),
                _textField(sellerCtrl, 'Seller name', Icons.store_outlined, TextInputType.text),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final qty = double.tryParse(qtyCtrl.text) ?? 0;
                      final price = double.tryParse(priceCtrl.text) ?? 0;
                      if (materialCtrl.text.isNotEmpty && qty > 0 && price > 0) {
                        onAdd(RawMaterialOrder(
                          material: materialCtrl.text,
                          type: typeCtrl.text,
                          quantity: qty,
                          unit: selectedUnit,
                          pricePerUnit: price,
                          sellerName: sellerCtrl.text,
                        ));
                        Navigator.pop(ctx);
                      }
                    },
                    style: AppDecorations.primaryButton,
                    child: Text('Place Order',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RawMaterialCard extends StatelessWidget {
  final RawMaterialOrder order;
  const _RawMaterialCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case 'Delivered': return AppTheme.successColor;
      case 'In Transit': return AppTheme.primaryColor;
      default: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${order.material} — ${order.type}',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _statusColor.withOpacity(0.4)),
                ),
                child: Text(order.status,
                    style: GoogleFonts.montserrat(
                        color: _statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _infoChip(Icons.store_outlined, order.sellerName),
              const SizedBox(width: 12),
              _infoChip(Icons.scale_outlined,
                  '${order.quantity} ${order.unit}'),
              const SizedBox(width: 12),
              _infoChip(Icons.currency_rupee,
                  '₹${order.totalPrice.toStringAsFixed(0)} total'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.montserrat(
                color: AppTheme.textMuted, fontSize: 11)),
      ],
    );
  }
}

// ─── Delivery Tab ────────────────────────────────────────────────────────────

class _DeliveryTab extends StatelessWidget {
  final List<DeliveryRequest> deliveries;
  final void Function(DeliveryRequest) onAdd;
  const _DeliveryTab({required this.deliveries, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final customerDeliveries = deliveries.where((d) => d.type == 'customer').toList();
    final rawDeliveries = deliveries.where((d) => d.type == 'raw_material').toList();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          _artisanAppBar(context, 'Delivery Partners', '🚚'),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Info banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor.withOpacity(0.15), AppTheme.primaryColor.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Text('🚚', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Delivery Partners Available',
                                style: GoogleFonts.montserrat(
                                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                            Text('For both artisan → customer & raw material → artisan',
                                style: GoogleFonts.montserrat(
                                    color: AppTheme.textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Deliveries',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    ElevatedButton.icon(
                      onPressed: () => _showAddDeliverySheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.bgDark,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text('Request',
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (customerDeliveries.isNotEmpty) ...[
                  _sectionLabel('📦 Artisan → Customer'),
                  const SizedBox(height: 10),
                  ...customerDeliveries.map((d) => _DeliveryCard(delivery: d)),
                  const SizedBox(height: 20),
                ],

                if (rawDeliveries.isNotEmpty) ...[
                  _sectionLabel('🌿 Raw Material → Artisan'),
                  const SizedBox(height: 10),
                  ...rawDeliveries.map((d) => _DeliveryCard(delivery: d)),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: GoogleFonts.montserrat(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5));
  }

  void _showAddDeliverySheet(BuildContext context) {
    final fromCtrl = TextEditingController();
    final toCtrl = TextEditingController();
    final partnerCtrl = TextEditingController();
    String selectedType = 'customer';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24,
              MediaQuery.of(ctx).viewInsets.bottom + 40),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(),
                const SizedBox(height: 16),
                Text('Request Delivery',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 24),

                Text('Delivery Type'.toUpperCase(),
                    style: GoogleFonts.montserrat(
                        color: AppTheme.textMuted, fontSize: 10,
                        fontWeight: FontWeight.w800, letterSpacing: 1)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheet(() => selectedType = 'customer'),
                        child: _typeToggle('To Customer', selectedType == 'customer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheet(() => selectedType = 'raw_material'),
                        child: _typeToggle('Raw Material', selectedType == 'raw_material'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _textField(fromCtrl, 'From (address)', Icons.location_on_outlined, TextInputType.text),
                const SizedBox(height: 14),
                _textField(toCtrl, 'To (address)', Icons.flag_outlined, TextInputType.text),
                const SizedBox(height: 14),
                _textField(partnerCtrl, 'Preferred partner (optional)', Icons.local_shipping_outlined, TextInputType.text),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (fromCtrl.text.isNotEmpty && toCtrl.text.isNotEmpty) {
                        onAdd(DeliveryRequest(
                          type: selectedType,
                          from: fromCtrl.text,
                          to: toCtrl.text,
                          partner: partnerCtrl.text,
                        ));
                        Navigator.pop(ctx);
                      }
                    },
                    style: AppDecorations.primaryButton,
                    child: Text('Request Delivery',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeToggle(String label, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor.withOpacity(0.2) : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isActive ? AppTheme.primaryColor : Colors.white.withOpacity(0.08)),
      ),
      child: Center(
        child: Text(label,
            style: GoogleFonts.montserrat(
                color: isActive ? Colors.white : AppTheme.textMuted,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12)),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final DeliveryRequest delivery;
  const _DeliveryCard({required this.delivery});

  Color get _statusColor {
    switch (delivery.status) {
      case 'Delivered': return AppTheme.successColor;
      case 'In Transit': return AppTheme.primaryColor;
      default: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(delivery.type == 'customer' ? '📦 To Customer' : '🌿 Raw Material',
                  style: GoogleFonts.montserrat(
                      color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _statusColor.withOpacity(0.4)),
                ),
                child: Text(delivery.status,
                    style: GoogleFonts.montserrat(
                        color: _statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(delivery.from,
                    style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.flag_outlined, size: 14, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(delivery.to,
                    style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          if (delivery.partner.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Text(delivery.partner,
                    style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Account Tab ─────────────────────────────────────────────────────────────

class _AccountTab extends StatelessWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          _artisanAppBar(context, 'My Account', '👨‍🎨'),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Profile card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppDecorations.glassCard,
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.luxuryGradient,
                        ),
                        child: const Center(
                            child: Text('👨‍🎨', style: TextStyle(fontSize: 30))),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Artisan',
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          Text('Verified Craftsperson',
                              style: GoogleFonts.montserrat(
                                  color: AppTheme.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 12, color: AppTheme.textMuted),
                              const SizedBox(width: 4),
                              Text('Agra, Uttar Pradesh',
                                  style: GoogleFonts.montserrat(
                                      color: AppTheme.textMuted, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats row
                Row(
                  children: [
                    _statCard('Orders', '142', Icons.receipt_long_outlined),
                    const SizedBox(width: 12),
                    _statCard('Rating', '4.8 ⭐', Icons.star_outline),
                    const SizedBox(width: 12),
                    _statCard('Revenue', '₹84K', Icons.trending_up),
                  ],
                ),
                const SizedBox(height: 24),

                // Info section
                Text('Account Information'.toUpperCase(),
                    style: GoogleFonts.montserrat(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2)),
                const SizedBox(height: 12),
                _infoRow(Icons.phone_outlined, 'Phone', '+91 98765 43210'),
                _infoRow(Icons.email_outlined, 'Email', 'artisan@example.com'),
                _infoRow(Icons.store_outlined, 'Workshop', 'Sadar Bazaar, Agra'),
                _infoRow(Icons.badge_outlined, 'Artisan ID', 'ART-2024-0042'),
                const SizedBox(height: 24),

                // Specializations
                Text('Specializations'.toUpperCase(),
                    style: GoogleFonts.montserrat(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Kolhapuri', 'Mojari', 'Jutti', 'Leather Work', 'Hand Stitching']
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3)),
                            ),
                            child: Text(s,
                                style: GoogleFonts.montserrat(
                                    color: AppTheme.primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 32),

                // Logout
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.dangerColor,
                      side: BorderSide(color: AppTheme.dangerColor.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.logout, size: 18),
                    label: Text('Sign Out',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.glassCard,
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.montserrat(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
            Text(label,
                style: GoogleFonts.montserrat(
                    color: AppTheme.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.montserrat(
                      color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
              Text(value,
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

SliverAppBar _artisanAppBar(BuildContext context, String title, String emoji) {
  return SliverAppBar(
    floating: true,
    pinned: true,
    backgroundColor: AppTheme.bgDark.withOpacity(0.95),
    title: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Text(title,
            style: GoogleFonts.playfairDisplay(
                fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
      ],
    ),
  );
}

Widget _sheetHandle() {
  return Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
          color: Colors.white24, borderRadius: BorderRadius.circular(2)),
    ),
  );
}

Widget _dropdownField(String label, List<String> items, String value,
    void Function(String?) onChanged) {
  return DropdownButtonFormField<String>(
    value: value,
    onChanged: onChanged,
    dropdownColor: AppTheme.bgCard,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    decoration: AppDecorations.inputDecoration(label, Icons.arrow_drop_down),
    items: items
        .map((item) => DropdownMenuItem(
              value: item,
              child: Text(item,
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontSize: 13)),
            ))
        .toList(),
  );
}

Widget _textField(TextEditingController ctrl, String label, IconData icon,
    TextInputType keyboardType) {
  return TextField(
    controller: ctrl,
    keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white),
    decoration: AppDecorations.inputDecoration(label, icon),
  );
}
