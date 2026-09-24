import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_event.dart';
import '../../logic/theme/theme_state.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _identifierFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final GlobalKey _themeButtonKey = GlobalKey();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isCapsLockOn = false;

  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  Offset _rippleOrigin = const Offset(1200, 40);

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    _loadSavedCredentials();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _rippleAnimation = CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(AuthBloc.prefRememberMeKey) ?? true;
      final savedIdentifier = prefs.getString(AuthBloc.prefIdentifierKey);
      if (mounted) {
        setState(() {
          _rememberMe = rememberMe;
          if (savedIdentifier != null && savedIdentifier.isNotEmpty) {
            _identifierController.text = savedIdentifier;
          }
        });
      }
    } catch (_) {}
  }

  bool _handleKeyEvent(KeyEvent event) {
    final isCaps = HardwareKeyboard.instance.lockModesEnabled.contains(
      KeyboardLockMode.capsLock,
    );
    if (isCaps != _isCapsLockOn) {
      setState(() => _isCapsLockOn = isCaps);
    }
    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _identifierController.dispose();
    _passwordController.dispose();
    _identifierFocus.dispose();
    _passwordFocus.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _toggleTheme(bool currentIsDark) {
    final renderBox = _themeButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final globalPos = renderBox.localToGlobal(
        Offset(size.width / 2, size.height / 2),
      );
      setState(() {
        _rippleOrigin = globalPos;
      });
    }
    _rippleController.forward(from: 0.0);
    context.read<ThemeBloc>().add(ToggleDarkMode(currentIsDark));
  }

  void _submitLogin() {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please enter both your email/phone and password.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(20),
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      LoginSubmitted(
        identifier: identifier,
        password: password,
        rememberMe: _rememberMe,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 960;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF8FAFC),
          body: Stack(
            children: [
              // Split Screen Content
              Row(
                children: [
                  // Left Hero Panel
                  if (isWide)
                    Expanded(
                      flex: 5,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF0B1324), const Color(0xFF06281E)]
                                : [const Color(0xFF064E3B), const Color(0xFF047857)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border(
                            right: BorderSide(
                              color: isDark ? const Color(0xFF1F2937) : const Color(0xFF065F46),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               // Top Brand
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.eco_rounded, color: Color(0xFF059669), size: 22),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        themeState.brandName.toUpperCase(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Text(
                                        'ADMINISTRATIVE PORTAL',
                                        style: TextStyle(
                                          color: Color(0xFF6EE7B7),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Headline & Overview
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Active Cloud Infrastructure',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Dedicated Operations\n& Administrative Portal\nfor Krishi Bhandar',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                      height: 1.25,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Empowering regional agricultural hubs and farmers with real-time digital management, inventory controls, customer fulfillment, and high-performance cloud operations.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w400,
                                      height: 1.55,
                                      color: const Color(0xFFD1FAE5),
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Trust & Capability Badges (Scalable, not hardcoded feature list)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildTrustRow(Icons.security_rounded, 'Enterprise-grade SSL Encryption & Session Guard'),
                                        const SizedBox(height: 10),
                                        _buildTrustRow(Icons.sync_rounded, 'Real-time Live Sync with Bhandar Cloud Services'),
                                        const SizedBox(height: 10),
                                        _buildTrustRow(Icons.agriculture_rounded, 'Scalable Multi-Module Architecture for Growing Agri Operations'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Bottom Security Tag
                              Row(
                                children: const [
                                  Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFFA7F3D0)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Authorized Administrative Access • SSL Encrypted',
                                    style: TextStyle(
                                      color: Color(0xFFA7F3D0),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Right Form Panel
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Mobile-only brand crest
                              if (!isWide) ...[
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF059669),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      themeState.brandName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                              ],

                              // Eyebrow Tag
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark 
                                        ? const Color(0xFF059669).withValues(alpha: 0.18)
                                        : const Color(0xFF059669).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFF059669).withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.admin_panel_settings_rounded, size: 14, color: Color(0xFF059669)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'ADMIN SECURE ACCESS',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                          color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              Text(
                                'Sign in to Dashboard',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Enter your credentials to access the Krishi Bhandar control center.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Form
                              BlocConsumer<AuthBloc, AuthState>(
                                listener: (context, authState) {
                                  if (authState.errorMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          authState.errorMessage!,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        backgroundColor: const Color(0xFFE11D48),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        margin: const EdgeInsets.all(20),
                                      ),
                                    );
                                  }
                                },
                                builder: (context, authState) {
                                  final isLoading = authState.status == AuthStatus.loading;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Email/Username
                                      Text(
                                        'Email or Mobile Number',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _identifierController,
                                        focusNode: _identifierFocus,
                                        keyboardType: TextInputType.emailAddress,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter your email or phone number',
                                          prefixIcon: Icon(
                                            Icons.mail_outline_rounded,
                                            size: 18,
                                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                          ),
                                          filled: true,
                                          fillColor: isDark ? const Color(0xFF161E2E) : const Color(0xFFF1F5F9),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(color: Color(0xFF059669), width: 1.6),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                        ),
                                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                                      ),

                                      const SizedBox(height: 20),

                                      // Password
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Password',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                            ),
                                          ),
                                          if (_isCapsLockOn)
                                            const Text(
                                              'CAPS LOCK ON',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFFF59E0B),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocus,
                                        obscureText: _obscurePassword,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter your password',
                                          prefixIcon: Icon(
                                            Icons.lock_outline_rounded,
                                            size: 18,
                                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                              size: 18,
                                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                            ),
                                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                          ),
                                          filled: true,
                                          fillColor: isDark ? const Color(0xFF161E2E) : const Color(0xFFF1F5F9),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(color: Color(0xFF059669), width: 1.6),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                        ),
                                        onSubmitted: (_) => _submitLogin(),
                                      ),

                                      const SizedBox(height: 18),

                                      // Remember Me
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              activeColor: const Color(0xFF059669),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                              onChanged: (val) => setState(() => _rememberMe = val ?? false),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => setState(() => _rememberMe = !_rememberMe),
                                            child: Text(
                                              'Remember me on this browser',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 28),

                                      // Submit Button
                                      SizedBox(
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: isLoading ? null : _submitLogin,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF059669),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.2,
                                                  ),
                                                )
                                              : Text(
                                                  'Sign In to Dashboard',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Wave Ripple Transition Overlay
              AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (context, child) {
                  if (_rippleAnimation.value == 0.0 || _rippleAnimation.value == 1.0) {
                    return const SizedBox.shrink();
                  }
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        size: size,
                        painter: _ThemeRipplePainter(
                          progress: _rippleAnimation.value,
                          origin: _rippleOrigin,
                          targetColor: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF8FAFC),
                          waveColor: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Fixed Top-Right Theme Toggle with Key for Ripple Anchor
              Positioned(
                top: 20,
                right: 24,
                child: AnimatedContainer(
                  key: _themeButtonKey,
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
                    onPressed: () => _toggleTheme(isDark),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) => RotationTransition(
                        turns: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        key: ValueKey<bool>(isDark),
                        size: 18,
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrustRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6EE7B7)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFE6FFFA),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeRipplePainter extends CustomPainter {
  final double progress;
  final Offset origin;
  final Color targetColor;
  final Color waveColor;

  _ThemeRipplePainter({
    required this.progress,
    required this.origin,
    required this.targetColor,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final double maxRadius = math.sqrt(
      math.pow(math.max(origin.dx, size.width - origin.dx), 2) +
      math.pow(math.max(origin.dy, size.height - origin.dy), 2),
    );

    final currentRadius = maxRadius * progress;

    // Expanding solid wave wash
    final fillPaint = Paint()
      ..color = targetColor.withValues(alpha: (1.0 - progress * 0.7).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(origin, currentRadius, fillPaint);

    // Primary wavefront ring
    final primaryWavePaint = Paint()
      ..color = waveColor.withValues(alpha: ((1.0 - progress) * 0.9).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = (5.0 * (1.0 - progress) + 1.0);
    canvas.drawCircle(origin, currentRadius, primaryWavePaint);

    // Trailing echo wave ring
    if (currentRadius > 40) {
      final echoWavePaint = Paint()
        ..color = waveColor.withValues(alpha: ((1.0 - progress) * 0.4).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(origin, (currentRadius - 30).clamp(0.0, double.infinity), echoWavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThemeRipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.origin != origin;
  }
}
