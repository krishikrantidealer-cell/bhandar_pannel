import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_event.dart';
import '../../logic/theme/theme_state.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';
import '../../core/theme/theme_palettes.dart';

/// Next-Gen Krishi Bhandar Enterprise Login Console.
/// Engineered with High-Precision Kinetic Biometric Optical Telemetry and Monolithic Frosted Obsidian Glassmorphism.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _identifierFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isIdentifierFocused = false;
  bool _isPasswordFocused = false;
  bool _isCapsLockOn = false;

  // Normalized cursor offset [-1.0, 1.0] for smooth 3D gyroscopic parallax
  Offset _mousePos = Offset.zero;
  Offset _targetMousePos = Offset.zero;

  late AnimationController _rotorController;
  late AnimationController _pulseController;
  late AnimationController _shieldController;
  late AnimationController _laserScanController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    // 1. Outer Tachymeter Rotor Rotation (Calm & Elegant)
    _rotorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 34),
    )..repeat();

    // 2. Ambient Volumetric Pulse (Slow, Relaxed Breathing)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6400),
    )..repeat(reverse: true);

    // 3. Cryptographic Vault Shield Deployment (on Password Focus)
    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // 4. Precision Laser Scan Sweep (Relaxed Smooth Sweep)
    _laserScanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat();

    // 5. Kinetic Waveform Harmonic (Serene Fluid Orbit)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7200),
    )..repeat();

    _identifierFocus.addListener(() {
      setState(() => _isIdentifierFocused = _identifierFocus.hasFocus);
    });

    _passwordFocus.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocus.hasFocus;
        if (_isPasswordFocused && _obscurePassword) {
          _shieldController.forward();
        } else {
          _shieldController.reverse();
        }
      });
    });

    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
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
    _rotorController.dispose();
    _pulseController.dispose();
    _shieldController.dispose();
    _laserScanController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.shield_outlined, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                'Please enter both administrator identifier and security key.',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double score = 0.0;
    if (password.length >= 6) score += 0.3;
    if (password.length >= 10) score += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.15;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.15;
    if (RegExp(r'[!@#\$&*~%]').hasMatch(password)) score += 0.15;
    return score.clamp(0.1, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final palette = themeState.currentPalette;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF050811)
              : const Color(0xFFF1F5F9),
          body: MouseRegion(
            onHover: (event) {
              if (size.width > 0 && size.height > 0) {
                setState(() {
                  _targetMousePos = Offset(
                    ((event.position.dx / size.width) - 0.5) * 2.0,
                    ((event.position.dy / size.height) - 0.5) * 2.0,
                  );
                  _mousePos = Offset(
                    _mousePos.dx + (_targetMousePos.dx - _mousePos.dx) * 0.15,
                    _mousePos.dy + (_targetMousePos.dy - _mousePos.dy) * 0.15,
                  );
                });
              }
            },
            child: Stack(
              children: [
                // 1. Precision Cyber-Constellation & Gyroscopic Atmosphere
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _rotorController,
                      _pulseController,
                      _waveController,
                    ]),
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _ExecutiveAtmospherePainter(
                          rotorProgress: _rotorController.value,
                          pulseProgress: _pulseController.value,
                          waveProgress: _waveController.value,
                          mousePos: _mousePos,
                          isDark: isDark,
                          primaryColor: palette.primary,
                          secondaryColor: palette.secondary,
                        ),
                      );
                    },
                  ),
                ),

                // 2. High-Precision Navigation Header
                Positioned(
                  top: 22,
                  left: 32,
                  right: 32,
                  child: _buildHeader(context, isDark, themeState, palette),
                ),

                // 3. Central Monolithic Zero-Trust Command Console
                Positioned.fill(
                  top: 80,
                  bottom: 44,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: _buildIntegratedConsoleCard(
                        context,
                        isDark,
                        themeState,
                        palette,
                      ),
                    ),
                  ),
                ),

                // 4. System Status Bar
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'KRISHI BHANDAR • ADMIN PANEL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Top Navigation Header ---
  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    ThemeState themeState,
    PaletteConfig palette,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand Crest & Tagline
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [palette.primary, palette.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.6),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.primary.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.eco_rounded, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      themeState.brandName.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: isDark
                            ? const Color(0xFFF8FAFC)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: palette.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: palette.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        'ADMIN PANEL',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: palette.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF10B981),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF10B981),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'KRISHI BHANDAR ONLINE SYSTEM',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: palette.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Theme Switcher
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0B1120) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 18,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF334155),
            ),
            tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
            onPressed: () =>
                context.read<ThemeBloc>().add(ToggleDarkMode(isDark)),
          ),
        ),
      ],
    );
  }

  // --- Monolithic Integrated Console Card ---
  Widget _buildIntegratedConsoleCard(
    BuildContext context,
    bool isDark,
    ThemeState themeState,
    PaletteConfig palette,
  ) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0008)
        ..rotateX(-_mousePos.dy * 0.015)
        ..rotateY(_mousePos.dx * 0.015),
      alignment: FractionalOffset.center,
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF080D1A).withValues(alpha: 0.96)
              : Colors.white.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: palette.primary.withValues(alpha: isDark ? 0.28 : 0.10),
              blurRadius: 60,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.65 : 0.08),
              blurRadius: 36,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Sleek Compact Optical Sentinel Crest & Header
              Container(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF101B33), const Color(0xFF080D1A)]
                        : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Security Telemetry Status Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: palette.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: palette.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.eco_rounded,
                                size: 12,
                                color: palette.primary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'KRISHI BHANDAR',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: palette.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.30),
                            ),
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
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF10B981),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'SECURE LOGIN',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Modern Animated Eye Stage
                    SizedBox(
                      width: 132,
                      height: 132,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _rotorController,
                          _pulseController,
                          _shieldController,
                          _laserScanController,
                          _waveController,
                        ]),
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _BiometricSentinelPainter(
                              rotorProgress: _rotorController.value,
                              pulseProgress: _pulseController.value,
                              shieldProgress: _shieldController.value,
                              laserProgress: _laserScanController.value,
                              waveProgress: _waveController.value,
                              mousePos: _mousePos,
                              isIdentifierFocused: _isIdentifierFocused,
                              isPasswordFocused: _isPasswordFocused,
                              typingLength: _isPasswordFocused
                                  ? _passwordController.text.length
                                  : _identifierController.text.length,
                              primaryColor: palette.primary,
                              secondaryColor: palette.secondary,
                              isDark: isDark,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 14),
                    Text(
                      'Admin Sign In',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: isDark
                            ? const Color(0xFFF8FAFC)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please enter your email and password to log in',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. High-Impact Form Center Stage
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, authState) {
                    if (authState.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  authState.errorMessage!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFFDC2626),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(20),
                        ),
                      );
                    }
                  },
                  builder: (context, authState) {
                    final isLoading = authState.status == AuthStatus.loading;
                    final passwordStrength = _calculatePasswordStrength(
                      _passwordController.text,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Admin Identifier Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'EMAIL / USERNAME',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                                color: isDark
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF334155),
                              ),
                            ),
                            Text(
                              'EMAIL OR ID',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: isDark
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF060912)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _isIdentifierFocused
                                  ? palette.primary
                                  : (isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFCBD5E1)),
                              width: _isIdentifierFocused ? 1.6 : 1.0,
                            ),
                            boxShadow: _isIdentifierFocused
                                ? [
                                    BoxShadow(
                                      color: palette.primary.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: TextField(
                            controller: _identifierController,
                            focusNode: _identifierFocus,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'admin@krishibhandar.in',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: isDark
                                    ? const Color(0xFF475569)
                                    : const Color(0xFF94A3B8),
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _isIdentifierFocused
                                      ? palette.primary.withValues(alpha: 0.18)
                                      : (isDark
                                            ? const Color(0xFF111827)
                                            : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  size: 18,
                                  color: _isIdentifierFocused
                                      ? palette.primary
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              suffixIcon: _identifierController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.cancel_outlined,
                                        size: 18,
                                        color: Color(0xFF64748B),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _identifierController.clear();
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 15,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) {
                              _passwordFocus.requestFocus();
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Security Password Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PASSWORD',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                                color: isDark
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF334155),
                              ),
                            ),
                            if (_isCapsLockOn)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.keyboard_capslock_rounded,
                                    size: 14,
                                    color: palette.accent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'CAPS LOCK ON',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: palette.accent,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                'PRIVATE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF060912)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _isPasswordFocused
                                  ? palette.primary
                                  : (isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFCBD5E1)),
                              width: _isPasswordFocused ? 1.6 : 1.0,
                            ),
                            boxShadow: _isPasswordFocused
                                ? [
                                    BoxShadow(
                                      color: palette.primary.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: TextField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: _obscurePassword ? 2.5 : 0.4,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                letterSpacing: 0,
                                color: isDark
                                    ? const Color(0xFF475569)
                                    : const Color(0xFF94A3B8),
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _isPasswordFocused
                                      ? palette.primary.withValues(alpha: 0.18)
                                      : (isDark
                                            ? const Color(0xFF111827)
                                            : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.lock_outline_rounded,
                                  size: 18,
                                  color: _isPasswordFocused
                                      ? palette.primary
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 19,
                                  color: const Color(0xFF64748B),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                    if (_isPasswordFocused) {
                                      if (_obscurePassword) {
                                        _shieldController.forward();
                                      } else {
                                        _shieldController.reverse();
                                      }
                                    }
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 15,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _submitLogin(),
                          ),
                        ),

                        // Multi-Segment Entropy Visualizer
                        if (_passwordController.text.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              for (int s = 1; s <= 4; s++) ...[
                                Expanded(
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: passwordStrength >= (s * 0.25)
                                          ? (passwordStrength > 0.75
                                                ? const Color(0xFF10B981)
                                                : (passwordStrength > 0.5
                                                      ? const Color(0xFF14B8A6)
                                                      : (passwordStrength > 0.25
                                                            ? const Color(
                                                                0xFFF59E0B,
                                                              )
                                                            : const Color(
                                                                0xFFEF4444,
                                                              ))))
                                          : (isDark
                                                ? const Color(0xFF1E293B)
                                                : const Color(0xFFE2E8F0)),
                                      boxShadow: passwordStrength >= (s * 0.25)
                                          ? [
                                              BoxShadow(
                                                color:
                                                    (passwordStrength > 0.75
                                                            ? const Color(
                                                                0xFF10B981,
                                                              )
                                                            : (passwordStrength >
                                                                      0.5
                                                                  ? const Color(
                                                                      0xFF14B8A6,
                                                                    )
                                                                  : (passwordStrength >
                                                                            0.25
                                                                        ? const Color(
                                                                            0xFFF59E0B,
                                                                          )
                                                                        : const Color(
                                                                            0xFFEF4444,
                                                                          ))))
                                                        .withValues(alpha: 0.5),
                                                blurRadius: 6,
                                              ),
                                            ]
                                          : [],
                                    ),
                                  ),
                                ),
                                if (s < 4) const SizedBox(width: 5),
                              ],
                              const SizedBox(width: 10),
                              Text(
                                passwordStrength > 0.75
                                    ? 'VERY STRONG'
                                    : (passwordStrength > 0.5
                                          ? 'STRONG'
                                          : (passwordStrength > 0.25
                                                ? 'MEDIUM'
                                                : 'WEAK')),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: passwordStrength > 0.75
                                      ? const Color(0xFF10B981)
                                      : (passwordStrength > 0.5
                                            ? const Color(0xFF14B8A6)
                                            : (passwordStrength > 0.25
                                                  ? const Color(0xFFF59E0B)
                                                  : const Color(0xFFEF4444))),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Remember Device & Security Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _rememberMe = !_rememberMe),
                                borderRadius: BorderRadius.circular(6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: palette.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        onChanged: (val) {
                                          setState(
                                            () => _rememberMe = val ?? false,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Remember me',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? const Color(0xFFCBD5E1)
                                            : const Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user_outlined,
                                  size: 14,
                                  color: palette.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Safe & Secure',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // High-Impact Primary CTA Button
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [palette.primary, palette.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isLoading
                                ? []
                                : [
                                    BoxShadow(
                                      color: palette.primary.withValues(
                                        alpha: 0.45,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submitLogin,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sign In to Dashboard',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 19,
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Press Enter key to sign in',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFF475569)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clean, Modern & Expressive Animated Eye Painter:
/// - Awake: Responsive gaze-tracking iris with crisp specular gleams and gentle orbiting glow.
/// - Closed: Silky smooth eyelid descent into a sleek curved lash arc with delightful keystroke micro-bounce.
class _BiometricSentinelPainter extends CustomPainter {
  final double rotorProgress;
  final double pulseProgress;
  final double shieldProgress;
  final double laserProgress;
  final double waveProgress;
  final Offset mousePos;
  final bool isIdentifierFocused;
  final bool isPasswordFocused;
  final int typingLength;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  _BiometricSentinelPainter({
    required this.rotorProgress,
    required this.pulseProgress,
    required this.shieldProgress,
    required this.laserProgress,
    required this.waveProgress,
    required this.mousePos,
    required this.isIdentifierFocused,
    required this.isPasswordFocused,
    required this.typingLength,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 6;

    // 1. Soft Ambient Halo Glow
    final haloRadius = outerRadius + 4 + (pulseProgress * 4);
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
          secondaryColor.withValues(alpha: isDark ? 0.08 : 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: haloRadius));
    canvas.drawCircle(center, haloRadius, haloPaint);

    // 2. Clean, Minimalist Orbit Ring with Single Luminous Satellite
    final orbitPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          primaryColor.withValues(alpha: 0.1),
          primaryColor.withValues(alpha: isDark ? 0.6 : 0.4),
          secondaryColor.withValues(alpha: isDark ? 0.6 : 0.4),
          primaryColor.withValues(alpha: 0.1),
        ],
        transform: GradientRotation(rotorProgress * 2 * math.pi),
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(center, outerRadius, orbitPaint);

    // Single Floating Satellite Glow Bead
    final satAngle = rotorProgress * 2 * math.pi;
    final satPos = Offset(
      center.dx + math.cos(satAngle) * outerRadius,
      center.dy + math.sin(satAngle) * outerRadius,
    );
    canvas.drawCircle(
      satPos,
      3.0,
      Paint()..color = primaryColor.withValues(alpha: 0.95),
    );
    canvas.drawCircle(satPos, 1.5, Paint()..color = Colors.white);

    // 3. Eye Sclera Bed (Smooth, Original Proportional Circle)
    final eyeRadius = outerRadius * 0.52;
    final scleraPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
            : [const Color(0xFFFFFFFF), const Color(0xFFE2E8F0)],
        stops: const [0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: eyeRadius));

    // Draw eye base
    canvas.drawCircle(center, eyeRadius, scleraPaint);

    // Subtle Eye Inner Border
    final eyeBorderPaint = Paint()
      ..color = (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))
          .withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, eyeRadius, eyeBorderPaint);

    // 4. Open Eye (Gaze-Tracking Iris & Gleam)
    // Calculate Look Direction
    Offset lookOffset;
    if (isIdentifierFocused) {
      lookOffset = const Offset(
        0.0,
        0.45,
      ); // Looking down attentively at identifier input
    } else if (isPasswordFocused) {
      lookOffset = const Offset(0.0, 0.15);
    } else {
      // Smooth natural gaze with subtle idle drift
      final idleX = math.cos(waveProgress * 2 * math.pi) * 0.05;
      final idleY = math.sin(waveProgress * 2 * math.pi) * 0.05;
      lookOffset = Offset(
        (mousePos.dx + idleX).clamp(-0.5, 0.5),
        (mousePos.dy + idleY).clamp(-0.5, 0.5),
      );
    }

    final pupilMaxShift = eyeRadius * 0.40;
    final pupilCenter = Offset(
      center.dx + lookOffset.dx * pupilMaxShift,
      center.dy +
          lookOffset.dy * pupilMaxShift +
          (shieldProgress * 8.0), // Glides down when closing
    );

    // Clip to Eye Ball
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: eyeRadius)),
    );

    if (shieldProgress < 1.0) {
      final irisRadius = eyeRadius * 0.58;

      // Glowing Concentric Iris (Emerald to Cyan to Deep Forest Green) - No black color
      final irisPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            primaryColor,
            secondaryColor,
            const Color(0xFF064E3B),
          ],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(
          Rect.fromCircle(center: pupilCenter, radius: irisRadius),
        );
      canvas.drawCircle(pupilCenter, irisRadius, irisPaint);

      // Major Specular Catchlight (Gleam)
      final gleamMajorOffset = Offset(
        pupilCenter.dx - irisRadius * 0.28,
        pupilCenter.dy - irisRadius * 0.28,
      );
      canvas.drawCircle(
        gleamMajorOffset,
        irisRadius * 0.24,
        Paint()..color = Colors.white.withValues(alpha: 0.95),
      );

      // Minor Specular Catchlight
      final gleamMinorOffset = Offset(
        pupilCenter.dx + irisRadius * 0.32,
        pupilCenter.dy + irisRadius * 0.26,
      );
      canvas.drawCircle(
        gleamMinorOffset,
        irisRadius * 0.12,
        Paint()..color = Colors.white.withValues(alpha: 0.80),
      );
    }

    // 5. Smooth Eyelid Descent (Closure)
    if (shieldProgress > 0.0) {
      final easedProgress = Curves.easeInOutCubic.transform(shieldProgress);
      final lidY = center.dy - eyeRadius + (easedProgress * eyeRadius * 2.0);

      // Upper Eyelid Cover
      final lidPath = Path()
        ..moveTo(center.dx - eyeRadius - 4, center.dy - eyeRadius - 4)
        ..lineTo(center.dx + eyeRadius + 4, center.dy - eyeRadius - 4)
        ..lineTo(center.dx + eyeRadius + 4, lidY)
        ..quadraticBezierTo(
          center.dx,
          lidY + (1.0 - easedProgress) * 12,
          center.dx - eyeRadius - 4,
          lidY,
        )
        ..close();

      final lidPaint = Paint()
        ..shader = LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: center, radius: eyeRadius));
      canvas.drawPath(lidPath, lidPaint);

      // Eyelid Seam Glow
      final seamPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.6 * easedProgress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final seamPath = Path()
        ..moveTo(center.dx - eyeRadius * 0.8, lidY)
        ..quadraticBezierTo(
          center.dx,
          lidY + (1.0 - easedProgress) * 12,
          center.dx + eyeRadius * 0.8,
          lidY,
        );
      canvas.drawPath(seamPath, seamPaint);
    }

    canvas.restore(); // Restore Sclera Clip

    // 6. Charming Closed Eye Smile Lash Arc & Keystroke Bounce
    if (shieldProgress > 0.30) {
      final closedAlpha = ((shieldProgress - 0.30) / 0.70).clamp(0.0, 1.0);

      // Subtle Keystroke Bounce / Micro-Wink
      final bounceY = typingLength > 0
          ? (math.sin(typingLength * 2.0 + waveProgress * 4 * math.pi) * 2.2)
          : (math.sin(waveProgress * 2 * math.pi) * 0.8);

      final arcCenter = Offset(center.dx, center.dy + 2 + bounceY);
      final arcWidth = eyeRadius * 0.72;

      // Closed Lash Curve ◠ (Smooth, Elegant Smile Arc)
      final lashPath = Path()
        ..moveTo(arcCenter.dx - arcWidth * 0.5, arcCenter.dy + 3)
        ..quadraticBezierTo(
          arcCenter.dx,
          arcCenter.dy - 10,
          arcCenter.dx + arcWidth * 0.5,
          arcCenter.dy + 3,
        );

      final lashPaint = Paint()
        ..shader =
            LinearGradient(
              colors: [
                primaryColor.withValues(alpha: closedAlpha),
                secondaryColor.withValues(alpha: closedAlpha),
              ],
            ).createShader(
              Rect.fromCenter(center: arcCenter, width: arcWidth, height: 14),
            )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(lashPath, lashPaint);

      // 3 Delicate Curved Eyelashes
      final lashTipPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.85 * closedAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      // Left Lash
      canvas.drawLine(
        Offset(arcCenter.dx - arcWidth * 0.28, arcCenter.dy - 6),
        Offset(arcCenter.dx - arcWidth * 0.40, arcCenter.dy - 12),
        lashTipPaint,
      );
      // Center Lash
      canvas.drawLine(
        Offset(arcCenter.dx, arcCenter.dy - 9),
        Offset(arcCenter.dx, arcCenter.dy - 16),
        lashTipPaint,
      );
      // Right Lash
      canvas.drawLine(
        Offset(arcCenter.dx + arcWidth * 0.28, arcCenter.dy - 6),
        Offset(arcCenter.dx + arcWidth * 0.40, arcCenter.dy - 12),
        lashTipPaint,
      );

      // Floating Soft Sleep / Privacy Sparkles ✦
      final sparkleAlpha =
          ((math.sin(waveProgress * 3 * math.pi) + 1.0) * 0.5 * 0.7 + 0.3) *
          closedAlpha;
      final sparklePaint = Paint()
        ..color = secondaryColor.withValues(alpha: sparkleAlpha);

      // Sparkle 1 (Top-Right)
      final sp1 = Offset(
        center.dx + eyeRadius * 0.65,
        center.dy - eyeRadius * 0.55 + bounceY * 0.5,
      );
      canvas.drawCircle(sp1, 2.0, sparklePaint);
      canvas.drawCircle(
        sp1,
        1.0,
        Paint()..color = Colors.white.withValues(alpha: sparkleAlpha),
      );

      // Sparkle 2 (Top-Left small)
      final sp2 = Offset(
        center.dx - eyeRadius * 0.60,
        center.dy - eyeRadius * 0.40 - bounceY * 0.5,
      );
      canvas.drawCircle(sp2, 1.4, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BiometricSentinelPainter oldDelegate) {
    return oldDelegate.rotorProgress != rotorProgress ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.shieldProgress != shieldProgress ||
        oldDelegate.laserProgress != laserProgress ||
        oldDelegate.waveProgress != waveProgress ||
        oldDelegate.mousePos != mousePos ||
        oldDelegate.isIdentifierFocused != isIdentifierFocused ||
        oldDelegate.isPasswordFocused != isPasswordFocused ||
        oldDelegate.typingLength != typingLength ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.isDark != isDark;
  }
}

