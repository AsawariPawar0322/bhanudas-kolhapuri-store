import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:js' as js;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'login_screen.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_banner.dart';
import '../widgets/demand_prediction_card.dart';
import '../widgets/weekly_forecast_card.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/offline_queue_card.dart';
import '../widgets/ai_insights_section.dart';
import '../widgets/orders_section.dart';
import '../widgets/impact_section.dart';
import '../widgets/animated_orb.dart';
import '../widgets/product_gallery_section.dart';
import '../widgets/activity_feed_section.dart';
import '../widgets/animated_counter.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/buyer_hero_section.dart';
import '../widgets/impact_tracker_meter.dart';
import '../widgets/meet_the_maker_section.dart';
import '../widgets/voice_ai_orb.dart';
import '../widgets/buyer_parallax_story_card.dart';
import '../widgets/outfit_matcher_card.dart';
import '../widgets/hover_lift_wrapper.dart';
import '../widgets/footwear_customizer_card.dart';
import '../widgets/foot_sizer_card.dart';
import '../widgets/negotiation_chat_card.dart';
import '../widgets/artisan_stories_section.dart';
import '../widgets/coop_tracker_card.dart';
import '../widgets/break_in_coach_card.dart';
import '../widgets/traceability_ledger_card.dart';
import '../models/order.dart';

