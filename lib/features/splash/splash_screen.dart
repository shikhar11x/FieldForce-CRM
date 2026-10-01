import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Phase 2 replaces this with a session/token check.
    Future<void>.delayed(AppConstants.splashDuration, () {
      if (mounted) context.go(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 104, onDark: true)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack,
                      duration: 700.ms,
                    ),
                const SizedBox(height: 28),
                Text(
                  AppConstants.appName,
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                )
                    .animate(delay: 350.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
                const SizedBox(height: 8),
                Text(
                  AppConstants.tagline,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 0.6,
                  ),
                )
                    .animate(delay: 550.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
                const SizedBox(height: 56),
                SizedBox(
                  width: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      color: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}