/// State-of-the-Art Executive Cyber-Agro Atmosphere Background Canvas:
/// - 4-Point Volumetric Harmonic Aurora Nebulae with chromatic dispersion & cursor aura
/// - 3D Perspective Agro-Spatial Terrain Grid with kinetic data photon pulses
/// - Multi-Tier Z-Depth Constellation Matrix with dynamic energy filaments & mouse physics
/// - Vector Architectural Telemetry HUD (geo-coordinates, sonar rings, silo status markers)
/// - Gyroscopic Horizon Orbitals with rotating orbital satellite markers
class _ExecutiveAtmospherePainter extends CustomPainter {
  final double rotorProgress;
  final double pulseProgress;
  final double waveProgress;
  final Offset mousePos;
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;

  _ExecutiveAtmospherePainter({
    required this.rotorProgress,
    required this.pulseProgress,
    required this.waveProgress,
    required this.mousePos,
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final width = size.width;
    final height = size.height;
    final center = Offset(width * 0.5, height * 0.5);

    // =========================================================================
    // 1. MULTI-POINT VOLUMETRIC AURORA NEBULAE (Deep Field Chromatic Luminescence)
    // ===============================    // Point A: Bio-Emerald Core (Top-Left Drifting Fluid)
    final aAngle = waveProgress * 2 * math.pi;
    final aurora1Center = Offset(
      width * 0.22 + math.cos(aAngle) * 40 + mousePos.dx * 6,
      height * 0.28 + math.sin(aAngle * 0.8) * 35 + mousePos.dy * 6,
    );
    final aurora1Radius = width * (0.42 + 0.05 * pulseProgress);
    final aurora1Paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              primaryColor.withValues(alpha: isDark ? 0.20 : 0.07),
              primaryColor.withValues(alpha: isDark ? 0.08 : 0.02),
              Colors.transparent,
            ],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(
            Rect.fromCircle(center: aurora1Center, radius: aurora1Radius),
          );
    canvas.drawCircle(aurora1Center, aurora1Radius, aurora1Paint);

    // Point B: Cyber Cyan / Azure Fluid (Bottom-Right Counter-Drift)
    final bAngle = (waveProgress + 0.5) * 2 * math.pi;
    final aurora2Center = Offset(
      width * 0.78 + math.cos(bAngle * 0.9) * 35 - mousePos.dx * 6,
      height * 0.72 + math.sin(bAngle) * 30 - mousePos.dy * 6,
    );
    final aurora2Radius = width * (0.38 + 0.04 * (1.0 - pulseProgress));
    final aurora2Paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              secondaryColor.withValues(alpha: isDark ? 0.16 : 0.05),
              secondaryColor.withValues(alpha: isDark ? 0.06 : 0.015),
              Colors.transparent,
            ],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(
            Rect.fromCircle(center: aurora2Center, radius: aurora2Radius),
          );
    canvas.drawCircle(aurora2Center, aurora2Radius, aurora2Paint);

