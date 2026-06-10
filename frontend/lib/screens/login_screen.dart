import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:async';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isArtisanMode = true;
  bool isLoginMode = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idOrEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // For 3D Parallax Tilt effect
  double _mouseX = 0;
  double _mouseY = 0;

  // MFA Security parameters
  bool showMfaOverlay = false;
  bool isBiometricScanning = false;
  double biometricScanProgress = 0.0;
  String otpInputCode = '';
  bool isOtpVerifying = false;

  @override
  void dispose() {
    _nameController.dispose();
    _idOrEmailController.dispose();
    _passwordController.dispose();
    _biometricTimer?.cancel();
    super.dispose();
  }

  void _login() {
    if (!showMfaOverlay) {
      setState(() {
        showMfaOverlay = true;
        biometricScanProgress = 0.0;
        isBiometricScanning = false;
        otpInputCode = '';
        isOtpVerifying = false;
      });
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            HomeScreen(isArtisan: isArtisanMode),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  void _showEmailSelectionDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Select Account',
      barrierColor: Colors.black.withOpacity(0.15),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curveValue = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: 0.9 + (curveValue * 0.1),
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              content: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 440,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '✨ Select Account',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Choose a simulated account below to login instantly with pre-configured settings & dynamic roles.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),
                        ..._buildMockEmailList(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMockEmailList(BuildContext context) {
    final List<Map<String, dynamic>> mockEmails = [
      {
        'email': 'artisan.sanand@coop.in',
        'name': 'Sanand (Master Artisan)',
        'role': 'Artisan Workspace',
        'isArtisan': true,
        'avatar': '👨‍🎨',
        'badgeColor': const Color(0xFF8B5CF6),
      },
      {
        'email': 'buyer.global@market.com',
        'name': 'Eleanor Vance (Global Sourcing)',
        'role': 'Buyer Portal',
        'isArtisan': false,
        'avatar': '🛍️',
        'badgeColor': const Color(0xFF10B981),
      },
      {
        'email': 'devi.lal@manager.org',
        'name': 'Devi Lal (Co-op Manager)',
        'role': 'Artisan Workspace',
        'isArtisan': true,
        'avatar': '💼',
        'badgeColor': const Color(0xFF06B6D4),
      },
    ];

    return mockEmails.map((account) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              
              setState(() {
                _idOrEmailController.text = account['email'];
                _passwordController.text = 'password123';
                isArtisanMode = account['isArtisan'];
                isLoginMode = true;
              });

              // Show a beautiful SnackBar or short overlay before logging in
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  content: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (account['badgeColor'] as Color).withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(account['avatar'], style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Logging in as ${account['name']}',
                                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Synchronizing secure credentials...',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(account['badgeColor'] as Color),
                          ),
                        ),
                      ],
                    ),
                  ),
                  duration: const Duration(milliseconds: 1400),
                ),
              );

              Future.delayed(const Duration(milliseconds: 1600), () {
                if (mounted) {
                  _login();
                }
              });
            },
            borderRadius: BorderRadius.circular(20),
            hoverColor: const Color(0xFFF1F5F9),
            splashColor: const Color(0xFFE2E8F0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (account['badgeColor'] as Color).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      account['avatar'],
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account['name'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          account['email'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (account['badgeColor'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (account['badgeColor'] as Color).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      account['role'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: account['badgeColor'] as Color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showGoogleSelectionDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Sign in with Google',
      barrierColor: Colors.black.withOpacity(0.15),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curveValue = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: 0.9 + (curveValue * 0.1),
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              content: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 420,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 52,
                            height: 52,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Image.network(
                              'https://developers.google.com/static/identity/images/g-logo.png',
                              width: 32,
                              height: 32,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: Color(0xFF4285F4), shape: BoxShape.circle),
                                child: const Text('G', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Choose an account',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'to continue to Sanand Footwear',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        ..._buildGoogleMockEmailList(context),
                        const Divider(color: Color(0xFFE2E8F0), height: 24),
                        ListTile(
                          onTap: () => Navigator.pop(context),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_add_alt_1_outlined, color: AppTheme.textSecondary, size: 20),
                          ),
                          title: const Text(
                            'Use another account',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildGoogleMockEmailList(BuildContext context) {
    final List<Map<String, dynamic>> googleAccounts = [
      {
        'email': 'sanand.crafts@gmail.com',
        'name': 'Sanand Master',
        'role': 'Artisan Workspace',
        'isArtisan': true,
        'initial': 'S',
        'color': const Color(0xFFEA4335), // Google Red
      },
      {
        'email': 'vance.eleanor@gmail.com',
        'name': 'Eleanor Vance',
        'role': 'Buyer Portal',
        'isArtisan': false,
        'initial': 'E',
        'color': const Color(0xFF34A853), // Google Green
      },
      {
        'email': 'devi.manager@gmail.com',
        'name': 'Devi Lal',
        'role': 'Artisan Workspace',
        'isArtisan': true,
        'initial': 'D',
        'color': const Color(0xFF4285F4), // Google Blue
      },
    ];

    return googleAccounts.map((account) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              
              setState(() {
                _idOrEmailController.text = account['email'];
                _passwordController.text = 'google_authenticated';
                isArtisanMode = account['isArtisan'];
                isLoginMode = true;
              });

              // Show a beautiful Google-branded Sync snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  content: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (account['color'] as Color).withOpacity(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Image.network(
                            'https://developers.google.com/static/identity/images/g-logo.png',
                            errorBuilder: (context, error, stackTrace) => Container(
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(color: Color(0xFF4285F4), shape: BoxShape.circle),
                              child: const Text('G', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Signing in with Google as ${account['name']}',
                                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Connecting to ${account['email']}...',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(account['color'] as Color),
                          ),
                        ),
                      ],
                    ),
                  ),
                  duration: const Duration(milliseconds: 1400),
                ),
              );

              Future.delayed(const Duration(milliseconds: 1600), () {
                if (mounted) {
                  _login();
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            hoverColor: const Color(0xFFF1F5F9),
            splashColor: const Color(0xFFE2E8F0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: account['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      account['initial'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          account['email'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      account['role'].split(' ')[0],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: MouseRegion(
        onHover: (event) {
          final size = MediaQuery.of(context).size;
          setState(() {
            _mouseX = (event.position.dx / size.width) * 2 - 1;
            _mouseY = (event.position.dy / size.height) * 2 - 1;
          });
        },
        onExit: (_) {
          setState(() {
            _mouseX = 0;
            _mouseY = 0;
          });
        },
        child: Stack(
          children: [
            // Soft Light Grid/Mesh Canvas instead of dark background image
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            
            // Ultra-subtle mesh orbs for premium startup look
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15 + (_mouseY * 40),
              left: MediaQuery.of(context).size.width * 0.15 + (_mouseX * 40),
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppTheme.secondaryColor.withOpacity(0.06), Colors.transparent],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .scaleXY(begin: 0.9, end: 1.1, duration: 6.seconds, curve: Curves.easeInOut),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.1 - (_mouseY * 30),
              right: MediaQuery.of(context).size.width * 0.15 - (_mouseX * 30),
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppTheme.primaryColor.withOpacity(0.06), Colors.transparent],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .scaleXY(begin: 1.1, end: 0.9, duration: 7.seconds, curve: Curves.easeInOut),
            ),

            // Main White Glass Card
            Center(
              child: SingleChildScrollView(
                child: Transform(
                  transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0008) // subtle perspective
                  ..rotateX(-_mouseY * 0.04)
                  ..rotateY(_mouseX * 0.04),
                  alignment: Alignment.center,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9), // Pure White Glass
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.03),
                          blurRadius: 60,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo Section
                            Center(
                              child: Hero(
                                tag: 'app_logo',
                                child: Text(
                                  '✨ Sanand Footwear',
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 36,
                                  ),
                                ),
                              ),
                            ).animate().slideY(begin: -0.3, end: 0, duration: 800.ms, curve: Curves.easeOutCubic)
                             .fadeIn(duration: 800.ms),
                            
                            const SizedBox(height: 16),
                            const Text(
                              'Empowering traditional craftsmanship with offline-first AI predictions, seamless syncing, and modern tools designed for authentic human impact.',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
                            
                            const SizedBox(height: 36),

                            // Role Selector
                            Container(
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9), // Slate 100
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Row(
                                children: [
                                  Expanded(child: _buildSegmentButton('👨‍🎨 Workspace', true)),
                                  Expanded(child: _buildSegmentButton('🛍️ Buyer Portal', false)),
                                ],
                              ),
                            ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

                            const SizedBox(height: 28),

                            // Inputs
                            if (!isLoginMode) ...[
                              _buildModernTextField(
                                hint: 'Full Name',
                                icon: Icons.person_outline,
                                controller: _nameController,
                              ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1, end: 0, curve: Curves.easeOutCubic),
                              const SizedBox(height: 16),
                            ],

                            _buildModernTextField(
                              hint: 'User ID',
                              icon: Icons.badge_outlined,
                              controller: _idOrEmailController,
                            ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1, end: 0, curve: Curves.easeOutCubic),
                            
                            const SizedBox(height: 16),
                            
                            _buildModernTextField(
                              hint: 'Secure Password',
                              icon: Icons.fingerprint,
                              isObscure: true,
                              controller: _passwordController,
                            ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

                            const SizedBox(height: 28),

                            // Login Button
                            GestureDetector(
                              onTap: _login,
                              child: Container(
                                height: 68,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: AppTheme.primaryGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    isLoginMode ? 'Login →' : 'Register →',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 900.ms)
                            .scale(begin: const Offset(0.95, 0.95), delay: 900.ms, curve: Curves.elasticOut, duration: 1200.ms)
                            .shimmer(delay: 2.seconds, duration: 1.seconds, color: Colors.white24),
                            
                            const SizedBox(height: 20),
                            
                            // Toggle Login/Register
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    isLoginMode = !isLoginMode;
                                  });
                                },
                                child: Text(
                                  isLoginMode 
                                      ? "Don't have an account? Register" 
                                      : "Already have an account? Login",
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ).animate().fadeIn(delay: 1000.ms),
                            ),

                            const SizedBox(height: 20),
                            
                            Row(
                              children: const [
                                Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('OR', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                              ],
                            ).animate().fadeIn(delay: 1100.ms),
                            
                            const SizedBox(height: 24),
                            
                            // Continue with Google
                            GestureDetector(
                              onTap: _showGoogleSelectionDialog,
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      'https://developers.google.com/static/identity/images/g-logo.png',
                                      width: 24,
                                      height: 24,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 24,
                                        height: 24,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(color: Color(0xFF4285F4), shape: BoxShape.circle),
                                        child: const Text('G', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: 1150.ms),
                            
                            const SizedBox(height: 16),
                            
                            // Continue with Email
                            GestureDetector(
                              onTap: _showEmailSelectionDialog,
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.email_outlined, color: AppTheme.textPrimary),
                                    SizedBox(width: 12),
                                    Text(
                                      'Continue with Email',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: 1200.ms),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (showMfaOverlay) _buildMfaOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton(String title, bool isArtisan) {
    final bool isSelected = isArtisanMode == isArtisan;
    return GestureDetector(
      onTap: () {
        setState(() {
          isArtisanMode = isArtisan;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isSelected 
              ? Border.all(color: const Color(0xFFE2E8F0), width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required String hint,
    required IconData icon,
    bool isObscure = false,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 16),
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        ),
      ),
    );
  }

  // --- MFA DUAL-FACTOR OVERLAY AND LOGIC ---
  Widget _buildMfaOverlay(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: const Color(0xFF0F172A).withOpacity(0.15),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.03),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Shield Icon
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.security, color: AppTheme.primaryColor, size: 36),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .scaleXY(begin: 0.95, end: 1.05, duration: 2.seconds, curve: Curves.easeInOut)
                     .shimmer(duration: 1.5.seconds, color: Colors.white24),
                    const SizedBox(height: 24),

                    // Header Text
                    const Text(
                      'Multi-Factor Verification',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: 0.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Artisan Workspace requires secure validation before unlocking Sanand Footwear systems.',
                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),

                    // Interactive Biometric Fingerprint Scanner
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'METHOD A: BIOMETRIC SHIELD SCAN',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryColor, letterSpacing: 1.0),
                          ),
                          const SizedBox(height: 20),
                          
                          // Fingerprint Touch Area
                          GestureDetector(
                            onTapDown: (_) => _startBiometricScan(),
                            onTapUp: (_) => _cancelBiometricScan(),
                            onTapCancel: () => _cancelBiometricScan(),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulsing glowing background rings
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: isBiometricScanning
                                          ? AppTheme.primaryColor
                                          : AppTheme.primaryColor.withOpacity(0.2),
                                      width: 2,
                                    ),
                                  ),
                                ).animate(onPlay: (c) => c.repeat())
                                 .scaleXY(begin: 1.0, end: 1.25, duration: 1.5.seconds, curve: Curves.easeOut)
                                 .fadeIn(duration: 500.ms)
                                 .fadeOut(delay: 1.seconds, duration: 500.ms),

                                // Main Scanner button
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isBiometricScanning
                                        ? AppTheme.primaryColor.withOpacity(0.15)
                                        : const Color(0xFFF1F5F9),
                                    border: Border.all(
                                      color: isBiometricScanning
                                          ? AppTheme.primaryColor
                                          : const Color(0xFFE2E8F0),
                                      width: 1.5,
                                    ),
                                    boxShadow: isBiometricScanning
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.primaryColor.withOpacity(0.15),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                            )
                                          ]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.fingerprint,
                                    color: isBiometricScanning
                                        ? AppTheme.primaryColor
                                        : AppTheme.textSecondary,
                                    size: 48,
                                  ),
                                ),

                                // Circular scan line sweep
                                if (isBiometricScanning)
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: 80,
                                        height: 3,
                                        color: AppTheme.primaryColor.withOpacity(0.7),
                                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                                       .slideY(begin: -10, end: 10, duration: 800.ms, curve: Curves.easeInOut),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Scan progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: biometricScanProgress,
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                biometricScanProgress >= 1.0
                                    ? AppTheme.successColor
                                    : AppTheme.primaryColor,
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isBiometricScanning
                                ? 'HOLD TO SCAN: ${(biometricScanProgress * 100).toInt()}%'
                                : 'PRESS AND HOLD FINGERPRINT SENSOR',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isBiometricScanning ? AppTheme.primaryColor : AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Method B: SMS Authentication passcode grid
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'METHOD B: ENCRYPTED SMS OTP',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryColor, letterSpacing: 1.0),
                          ),
                          const SizedBox(height: 16),
                          
                          // Code display slots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              final String char = otpInputCode.length > index 
                                  ? otpInputCode[index] 
                                  : '';
                              final bool hasChar = char.isNotEmpty;
                              
                              return Container(
                                width: 40,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: hasChar 
                                        ? AppTheme.primaryColor.withOpacity(0.6) 
                                        : const Color(0xFFE2E8F0),
                                    width: hasChar ? 1.5 : 1.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  char,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                          
                          // Preset / autofill hint button
                          GestureDetector(
                            onTap: () {
                              _autofillOtpCode();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.sms, color: AppTheme.primaryColor, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'Autofill Secure Code: 582914',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Keypad grid simulation
                          _buildOtpKeypad(context),
                          const SizedBox(height: 16),

                          // Verify Button
                          if (otpInputCode.length == 6)
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: isOtpVerifying ? null : () => _verifyOtp(),
                                child: isOtpVerifying
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                                      )
                                    : const Text(
                                        'Authorize Secure SMS Handshake 🚀',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                              ),
                            ).animate().fadeIn().scale(duration: 300.ms),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Back button to login
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
                      onPressed: () {
                        setState(() {
                          showMfaOverlay = false;
                        });
                      },
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Back to credentials login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _autofillOtpCode() {
    setState(() {
      otpInputCode = '582914';
    });
  }

  Widget _buildOtpKeypad(BuildContext context) {
    final List<String> keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '⌫', '0', '✓'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final String label = keys[index];
        return GestureDetector(
          onTap: () {
            if (label == '⌫') {
              if (otpInputCode.isNotEmpty) {
                setState(() {
                  otpInputCode = otpInputCode.substring(0, otpInputCode.length - 1);
                });
              }
            } else if (label == '✓') {
              if (otpInputCode.length == 6) {
                _verifyOtp();
              }
            } else {
              if (otpInputCode.length < 6) {
                setState(() {
                  otpInputCode += label;
                });
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Timer? _biometricTimer;
  void _startBiometricScan() {
    setState(() {
      isBiometricScanning = true;
    });

    _biometricTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!isBiometricScanning) {
        timer.cancel();
        return;
      }
      setState(() {
        biometricScanProgress = (biometricScanProgress + 0.04).clamp(0.0, 1.0);
      });

      if (biometricScanProgress >= 1.0) {
        timer.cancel();
        _finalizeMfaSuccess('Biometric handshake authorized. Welcome master artisan.');
      }
    });
  }

  void _cancelBiometricScan() {
    _biometricTimer?.cancel();
    if (biometricScanProgress < 1.0) {
      setState(() {
        isBiometricScanning = false;
        biometricScanProgress = 0.0;
      });
    }
  }

  void _verifyOtp() {
    if (otpInputCode != '582914') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Invalid Verification Code. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        otpInputCode = '';
      });
      return;
    }

    setState(() {
      isOtpVerifying = true;
    });

    Timer(const Duration(milliseconds: 1200), () {
      _finalizeMfaSuccess('Secure SMS handshake verified.');
    });
  }

  void _finalizeMfaSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.successColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.successColor.withOpacity(0.1),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Access Granted 🔐',
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    Text(msg, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          showMfaOverlay = false;
        });
        
        // Push navigation
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                HomeScreen(isArtisan: isArtisanMode),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
    });
  }
}

