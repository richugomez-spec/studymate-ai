import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Allow splash animation to run
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    // Always navigate to Home so both visitors/guests and logged in users land directly on the platform
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D12),
              Color(0xFF1A1035),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricViolet.withOpacity(0.4),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              )
              .animate()
              .scale(
                duration: 600.ms,
                curve: Curves.elasticOut,
                begin: const Offset(0.3, 0.3),
              )
              .fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // App name
              const Text(
                'StudyMate AI',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              )
              .animate(delay: 300.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

              const SizedBox(height: 8),

              // Tagline
              Text(
                'Learn smarter, not harder.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 0.2,
                ),
              )
              .animate(delay: 500.ms)
              .fadeIn(duration: 500.ms),

              const SizedBox(height: 64),

              // Loading indicator
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.electricViolet,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              )
              .animate(delay: 800.ms)
              .fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