    // Point C: Solar Warmth / Electric Indigo Accent (Center-Top Breathing Ray)
    final aurora3Center = Offset(
      width * 0.50 + mousePos.dx * 4,
      height * 0.15 + math.sin(aAngle * 1.2) * 20,
    );
    final aurora3Paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF6366F1).withValues(alpha: isDark ? 0.09 : 0.03),
              Colors.transparent,
            ],
            stops: const [0.0, 1.0],
          ).createShader(
            Rect.fromCircle(center: aurora3Center, radius: width * 0.32),
          );
    canvas.drawCircle(aurora3Center, width * 0.32, aurora3Paint);

    // =========================================================================
    // 2. KINETIC 3D PERSPECTIVE AGRO-SPATIAL TERRAIN GRID & DATA PHOTONS
    // =========================================================================
    final gridLinePaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF0F172A)).withValues(
        alpha: isDark ? 0.035 : 0.02,
      )
      ..strokeWidth = 1.0;

    final horizonY = height * 0.52;
    const int verticalGridLines = 18;

    for (int i = 0; i <= verticalGridLines; i++) {
      final ratio = i / verticalGridLines;
      final startX = width * 0.5 + (ratio - 0.5) * width * 0.35;
      final endX = width * 0.5 + (ratio - 0.5) * width * 1.8;

      final midX = (startX + endX) * 0.5 + (mousePos.dx * 3);
      final midY = (horizonY + height) * 0.5;

      final path = Path()
        ..moveTo(startX, horizonY)
        ..quadraticBezierTo(midX, midY, endX, height);
      canvas.drawPath(path, gridLinePaint);
    }

    const int horizGridLines = 8;
    for (int i = 1; i <= horizGridLines; i++) {
      final yProg = i / horizGridLines;
      final y = horizonY + (height - horizonY) * math.pow(yProg, 1.7);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridLinePaint);
    }

    // Kinetic Data Stream Photon Pulses (Traveling along grid tracks toward horizon)
    final photonPaint = Paint()..style = PaintingStyle.fill;

    for (int p = 0; p < 5; p++) {
      final pProgress = (rotorProgress * 2.2 + (p * 0.22)) % 1.0;
      final lineIdx = (p * 4) % verticalGridLines;
      final ratio = lineIdx / verticalGridLines;

      final startX = width * 0.5 + (ratio - 0.5) * width * 0.35;
      final endX = width * 0.5 + (ratio - 0.5) * width * 1.8;

      final curX = startX + (endX - startX) * pProgress;
      final curY = horizonY + (height - horizonY) * math.pow(pProgress, 1.7);

      final alpha = (math.sin(pProgress * math.pi) * (isDark ? 0.50 : 0.25))
          .clamp(0.0, 1.0);
      photonPaint.color = (p % 2 == 0 ? primaryColor : secondaryColor)
          .withValues(alpha: alpha);

      canvas.drawCircle(Offset(curX, curY), 2.0 + pProgress * 1.2, photonPaint);
    }

    // =========================================================================
    // 3. MULTI-AXIS 3D GYROSCOPIC HORIZON ORBITALS (Behind Center Card)
    // =========================================================================
    final gyroCenter = Offset(
      center.dx + mousePos.dx * 5,
      center.dy + mousePos.dy * 5,
    );

    // Primary Equatorial Horizon Ring
    final gyroAngle1 = rotorProgress * 2 * math.pi;
    final ring1Radius = width * 0.34;
    final ring1Paint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.12 : 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    canvas.save();
    canvas.translate(gyroCenter.dx, gyroCenter.dy);
    canvas.rotate(gyroAngle1 * 0.5);
    canvas.scale(1.0, 0.38 + 0.05 * math.sin(gyroAngle1));
    canvas.drawCircle(Offset.zero, ring1Radius, ring1Paint);

    // Orbital Tachymeter Ticks & Satellite Node
    const int gyroTicks = 24;
    final gTickPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.35 : 0.15)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < gyroTicks; i++) {
      final tAngle = (i * 2 * math.pi / gyroTicks);
      final isMajor = i % 6 == 0;
      final len = isMajor ? 7.0 : 3.5;
      final p1 = Offset(
        math.cos(tAngle) * (ring1Radius - len),
        math.sin(tAngle) * (ring1Radius - len),
      );
      final p2 = Offset(
        math.cos(tAngle) * (ring1Radius + len),
        math.sin(tAngle) * (ring1Radius + len),
      );
      canvas.drawLine(p1, p2, gTickPaint);
    }

    // Floating Orbital Satellite Node on Ring 1
    final satX = math.cos(gyroAngle1 * 2.0) * ring1Radius;
    final satY = math.sin(gyroAngle1 * 2.0) * ring1Radius;
    final satPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.85 : 0.5);
    canvas.drawCircle(Offset(satX, satY), 3.5, satPaint);
    satPaint.color = Colors.white.withValues(alpha: 0.95);
    canvas.drawCircle(Offset(satX, satY), 1.6, satPaint);

    canvas.restore();

    // Counter-Rotating Inner Elliptical Orbital
    final gyroAngle2 = -rotorProgress * 2 * math.pi * 0.75;
    final ring2Radius = width * 0.25;
    final ring2Paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          secondaryColor.withValues(alpha: isDark ? 0.22 : 0.08),
          Colors.transparent,
        ],
        transform: GradientRotation(gyroAngle2),
      ).createShader(Rect.fromCircle(center: gyroCenter, radius: ring2Radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.save();
    canvas.translate(gyroCenter.dx, gyroCenter.dy);
    canvas.rotate(0.52);
    canvas.scale(0.50 + 0.08 * math.cos(gyroAngle2), 1.0);
    canvas.drawCircle(Offset.zero, ring2Radius, ring2Paint);
    canvas.restore();

    // =========================================================================
    // 4. MULTI-TIER CONSTELLATION MESH & PARTICLE DYNAMICS
    // =========================================================================
    // Layer A: Deep Atmospheric Micro-Data Embers (Drifting upwards calmly)
    const int emberCount = 32;
    final emberPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < emberCount; i++) {
      final seed = i * 137.5;
      final eProgress = (waveProgress * 0.8 + (i / emberCount)) % 1.0;
      final eX =
          (width * (0.05 + 0.90 * ((math.sin(seed) + 1) / 2))) +
          mousePos.dx * 3;
      final eY = height - (eProgress * height);
      final eAlpha = (math.sin(eProgress * math.pi) * (isDark ? 0.40 : 0.18))
          .clamp(0.0, 1.0);

      emberPaint.color = (i % 2 == 0 ? primaryColor : secondaryColor)
          .withValues(alpha: eAlpha);
      canvas.drawCircle(Offset(eX, eY), 1.2 + (i % 3) * 0.5, emberPaint);
    }

    // Layer B: Ambient 24-Node Neural Constellation (Calm drifting)
    const int nodeCount = 24;
    final List<Offset> nodes = [];

    for (int i = 0; i < nodeCount; i++) {
      final phase = i * (2 * math.pi / nodeCount);
      final t = (waveProgress + (i / nodeCount)) % 1.0;

      final baseX = width * (0.10 + 0.80 * ((i * 7) % nodeCount / nodeCount));
      final baseY = height * (0.12 + 0.76 * ((i * 11) % nodeCount / nodeCount));

      final driftX = math.cos(t * 2 * math.pi + phase) * 20;
      final driftY = math.sin(t * 2 * math.pi + phase) * 16;

      final nodePos = Offset(baseX + driftX, baseY + driftY);
      nodes.add(nodePos);
    }

    // Connect close constellation nodes with subtle energy filaments
    final filamentPaint = Paint()..strokeWidth = 1.0;
    final maxDistance = width * 0.18;

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final dist = (nodes[i] - nodes[j]).distance;
        if (dist < maxDistance) {
          final alphaFactor = 1.0 - (dist / maxDistance);
          filamentPaint.color = (i % 2 == 0 ? primaryColor : secondaryColor)
              .withValues(alpha: (isDark ? 0.10 : 0.04) * alphaFactor);
          canvas.drawLine(nodes[i], nodes[j], filamentPaint);
        }
      }
    }

    // Glowing Node Mote Hubs
    final motePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < nodes.length; i++) {
      final isSecondary = i % 3 == 0;
      final pColor = isSecondary ? secondaryColor : primaryColor;

      motePaint.color = pColor.withValues(alpha: isDark ? 0.50 : 0.25);
      final radius = 2.4 + (i % 3) * 0.8;
      canvas.drawCircle(nodes[i], radius, motePaint);

      motePaint.color = Colors.white.withValues(alpha: isDark ? 0.80 : 0.50);
      canvas.drawCircle(nodes[i], radius * 0.45, motePaint);
    }

    // =========================================================================
    // 5. VECTOR ARCHITECTURAL TELEMETRY HUD & AGRO-COORDINATES
    // =========================================================================
    final hudBracketPaint = Paint()
      ..color = (isDark ? primaryColor : const Color(0xFF475569)).withValues(
        alpha: isDark ? 0.28 : 0.18,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Corner L-Brackets & Crosshairs
    _drawCornerBracket(
      canvas,
      const Offset(36, 36),
      14,
      hudBracketPaint,
      isTopLeft: true,
    );
    _drawCornerBracket(
      canvas,
      Offset(width - 36, 36),
      14,
      hudBracketPaint,
      isTopRight: true,
    );
    _drawCornerBracket(
      canvas,
      Offset(36, height - 36),
      14,
      hudBracketPaint,
      isBottomLeft: true,
    );
    _drawCornerBracket(
      canvas,
      Offset(width - 36, height - 36),
      14,
      hudBracketPaint,
      isBottomRight: true,
    );

    // Dynamic Telemetry Sonar Rings (Bottom-Left & Top-Right)
    final sonarCenter = Offset(64, height - 64);
    final sonarRadius = 26 + (pulseProgress * 12);
    final sonarPaint = Paint()
      ..color = primaryColor.withValues(
        alpha: (isDark ? 0.20 : 0.08) * (1.0 - pulseProgress),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(sonarCenter, sonarRadius, sonarPaint);
    canvas.drawCircle(
      sonarCenter,
      3.0,
      Paint()..color = primaryColor.withValues(alpha: isDark ? 0.6 : 0.3),
    );
  }

  void _drawCornerBracket(
    Canvas canvas,
    Offset origin,
    double armLength,
    Paint paint, {
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    final path = Path();
    if (isTopLeft) {
      path.moveTo(origin.dx, origin.dy + armLength);
      path.lineTo(origin.dx, origin.dy);
      path.lineTo(origin.dx + armLength, origin.dy);
    } else if (isTopRight) {
      path.moveTo(origin.dx - armLength, origin.dy);
      path.lineTo(origin.dx, origin.dy);
      path.lineTo(origin.dx, origin.dy + armLength);
    } else if (isBottomLeft) {
      path.moveTo(origin.dx, origin.dy - armLength);
      path.lineTo(origin.dx, origin.dy);
      path.lineTo(origin.dx + armLength, origin.dy);
    } else if (isBottomRight) {
      path.moveTo(origin.dx - armLength, origin.dy);
      path.lineTo(origin.dx, origin.dy);
      path.lineTo(origin.dx, origin.dy - armLength);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ExecutiveAtmospherePainter oldDelegate) {
    return oldDelegate.rotorProgress != rotorProgress ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.waveProgress != waveProgress ||
        oldDelegate.mousePos != mousePos ||
        oldDelegate.isDark != isDark ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
