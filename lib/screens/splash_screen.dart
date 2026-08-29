import 'dart:async';

import 'package:flutter/material.dart';

import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const SplashScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  Timer? _contentTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _logoFade = CurvedAnimation(parent: _logoController, curve: Curves.easeOut);

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _logoController.forward();

    _contentTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _contentController.forward();
      }
    });

    _navigationTimer = Timer(
      const Duration(milliseconds: 2300),
      _openMainScreen,
    );
  }

  void _openMainScreen() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (context, animation, secondaryAnimation) {
          return MainScreen(
            isDarkMode: widget.isDarkMode,
            onThemeToggle: widget.onThemeToggle,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.97, end: 1.0).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _contentTimer?.cancel();
    _navigationTimer?.cancel();
    _logoController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final backgroundColor = Color.lerp(
      theme.scaffoldBackgroundColor,
      colors.surface,
      0.35,
    )!;

    final secondColor = Color.lerp(
      theme.scaffoldBackgroundColor,
      colors.primaryContainer,
      0.28,
    )!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, secondColor],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -70,
                child: _circle(220, colors.primary.withValues(alpha: 0.07)),
              ),
              Positioned(
                bottom: -90,
                left: -80,
                child: _circle(240, colors.secondary.withValues(alpha: 0.06)),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final glow = 0.14 + (_pulseController.value * 0.07);

                            return Container(
                              width: 118,
                              height: 118,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(34),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.primary.withValues(
                                      alpha: glow,
                                    ),
                                    blurRadius: 32,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.restaurant_menu_rounded,
                                    size: 52,
                                    color: colors.onPrimary,
                                  ),
                                  Positioned(
                                    top: 20,
                                    right: 26,
                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 17,
                                      color: colors.onPrimary.withValues(
                                        alpha: 0.72,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Column(
                          children: [
                            Text(
                              'wasfa',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Delicious recipes in one place',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Discover • Cook • Enjoy',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 26,
                child: FadeTransition(
                  opacity: _contentFade,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 27,
                        height: 27,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        'Preparing your recipes...',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
