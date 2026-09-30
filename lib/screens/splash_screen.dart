import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6)),
    );
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) context.go('/language');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 110, height: 110,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: const Icon(Icons.school, size: 56, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 24),
                          const Text('ScholarSetu', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          Text('One App. Every Tribal Scholarship.', style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9))),
                          const SizedBox(height: 24),
                          Container(width: 60, height: 2, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(height: 20),
                          Text('Ministry of Tribal Affairs', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.75))),
                          const SizedBox(height: 4),
                          Text('Smart India Hackathon 2026', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.75))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    Text('Powered by Digital India', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('DPDP Act 2023 Compliant', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