class HomeScreen extends StatefulWidget {
  final bool isArtisan;
  const HomeScreen({super.key, this.isArtisan = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      floatingActionButton: (widget.isArtisan && _currentIndex == 0)
          ? VoiceAiOrbButton(onPressed: () => _showVoiceModal(context)) 
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final Widget mainContentStack = Stack(
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.bgDark,
                      Color(0xFFF1F5F9), // Slate 100
                      Color(0xFFE2E8F0), // Slate 200
                    ],
                  ),
                ),
              ),
              
              // Decorative orbs
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 200,
                right: -100,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.secondaryColor.withOpacity(0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              FadeTransition(
                opacity: _fadeAnimation,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      floating: true,
                      backgroundColor: AppTheme.bgDark.withOpacity(0.9),
                      automaticallyImplyLeading: false,
                      title: Row(
                        children: [
                          const Text('👞 ', style: TextStyle(fontSize: 28)),
                          Text(
                            'Sanand ',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => 
                                AppTheme.primaryGradient.createShader(bounds),
                            child: Text(
                              'Footwear',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        // User Account Icon
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppTheme.bgCard,
                            child: Text(widget.isArtisan ? '👨‍🎨' : '👤', style: const TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),

                     // Connection Banner (shows when offline)
                    if (!provider.isOnline)
                      const SliverToBoxAdapter(
                        child: ConnectionBanner(),
                      ),

                    // Content depending on Role
                    if (widget.isArtisan)
                      if (_currentIndex == 0)
                        ..._buildArtisanSlivers(context)
                      else if (_currentIndex == 1)
                        ..._buildArtisanMaterialsSlivers(context)
                      else
                        ..._buildArtisanAccountSlivers(context)
                    else
                      if (_currentIndex == 0)
                        ..._buildBuyerSlivers(context)
                      else if (_currentIndex == 1)
                        ..._buildBuyerStoreSlivers(context)
                      else
                        ..._buildBuyerAccountSlivers(context),
                  ],
                ),
              ),

              // Floating Bottom Glass Dock on narrow screens
              if (!isLargeScreen) _buildFloatingBottomDock(context),
            ],
          );

          if (isLargeScreen) {
            return Row(
              children: [
                _buildSideNavWindow(context),
                Expanded(child: mainContentStack),
              ],
            );
          } else {
            return mainContentStack;
          }
        },
      ),
    );
  }

  void _scrollToActiveTracker() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent * 0.7,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOutCubic,
    );
  }

  void _showWalletModal(BuildContext context) {
    double walletBalance = 5400.0;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
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
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Header
                Row(
                  children: const [
                    Text('💳', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 12),
                    Text(
                      'Sourcing Wallet & Refunds',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage payment tokens, co-op deposits, and instant refund ledgers.',
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
                ),
                const SizedBox(height: 28),

                // Card Graphic
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF06B6D4).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'ARTISANPAY SECURE',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          Icon(Icons.nfc, color: Colors.white, size: 24),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Total Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${walletBalance.toInt()}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            '••••  ••••  ••••  5890',
                            style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Eleanor Vance',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Add/Withdraw actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.06),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        onPressed: () {
                          setModalState(() {
                            walletBalance += 1000;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('₹1,000 added to wallet. 💰'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Funds', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.06),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        onPressed: () {
                          if (walletBalance >= 1000) {
                            setModalState(() {
                              walletBalance -= 1000;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('₹1,000 withdrawn to bank account. 💸'),
                                backgroundColor: AppTheme.accentColor,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Insufficient balance for withdrawal!'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.call_made, size: 16),
                        label: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Transaction history
                const Text(
                  'Transaction Ledger & Refund Status',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    children: [
                      _buildTransactionItem(
                        'Refund: Tan Kolhapuri (Rejected)', 
                        '+₹1,899', 
                        'May 26, 2026', 
                        true, 
                        isRefund: true,
                      ),
                      const Divider(color: Colors.white10, height: 1),
                      _buildTransactionItem(
                        'Brown Kolhapuri purchase', 
                        '-₹2,400', 
                        'May 26, 2026', 
                        false,
                      ),
                      const Divider(color: Colors.white10, height: 1),
                      _buildTransactionItem(
                        'Co-op Wallet Restock', 
                        '+₹5,000', 
                        'May 22, 2026', 
                        true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String amount, String date, bool isCredit, {bool isRefund = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isCredit
              ? Colors.green.withOpacity(0.1)
              : AppTheme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Text(
          isRefund 
              ? '🔄' 
              : isCredit 
                  ? '📥' 
                  : '📤',
          style: const TextStyle(fontSize: 14),
        ),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(date, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            amount,
            style: TextStyle(
              color: isCredit ? Colors.green : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isRefund) ...[
            const SizedBox(height: 2),
            const Text(
              'Refund Direct to Source',
              style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  void _showWishlistModal(BuildContext context) {
    final List<Map<String, String>> wishlistItems = [
      {
        'name': 'Bridal Maroon Kolhapuri',
        'price': '₹2,499',
        'image': 'assets/images/bridal_maroon.png',
        'desc': 'Stunning wedding edition with pure velvet linings & golden embroidery.',
      },
      {
        'name': 'Modern Black Kolhapuri',
        'price': '₹1,999',
        'image': 'assets/images/modern_black.png',
        'desc': 'Elegant dark edition designed for sleek urban aesthetics and comfortable office wear.',
      },
      {
        'name': 'Vibrant Blue Kolhapuri',
        'price': '₹2,199',
        'image': 'assets/images/vibrant_blue.png',
        'desc': 'Electric royal dye accenting premium handcrafted leather sole.',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
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
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: const [
                  Text('💖', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Text(
                    'Curated Sourcing Wishlist',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Eleanor Vance\'s exclusive selection. Instantly request customization or purchase.',
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
              ),
              const SizedBox(height: 24),

              ...wishlistItems.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      // Image Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item['image']!,
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 68,
                            height: 68,
                            color: Colors.white10,
                            child: const Icon(Icons.image, color: Colors.white24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['desc']!,
                              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5), height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['price']!,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.accentColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Action Buy Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close wishlist modal
                          _showBuyerCheckout(context, initialProduct: {
                            'name': item['name']!,
                            'price': item['price']!,
                            'image': item['image']!,
                          });
                        },
                        child: const Text('Buy Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideNavWindow(BuildContext context) {
    final List<Map<String, dynamic>> navItems = widget.isArtisan
        ? [
            {'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'label': 'Dashboard'},
            {'icon': Icons.inventory_2_outlined, 'activeIcon': Icons.inventory_2, 'label': 'Materials'},
            {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Account'},
          ]
        : [
            {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
            {'icon': Icons.storefront_outlined, 'activeIcon': Icons.storefront, 'label': 'Store'},
            {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Account'},
          ];

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white, // Theme Light glass
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sidebar Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Row(
                  children: [
                    const Text('👞 ', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 8),
                    const Text(
                      'Sanand ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                      child: const Text(
                        'Footwear',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Profile Card inside Sidebar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Text(widget.isArtisan ? '👨‍🎨' : '👤', style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isArtisan ? 'Sanand Master' : 'Eleanor Vance',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.isArtisan ? 'Artisan Workspace' : 'Buyer Sourcing',
                              style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Navigation Items
              Expanded(
                child: ListView.builder(
                  itemCount: navItems.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final item = navItems[index];
                    final isSelected = _currentIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          hoverColor: const Color(0xFFF1F5F9),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor.withOpacity(0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.15)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? item['activeIcon'] : item['icon'],
                                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                                  size: 22,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  item['label'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const Spacer(),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.primaryColor,
                                      boxShadow: [
                                        BoxShadow(color: AppTheme.primaryColor, blurRadius: 4),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Quick Toggle Switch inside Sidebar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (context, anim1, anim2) =>
                              HomeScreen(isArtisan: !widget.isArtisan),
                          transitionsBuilder: (context, anim1, anim2, child) =>
                              FadeTransition(opacity: anim1, child: child),
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: Text(
                      widget.isArtisan ? 'Switch to Buyer' : 'Switch to Artisan',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomDock(BuildContext context) {
    final List<Map<String, dynamic>> navItems = widget.isArtisan
        ? [
            {'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'label': 'Dashboard'},
            {'icon': Icons.inventory_2_outlined, 'activeIcon': Icons.inventory_2, 'label': 'Materials'},
            {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Account'},
          ]
        : [
            {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
            {'icon': Icons.storefront_outlined, 'activeIcon': Icons.storefront, 'label': 'Store'},
            {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Account'},
          ];

    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: AppTheme.bgCard.withOpacity(0.9), // Theme clay glass dock
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(navItems.length, (index) {
                    final item = navItems[index];
                    final isSelected = _currentIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor.withOpacity(0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? item['activeIcon'] : item['icon'],
                              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                              size: 20,
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              Text(
                                item['label'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildArtisanSlivers(BuildContext context) {
    return [
      // Surge Prediction Alert
      SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
               const Text('✨', style: TextStyle(fontSize: 24)),
               const SizedBox(width: 12),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text('Surge Predicted!', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
                     Text('Diwali is approaching. Expect a 300% increase in demand for block-prints. Stock up now.', 
                       style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                   ],
                 ),
               ),
            ],
          ),
        ),
      ),
      // Achievements Row
      SliverToBoxAdapter(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: const [
              AchievementBadge(title: 'Zero Waste Week', emoji: '🏆', color: AppTheme.accentColor),
              AchievementBadge(title: 'Speed Demon', emoji: '⭐', color: AppTheme.primaryColor),
              AchievementBadge(title: 'Festival Ready', emoji: '🌟', color: AppTheme.secondaryColor),
              AchievementBadge(title: 'Perfect Sync', emoji: '🔄', color: Color(0xFFD946EF)),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 280),
                      child: const WeeklyForecastCard(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        const DemandPredictionCard(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSmallActionCard(
                                context, 
                                'Add Stock', 
                                '📦', 
                                () => _showAddStockModal(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Consumer<AppProvider>(
                                builder: (context, provider, child) => _buildSmallStatusCard(
                                  context, 
                                  'In Stock', 
                                  provider.currentStock,
                                  'pairs',
                                  '📦',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (!Provider.of<AppProvider>(context).isOnline) ...[
                const OfflineQueueCard(),
                const SizedBox(height: 24),
              ],
              const OrdersSection(),
              const SizedBox(height: 24),
              const AIInsightsSection(),
              const ActivityFeedSection(),
              const ImpactSection(),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildArtisanMaterialsSlivers(BuildContext context) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Raw Materials & Restock', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              _buildMaterialCard('Premium Leather', '50 sq ft', 'Low Stock', Colors.orange),
              _buildMaterialCard('Dyes & Colors', '15 Liters', 'Sufficient', Colors.green),
              _buildMaterialCard('Thread & Needles', '200 Spools', 'Sufficient', Colors.green),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showOrderMaterialModal(context),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Order Materials from Supplier'),
              )
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildMaterialCard(String name, String qty, String status, Color statusColor) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(name, style: const TextStyle(color: Colors.white)),
        subtitle: Text('Quantity: $qty', style: const TextStyle(color: Colors.white70)),
        trailing: Chip(label: Text(status), backgroundColor: statusColor.withOpacity(0.2), side: BorderSide.none,),
      ),
    );
  }

  List<Widget> _buildArtisanAccountSlivers(BuildContext context) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const CircleAvatar(radius: 50, child: Text('👨‍🎨', style: TextStyle(fontSize: 40))),
              const SizedBox(height: 16),
              Text('Sanand Artisan', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 32),
              ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: (){}),
              ListTile(leading: const Icon(Icons.payment), title: const Text('Payments & Earnings'), onTap: (){}),
              ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()))),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildBuyerStoreSlivers(BuildContext context) {
    return [
      SliverToBoxAdapter(
        child: OutfitMatcherCard(
          onProductSelected: (product) {
            _showBuyerCheckout(context, initialProduct: product);
          },
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: const FootSizerCard(),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available Collections', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      label: const Text('Filter (Color, Size, Fabric)'),
                      avatar: const Icon(Icons.filter_list, size: 16),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      label: const Text('Sort (Price, Size, Rating)'),
                      avatar: const Icon(Icons.sort, size: 16),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Wholesale Mode'),
                      selected: false,
                      onSelected: (b) {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ProductGallerySection(
            selectedProductName: null,
            onProductTap: (product) {
              _showBuyerCheckout(context, initialProduct: product);
            },
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildBuyerAccountSlivers(BuildContext context) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Avatar & Profile Details
              const CircleAvatar(
                radius: 50, 
                backgroundColor: AppTheme.bgCard,
                child: Text('👤', style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 16),
              Text('Eleanor Vance', style: Theme.of(context).textTheme.headlineMedium),
              Text('Global Sourcing Coordinator', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
              const SizedBox(height: 32),
              
              // Tabs / Quick details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProfileStatCard('Active Tracker', '📦', () => _scrollToActiveTracker()),
                  _buildProfileStatCard('Refunds / Wallet', '💳', () => _showWalletModal(context)),
                  _buildProfileStatCard('Curated Wishlist', '💖', () => _showWishlistModal(context)),
                ],
              ),
              
              const SizedBox(height: 36),
              
              // AI SOURCING NEGOTIATIONS
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: const [
                    Text('💬', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 8),
                    Text(
                      'AI Sourcing Negotiations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const NegotiationChatCard(),
              const SizedBox(height: 36),
              
              // ACTIVE ORDERS TRACKING
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: const [
                    Text('📦', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 8),
                    Text(
                      'Live Order Tracking',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Orders list using Consumer
              Consumer<AppProvider>(
                builder: (context, provider, child) {
                  final activeOrders = provider.orders.isNotEmpty
                      ? provider.orders
                      : _getSampleOrdersInHome();

                  return Column(
                    children: activeOrders.map((order) => _buildBuyerTrackCard(context, order)).toList(),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Account Settings & Logout
              Card(
                color: Colors.white.withOpacity(0.03),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.settings_outlined, color: Colors.white70),
                      title: const Text('Settings', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                      onTap: () {},
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildBuyerTrackCard(BuildContext context, Order order) {
    // Determine progress parameters
    double progressPercent = 0.25; // 25% for pending
    String stageText = 'Awaiting Review';
    Color stageColor = const Color(0xFFEA580C);
    
    if (order.status == 'accepted' || order.status == 'in_production') {
      progressPercent = 0.70; // 70% for accepted
      stageText = 'Stitching & Crafting';
      stageColor = const Color(0xFF06B6D4);
    } else if (order.status == 'completed') {
      progressPercent = 1.0; // 100% for completed
      stageText = 'Dispatched for Delivery';
      stageColor = const Color(0xFF10B981);
    } else if (order.status == 'rejected' || order.status == 'cancelled') {
      progressPercent = 0.0;
      stageText = 'Cancelled';
      stageColor = const Color(0xFFEF4444);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B).withOpacity(0.25), // Sleek deep indigo glass
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order.color} Kolhapuri',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Order ID: #${order.id ?? "N/A"} • Size ${order.size}',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: stageColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: stageColor.withOpacity(0.3)),
                ),
                child: Text(
                  stageText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: stageColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 20),

          // Horizontal Stages Tracker Visuals
          if (order.status != 'rejected' && order.status != 'cancelled') ...[
            _buildTimelineIndicatorRow(order),
            const SizedBox(height: 12),
            
            // Linear Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressPercent,
                minHeight: 6,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(stageColor),
              ),
            ),
          ] else ...[
            // Rejected layout
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.error_outline, color: Color(0xFFF87171), size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This order could not be accepted. We have successfully initiated a full refund of 100% directly to your payment source.',
                      style: TextStyle(color: Color(0xFFFECACA), fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Real-time Countdown text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      order.status == 'pending'
                          ? '⏳'
                          : order.status == 'completed'
                              ? '📦'
                              : order.status == 'rejected' || order.status == 'cancelled'
                                  ? '❌'
                                  : '🔨',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.status == 'pending'
                            ? 'Awaiting scheduling review by the artisan...'
                            : order.status == 'completed'
                                ? 'Crafting complete! Dispatched via co-op delivery partner 🚚.'
                                : order.status == 'rejected' || order.status == 'cancelled'
                                    ? 'Order cancelled. Refund completed.'
                                    : 'Crafting in progress! Estimated completion in ${order.completionDays} Days (Delivery assigned 🚚).',
                        style: TextStyle(
                          fontSize: 12, 
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${order.amount.toInt()}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicatorRow(Order order) {
    final bool isApproved = order.status == 'accepted' || order.status == 'in_production' || order.status == 'completed';
    final bool isCompleted = order.status == 'completed';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStageIndicatorNode('Secured', true),
        _buildStageIndicatorNode('Approved', isApproved),
        _buildStageIndicatorNode('Stitching', isApproved),
        _buildStageIndicatorNode('Dispatched', isCompleted),
      ],
    );
  }

  Widget _buildStageIndicatorNode(String title, bool active) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFF06B6D4) : Colors.white12,
            border: Border.all(
              color: active ? Colors.white : Colors.white10,
              width: active ? 1.5 : 1.0,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF06B6D4).withOpacity(0.4),
                      blurRadius: 6,
                    )
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 9, 
            fontWeight: FontWeight.bold, 
            color: active ? Colors.white70 : Colors.white24,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStatCard(String title, String emoji, VoidCallback onTap) {
    return _HoverScaleWrapper(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white60),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Order> _getSampleOrdersInHome() {
    return [
      Order(id: '1248', customerName: 'Eleanor Vance', product: 'Kolhapuri Chappal', color: 'Brown', size: 7, quantity: 2, amount: 1800, status: 'pending', source: 'online', synced: true),
      Order(id: '1246', customerName: 'Eleanor Vance', product: 'Kolhapuri Chappal', color: 'Tan', size: 7, quantity: 1, amount: 1200, status: 'completed', source: 'online', synced: true),
    ];
  }

  List<Widget> _buildBuyerSlivers(BuildContext context) {
    return [
      const SliverToBoxAdapter(child: BuyerHeroSection()),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ArtisanStoriesSection(),
        ),
      ),
      const SliverToBoxAdapter(child: MeetTheMakerSection()),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
      const SliverToBoxAdapter(child: BuyerParallaxStoryCard()),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: const CoopTrackerCard(),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: const FootwearCustomizerCard(),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: const BreakInCoachCard(),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: const TraceabilityLedgerCard(),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ProductGallerySection(
            selectedProductName: null,
            onProductTap: (product) {
              _showBuyerCheckout(context, initialProduct: product);
            },
          ),
        ),
      ),
      const SliverToBoxAdapter(child: ImpactTrackerMeter()),
      SliverToBoxAdapter(child: _buildFooter(context)),
    ];
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Moonshot Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🚀 Moonshot Project',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  'AI That Understands',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: Text(
                    'Traditional Craft',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Subtitle
                Text(
                  'Offline-first intelligence for artisans.\nNo internet required.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          
          // AI Orb
          const SizedBox(
            width: 120,
            height: 120,
            child: AnimatedOrb(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🧵 ', style: TextStyle(fontSize: 24)),
              Text(
                'Artisan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  'AI',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Offline-First • Human-First • Craft-First',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            '🚀 Google Anti-Gravity Moonshot',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.primaryLight,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallActionCard(BuildContext context, String title, String emoji, VoidCallback onTap) {
    return HoverLiftWrapper(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 132,
          width: double.infinity,
          decoration: AppDecorations.glassCard.copyWith(
            color: AppTheme.primaryColor.withOpacity(0.1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSmallStatusCard(BuildContext context, String title, num value, String suffix, String emoji) {
    return HoverLiftWrapper(
      child: Container(
        height: 132,
        width: double.infinity,
        decoration: AppDecorations.glassCard,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedCounter(
              value: value,
              suffix: ' $suffix',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBuyerCheckout(BuildContext context, {Map<String, String>? initialProduct}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController styleController = TextEditingController(text: initialProduct?['name'] ?? '');
    final TextEditingController sizeController = TextEditingController(text: '6');
    String initialPrice = '';
    if (initialProduct != null) {
      initialPrice = int.parse(initialProduct['price']!.replaceAll(RegExp(r'[^0-9]'), '')).toString();
    }
    final TextEditingController priceController = TextEditingController(text: initialPrice);
    final TextEditingController quantityController = TextEditingController(text: '1');
    String? selectedProduct = initialProduct?['name'];
    bool needDeliveryPartner = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '🛍️ Secure Checkout',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your purchase directly supports the artisan.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                
                if (initialProduct == null) ...[
                  // Integrated Inventory Showcase for selection
                  const Text(
                    'Select Design',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ProductGallerySection(
                    selectedProductName: selectedProduct,
                    onProductTap: (product) {
                      setModalState(() {
                        selectedProduct = product['name'];
                        styleController.text = product['name'] ?? '';
                        final basePrice = int.parse(product['price']!.replaceAll(RegExp(r'[^0-9]'), ''));
                        priceController.text = basePrice.toString(); 
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                _buildTextField('Shipping Name', 'Enter your name', nameController),
                const SizedBox(height: 16),
                
                // Style and Size Section
                _buildTextField('Color / Style', 'e.g. Bridal Maroon', styleController),
                const SizedBox(height: 16),
                
                // Custom Sizing Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Size (UK / India)',
                          style: TextStyle(
                            fontSize: 12, 
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => SizeGuideDialog(
                                initialSize: sizeController.text.isNotEmpty ? sizeController.text : '6',
                                onSizeSelected: (newSize) {
                                  setModalState(() {
                                    sizeController.text = newSize;
                                  });
                                },
                              ),
                            );
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.rule, color: AppTheme.primaryLight, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Size Guide & Calibration 📏',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryLight,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['4', '5', '6', '7', '8', '9'].map((size) {
                        final bool isSelected = sizeController.text == size;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  sizeController.text = size;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppTheme.primaryColor 
                                      : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected 
                                        ? Colors.white.withOpacity(0.3) 
                                        : Colors.white.withOpacity(0.08),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  size,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quantity Selector & Unit Price
                Row(
                  children: [
                    // Quantity
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quantity', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          const SizedBox(height: 8),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: () {
                                    int current = int.tryParse(quantityController.text) ?? 1;
                                    if (current > 1) {
                                      setModalState(() {
                                        quantityController.text = (current - 1).toString();
                                      });
                                    }
                                  }, 
                                ),
                                SizedBox(
                                  width: 40,
                                  child: TextField(
                                    controller: quantityController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    decoration: const InputDecoration(border: InputBorder.none),
                                    onChanged: (val) => setModalState(() {}),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: () {
                                    int current = int.tryParse(quantityController.text) ?? 1;
                                    setModalState(() {
                                      quantityController.text = (current + 1).toString();
                                    });
                                  }, 
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Unit Price Display
                    Expanded(
                       child: _buildTextField('Unit Price (₹)', 'Price', priceController, showLabel: true),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),

                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.05),
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text('Need Delivery Partner?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                       Switch(
                         value: needDeliveryPartner,
                         activeColor: AppTheme.primaryLight,
                         onChanged: (val) {
                           setModalState(() => needDeliveryPartner = val);
                         },
                       ),
                     ],
                   ),
                 ),

                const SizedBox(height: 24),

                // Order Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryLight)),
                          if (selectedProduct != null)
                             const Icon(Icons.receipt_long, size: 16, color: AppTheme.primaryLight),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${quantityController.text} × ${styleController.text.isNotEmpty ? styleController.text : "Chapal"}', 
                            style: const TextStyle(fontSize: 13, color: Colors.white70)),
                          Text('₹${(int.parse(priceController.text.isEmpty ? '0' : priceController.text) * (int.parse(quantityController.text.isEmpty ? '1' : quantityController.text))).toString()}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryColor, 
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                        // Submit Order logic
                        if (nameController.text.isEmpty || styleController.text.isEmpty) {
                           // Show simple error feedback if needed
                           return;
                        }
                        
                        final qty = int.tryParse(quantityController.text) ?? 1;
                        final unitPrice = double.tryParse(priceController.text) ?? 0;
                        final totalAmount = unitPrice * qty;

                        final newOrder = Order(
                          id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
                          customerName: nameController.text,
                          product: 'Kolhapuri Chappal', // Could be dynamic
                          color: styleController.text,
                          size: int.tryParse(sizeController.text) ?? 9,
                          quantity: qty,
                          amount: totalAmount,
                          status: 'pending',
                          source: 'online',
                          createdAt: DateTime.now(),
                        );

                        Provider.of<AppProvider>(context, listen: false).createOrder(newOrder);
                        
                        Navigator.pop(context);
                        
                        // Show Success Snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment Successful! Crafting will begin soon. 🌱'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    },
                    child: const Text('Complete Purchase (₹)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

              ],
            ),
          ),
          );
        },
      ),
    );
  }

  void _showAddStockModal(BuildContext context) {
    final TextEditingController countController = TextEditingController(text: '1');
    final TextEditingController typeController = TextEditingController();
    final TextEditingController sizeController = TextEditingController();
    final TextEditingController fabricController = TextEditingController();
    final TextEditingController colorController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 const Text('Increase Inventory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                 const SizedBox(height: 8),
                 const Text('Log newly crafted items into the global record.', style: TextStyle(color: AppTheme.textSecondary)),
                 const SizedBox(height: 24),
                 
                 Row(
                   children: [
                     Expanded(child: _buildTextField('Type of Chappal', 'e.g. Kolhapuri', typeController)),
                     const SizedBox(width: 16),
                     Expanded(child: _buildTextField('Size', 'e.g. 9', sizeController)),
                   ],
                 ),
                 const SizedBox(height: 16),
                 Row(
                   children: [
                     Expanded(child: _buildTextField('Fabric/Material', 'e.g. Leather', fabricController)),
                     const SizedBox(width: 16),
                     Expanded(child: _buildTextField('Color', 'e.g. Brown', colorController)),
                   ],
                 ),
                 
                 const SizedBox(height: 32),
                 const Text('Quantity Added', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                 const SizedBox(height: 8),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Container(
                       decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                       child: IconButton(
                         onPressed: () {
                            int val = int.tryParse(countController.text) ?? 1;
                            if (val > 1) {
                              setModalState(() => countController.text = (val - 1).toString());
                            }
                         },
                         icon: const Icon(Icons.remove, color: Colors.white),
                       ),
                     ),
                     const SizedBox(width: 24),
                     SizedBox(
                       width: 80,
                       child: TextField(
                         controller: countController,
                         keyboardType: TextInputType.number,
                         textAlign: TextAlign.center,
                         style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                         decoration: const InputDecoration(border: InputBorder.none),
                         onChanged: (val) => setModalState(() {}),
                       ),
                     ),
                     const SizedBox(width: 24),
                     Container(
                       decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                       child: IconButton(
                         onPressed: () {
                            int val = int.tryParse(countController.text) ?? 1;
                            setModalState(() => countController.text = (val + 1).toString());
                         },
                         icon: const Icon(Icons.add, color: Colors.white),
                       ),
                     ),
                   ]
                 ),
                 const SizedBox(height: 48),
                 SizedBox(
                   width: double.infinity,
                   height: 56,
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppTheme.primaryColor,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     ),
                     onPressed: () {
                       int count = int.tryParse(countController.text) ?? 1;
                       Provider.of<AppProvider>(context, listen: false).addStock(count);
                       Navigator.pop(context);
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text('✅ Added $count items of type ${typeController.text.isNotEmpty ? typeController.text : "Chappal"} to stock.'), 
                           backgroundColor: AppTheme.accentColor,
                           behavior: SnackBarBehavior.floating,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                         ),
                       );
                     },
                     child: const Text('Confirm Addition', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                   ),
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderMaterialModal(BuildContext context) {
    final TextEditingController typeController = TextEditingController();
    final TextEditingController qtyController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    bool needDeliveryPartner = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const Center(child: Text('Order Raw Material', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
                 const SizedBox(height: 8),
                 const Center(child: Text('Buy from another seller', style: TextStyle(color: AppTheme.textSecondary))),
                 const SizedBox(height: 32),
                 
                 _buildTextField('Which type they want', 'e.g. Premium Leather', typeController),
                 const SizedBox(height: 16),
                 
                 Row(
                   children: [
                     Expanded(child: _buildTextField('How much they want', 'e.g. 50 sq ft', qtyController)),
                     const SizedBox(width: 16),
                     Expanded(child: _buildTextField('Expected Price (₹)', 'e.g. 5000', priceController)),
                   ],
                 ),
                 
                 const SizedBox(height: 24),
                 
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.05),
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text('Need Delivery Partner?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                       Switch(
                         value: needDeliveryPartner,
                         activeColor: AppTheme.primaryLight,
                         onChanged: (val) {
                           setModalState(() => needDeliveryPartner = val);
                         },
                       ),
                     ],
                   ),
                 ),
                 
                 const SizedBox(height: 32),
                 SizedBox(
                   width: double.infinity,
                   height: 56,
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.green,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     ),
                     onPressed: () {
                       Navigator.pop(context);
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: const Text('✅ Material order placed successfully.'), 
                           backgroundColor: Colors.green,
                           behavior: SnackBarBehavior.floating,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                         ),
                       );
                     },
                     child: const Text('Place Order', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                   ),
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool showLabel = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        if (showLabel) const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  void _showVoiceModal(BuildContext context) {
    // Keep existing voice modal logic...
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => _buildVoiceWave(index)),
            ),
            const SizedBox(height: 24),
            Text('Listening...', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceWave(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 20, end: 50),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 6,
          height: value,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}


class SizeGuideDialog extends StatefulWidget {
  final String initialSize;
  final Function(String) onSizeSelected;

  const SizeGuideDialog({
    super.key,
    required this.initialSize,
    required this.onSizeSelected,
  });

  @override
  State<SizeGuideDialog> createState() => _SizeGuideDialogState();
}

class _SizeGuideDialogState extends State<SizeGuideDialog> {
  int _activePage = 0;
  late PageController _pageController;
  double _footLengthCm = 22.0;

  Map<String, String> _calculateSize(double length) {
    if (length < 21.2) {
      return {'uk': '4', 'eu': '37', 'length': '21.0'};
    } else if (length < 21.7) {
      return {'uk': '5', 'eu': '38', 'length': '21.5'};
    } else if (length < 22.5) {
      return {'uk': '6', 'eu': '39', 'length': '22.0'};
    } else if (length < 23.2) {
      return {'uk': '7', 'eu': '40', 'length': '23.0'};
    } else if (length < 23.7) {
      return {'uk': '8', 'eu': '41', 'length': '23.5'};
    } else {
      return {'uk': '9', 'eu': '42', 'length': '24.0'};
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    final Map<String, double> sizeToLength = {
      '4': 21.0,
      '5': 21.5,
      '6': 22.0,
      '7': 23.0,
      '8': 23.5,
      '9': 24.0,
    };
    if (sizeToLength.containsKey(widget.initialSize)) {
      _footLengthCm = sizeToLength[widget.initialSize]!;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _launchURL(String url) {
    if (kIsWeb) {
      js.context.callMethod('open', [url]);
    } else {
      debugPrint('Launch URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeInfo = _calculateSize(_footLengthCm);
    final selectedUk = sizeInfo['uk']!;
    final selectedEu = sizeInfo['eu']!;
    final chartLength = sizeInfo['length']!;

    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      content: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 500,
            height: 600,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('📏', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            'Size Calculator & Guide',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _activePage == 0
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '📊 Size Chart',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _activePage == 0 ? Colors.white : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _activePage == 1
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '🎥 How to Measure',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _activePage == 1 ? Colors.white : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _activePage = page;
                      });
                    },
                    children: [
                      _buildSizeChartSlide(selectedUk, selectedEu, chartLength),
                      _buildMeasureVideoSlide(),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _activePage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _activePage == index
                              ? AppTheme.primaryLight
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      if (_activePage == 0) ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onSizeSelected(selectedUk);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                            ),
                            child: Text(
                              'Select Size UK/India $selectedUk (EU $selectedEu) →',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.15)),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              '← Back to Size Chart Calculator',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSizeChartSlide(String selectedUk, String selectedEu, String chartLength) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📏 Measured Foot Length:',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${_footLengthCm.toStringAsFixed(1)} cm',
                      style: const TextStyle(fontSize: 16, color: AppTheme.primaryLight, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 52,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomPaint(
                        painter: _RulerPainter(),
                      ),
                    ),
                    
                    Positioned(
                      left: 10,
                      child: Opacity(
                        opacity: 0.85,
                        child: Icon(
                          Icons.do_not_step,
                          size: 32 + (_footLengthCm - 20) * 4,
                          color: AppTheme.primaryLight.withOpacity(0.4),
                        ),
                      ),
                    ),
                    
                    Positioned(
                      left: 10 + (_footLengthCm - 20) * (400 - 20) / 5,
                      child: Container(
                        width: 3,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryLight.withOpacity(0.8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.primaryColor,
                    inactiveTrackColor: Colors.white12,
                    thumbColor: AppTheme.primaryLight,
                    overlayColor: AppTheme.primaryLight.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  ),
                  child: Slider(
                    value: _footLengthCm,
                    min: 20.0,
                    max: 25.0,
                    divisions: 50,
                    onChanged: (val) {
                      setState(() {
                        _footLengthCm = val;
                      });
                    },
                  ),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('20 cm', style: TextStyle(fontSize: 11, color: Colors.white30)),
                    Text('Swipe left for instructions ➔', style: TextStyle(fontSize: 11, color: Colors.white30, fontStyle: FontStyle.italic)),
                    Text('25 cm', style: TextStyle(fontSize: 11, color: Colors.white30)),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildResultBadge('UK / India Size', selectedUk, AppTheme.primaryLight),
              const SizedBox(width: 12),
              _buildResultBadge('EU Equivalent', selectedEu, AppTheme.accentColor),
            ],
          ),
          
          const SizedBox(height: 20),
          
          const Text(
            'Kolhapuri Size Chart Standard',
            style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(1.0),
                  2: FlexColumnWidth(1.0),
                },
                children: [
                  _buildTableHeader(),
                  _buildTableRow('21.0 cm', '4', '37', selectedUk == '4'),
                  _buildTableRow('21.5 cm', '5', '38', selectedUk == '5'),
                  _buildTableRow('22.0 cm', '6', '39', selectedUk == '6'),
                  _buildTableRow('23.0 cm', '7', '40', selectedUk == '7'),
                  _buildTableRow('23.5 cm', '8', '41', selectedUk == '8'),
                  _buildTableRow('24.0 cm', '9', '42', selectedUk == '9'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBadge(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text('Length (CM)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text('UK & India', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text('EU Size', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
        ),
      ],
    );
  }

  TableRow _buildTableRow(String length, String uk, String eu, bool isSelected) {
    return TableRow(
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.15) : Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04))),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Text(
            length,
            style: TextStyle(
              fontSize: 12, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Text(
            uk,
            style: TextStyle(
              fontSize: 12, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Text(
            eu,
            style: TextStyle(
              fontSize: 12, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildMeasureVideoSlide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calibration Parameters',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          
          _buildParamCard('1. Length of Foot 📏', 'Measure from the back of your heel to the tip of your longest toe (finger). Make sure to place your foot flat on a piece of paper and mark the boundaries with a vertical pen.', AppTheme.primaryLight),
          const SizedBox(height: 12),
          _buildParamCard('2. Breadth of Foot 📐', 'Measure the width of your foot at its widest part. Kolhapuri chappals are handcrafted from pure leather, which naturally stretches to mold around your foot breadth over time.', AppTheme.accentColor),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '🎥 Native Sizing Calibration Demo',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Icon(Icons.play_circle_outline, color: Colors.white54, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          
          const AnimatedMeasurementDemo(),
          const SizedBox(height: 16),
          
          Center(
            child: TextButton(
              onPressed: () => _launchURL('https://www.youtube.com/watch?v=WWAGL0RQlt4'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.open_in_new, color: Colors.white54, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Watch original YouTube video demo ➔',
                    style: TextStyle(color: Colors.white54, fontSize: 12, decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          const Text(
            '💡 Pro-tip: Foot dimensions naturally expand in the evening. We recommend taking measurements later in the day for the ultimate, custom-fit experience.',
            style: TextStyle(fontSize: 11, color: Colors.white30, fontStyle: FontStyle.italic, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildParamCard(String title, String desc, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: accentColor),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7), height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.0;

    final double step = size.width / 50;
    for (int i = 0; i <= 50; i++) {
      final double x = i * step;
      double height;
      if (i % 10 == 0) {
        height = 20.0;
      } else if (i % 5 == 0) {
        height = 12.0;
      } else {
        height = 6.0;
      }

      canvas.drawLine(Offset(x, 0), Offset(x, height), paint);
      canvas.drawLine(Offset(x, size.height), Offset(x, size.height - height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HoverScaleWrapper extends StatefulWidget {
  final Widget child;
  const _HoverScaleWrapper({required this.child});

  @override
  State<_HoverScaleWrapper> createState() => _HoverScaleWrapperState();
}

class _HoverScaleWrapperState extends State<_HoverScaleWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class AnimatedMeasurementDemo extends StatefulWidget {
  const AnimatedMeasurementDemo({super.key});

  @override
  State<AnimatedMeasurementDemo> createState() => _AnimatedMeasurementDemoState();
}

class _AnimatedMeasurementDemoState extends State<AnimatedMeasurementDemo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _FootMeasurementAnimationPainter(
                    progress: _controller.value,
                  ),
                  child: Container(),
                );
              },
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              IconButton(
                onPressed: _togglePlayback,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: AppTheme.primaryLight,
                  size: 28,
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _controller.value,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(4),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  String stageName = "1. Prep Paper";
                  final val = _controller.value;
                  if (val > 0.15 && val <= 0.5) {
                    stageName = "2. Measure Length 📏";
                  } else if (val > 0.5 && val <= 0.8) {
                    stageName = "3. Measure Breadth 📐";
                  } else if (val > 0.8) {
                    stageName = "4. Match Chart ✅";
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      stageName,
                      style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FootMeasurementAnimationPainter extends CustomPainter {
  final double progress;
  _FootMeasurementAnimationPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    final paintPaper = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;
      
    final paintPaperBorder = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    double paperScale = 1.0;
    if (progress < 0.15) {
      paperScale = progress / 0.15;
    }
    final paperW = w * 0.55 * paperScale;
    final paperH = h * 0.85 * paperScale;
    final paperRect = Rect.fromCenter(center: Offset(cx, cy), width: paperW, height: paperH);
    canvas.drawRRect(RRect.fromRectAndRadius(paperRect, const Radius.circular(8)), paintPaper);
    canvas.drawRRect(RRect.fromRectAndRadius(paperRect, const Radius.circular(8)), paintPaperBorder);

    if (progress < 0.15) return;

    double footOpacity = 1.0;
    if (progress >= 0.15 && progress < 0.3) {
      footOpacity = (progress - 0.15) / 0.15;
    }

    final paintActiveFoot = Paint()
      ..color = AppTheme.primaryLight.withOpacity(0.25 * footOpacity)
      ..style = PaintingStyle.fill;

    final paintActiveFootOutline = Paint()
      ..color = AppTheme.primaryLight.withOpacity(0.6 * footOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final soleW = paperW * 0.5;
    final soleH = paperH * 0.7;
    final soleCenterY = cy + 5;

    final footPath = Path();
    footPath.moveTo(cx - soleW * 0.1, soleCenterY - soleH * 0.4);
    footPath.quadraticBezierTo(cx + soleW * 0.4, soleCenterY - soleH * 0.35, cx + soleW * 0.35, soleCenterY - soleH * 0.1);
    footPath.quadraticBezierTo(cx + soleW * 0.25, soleCenterY + soleH * 0.2, cx + soleW * 0.15, soleCenterY + soleH * 0.45);
    footPath.quadraticBezierTo(cx, soleCenterY + soleH * 0.55, cx - soleW * 0.2, soleCenterY + soleH * 0.45);
    footPath.quadraticBezierTo(cx - soleW * 0.05, soleCenterY + soleH * 0.1, cx - soleW * 0.35, soleCenterY - soleH * 0.1);
    footPath.quadraticBezierTo(cx - soleW * 0.4, soleCenterY - soleH * 0.3, cx - soleW * 0.1, soleCenterY - soleH * 0.4);
    footPath.close();

    canvas.drawPath(footPath, paintActiveFoot);
    canvas.drawPath(footPath, paintActiveFootOutline);

    final double toeBaseY = soleCenterY - soleH * 0.43;
    final List<Map<String, double>> toes = [
      {'x': cx - soleW * 0.22, 'y': toeBaseY - 1, 'r': soleW * 0.15},
      {'x': cx - soleW * 0.02, 'y': toeBaseY - 6, 'r': soleW * 0.11},
      {'x': cx + soleW * 0.13, 'y': toeBaseY - 5, 'r': soleW * 0.10},
      {'x': cx + soleW * 0.25, 'y': toeBaseY - 2, 'r': soleW * 0.09},
      {'x': cx + soleW * 0.35, 'y': toeBaseY + 3, 'r': soleW * 0.08},
    ];

    for (var toe in toes) {
      final toePaint = Paint()
        ..color = AppTheme.primaryLight.withOpacity(0.25 * footOpacity)
        ..style = PaintingStyle.fill;
      final toeOutline = Paint()
        ..color = AppTheme.primaryLight.withOpacity(0.6 * footOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawCircle(Offset(toe['x']!, toe['y']!), toe['r']!, toePaint);
      canvas.drawCircle(Offset(toe['x']!, toe['y']!), toe['r']!, toeOutline);
    }

    if (progress < 0.3) return;

    if (progress >= 0.3) {
      final double lenProgress = ((progress - 0.3) / 0.25).clamp(0.0, 1.0);

      final double startY = soleCenterY + soleH * 0.52;
      final double endY = toeBaseY - 14;
      final double midY = startY + (endY - startY) * lenProgress;

      final paintMeasureLine = Paint()
        ..color = AppTheme.primaryColor // Sienna Terracotta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final paintDash = Paint()
        ..color = Colors.white30
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawLine(Offset(cx - soleW * 0.6, startY), Offset(cx + soleW * 0.6, startY), paintDash);
      
      if (lenProgress >= 0.5) {
        canvas.drawLine(Offset(cx - soleW * 0.6, endY), Offset(cx + soleW * 0.6, endY), paintDash);
      }

      final double measureLineX = cx - soleW * 0.55;
      canvas.drawLine(Offset(measureLineX, startY), Offset(measureLineX, midY), paintMeasureLine);

      if (lenProgress >= 0.9) {
        canvas.drawLine(Offset(measureLineX - 4, startY - 4), Offset(measureLineX, startY), paintMeasureLine);
        canvas.drawLine(Offset(measureLineX + 4, startY - 4), Offset(measureLineX, startY), paintMeasureLine);
        canvas.drawLine(Offset(measureLineX - 4, endY + 4), Offset(measureLineX, endY), paintMeasureLine);
        canvas.drawLine(Offset(measureLineX + 4, endY + 4), Offset(measureLineX, endY), paintMeasureLine);
      }

      if (lenProgress < 1.0) {
        final double pencilX = measureLineX + (lenProgress < 0.5 ? 40 * lenProgress : 40 * (1 - lenProgress));
        final double pencilY = midY;
        final paintPencil = Paint()
          ..color = const Color(0xFFFBBC05)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(pencilX, pencilY), 3.0, paintPencil);
      }

      if (lenProgress >= 0.8 && progress < 0.55) {
        _drawText(canvas, Offset(measureLineX - 35, (startY + endY) / 2), "Length\n23.0 cm", AppTheme.primaryColor);
      }
    }

    if (progress >= 0.55) {
      final double breadthProgress = ((progress - 0.55) / 0.25).clamp(0.0, 1.0);

      final double ballY = soleCenterY - soleH * 0.22;
      final double startX = cx - soleW * 0.45;
      final double endX = cx + soleW * 0.45;
      final double midX = startX + (endX - startX) * breadthProgress;

      final paintBreadthLine = Paint()
        ..color = AppTheme.secondaryColor // Jade Teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawLine(Offset(startX, ballY), Offset(midX, ballY), paintBreadthLine);

      if (breadthProgress >= 0.9) {
        canvas.drawLine(Offset(startX + 4, ballY - 4), Offset(startX, ballY), paintBreadthLine);
        canvas.drawLine(Offset(startX + 4, ballY + 4), Offset(startX, ballY), paintBreadthLine);
        canvas.drawLine(Offset(endX - 4, ballY - 4), Offset(endX, ballY), paintBreadthLine);
        canvas.drawLine(Offset(endX - 4, ballY + 4), Offset(endX, ballY), paintBreadthLine);
      }

      if (breadthProgress < 1.0) {
        final paintPencil = Paint()
          ..color = const Color(0xFFFBBC05)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(midX, ballY - 6), 3.0, paintPencil);
      }

      if (breadthProgress >= 0.8 && progress < 0.8) {
        _drawText(canvas, Offset(cx, ballY - 18), "Breadth: 9.2 cm", AppTheme.secondaryColor);
      }
    }

    if (progress >= 0.8) {
      final double calibrationProgress = ((progress - 0.8) / 0.2).clamp(0.0, 1.0);

      final double startY = soleCenterY + soleH * 0.52;
      final double endY = toeBaseY - 14;
      final double measureLineX = cx - soleW * 0.55;
      final double ballY = soleCenterY - soleH * 0.22;
      final double startX = cx - soleW * 0.45;
      final double endX = cx + soleW * 0.45;

      final paintStableLength = Paint()
        ..color = AppTheme.primaryColor.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final paintStableBreadth = Paint()
        ..color = AppTheme.secondaryColor.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawLine(Offset(measureLineX, startY), Offset(measureLineX, endY), paintStableLength);
      canvas.drawLine(Offset(startX, ballY), Offset(endX, ballY), paintStableBreadth);

      final cardW = w * 0.45 * calibrationProgress;
      final cardH = h * 0.55 * calibrationProgress;
      final cardRect = Rect.fromCenter(center: Offset(cx, cy), width: cardW, height: cardH);

      final paintCard = Paint()
        ..color = AppTheme.bgCard.withOpacity(0.95 * calibrationProgress)
        ..style = PaintingStyle.fill;

      final paintCardBorder = Paint()
        ..color = const Color(0xFF10B981).withOpacity(0.6 * calibrationProgress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawRRect(RRect.fromRectAndRadius(cardRect, const Radius.circular(16)), paintCard);
      canvas.drawRRect(RRect.fromRectAndRadius(cardRect, const Radius.circular(16)), paintCardBorder);

      if (calibrationProgress >= 0.7) {
        _drawText(canvas, Offset(cx, cy - 14), "SIZE CALIBRATED", const Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold);
        _drawText(canvas, Offset(cx, cy + 10), "UK/India 7", Colors.white, fontSize: 18, fontWeight: FontWeight.w900);
        _drawText(canvas, Offset(cx, cy + 24), "EU Equivalent: 40", Colors.white60, fontSize: 9);
      }
    }
  }

  void _drawText(Canvas canvas, Offset offset, String text, Color color, {double fontSize = 11, FontWeight fontWeight = FontWeight.normal}) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: 1.2,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
