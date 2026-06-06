import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deep,
      body: Stack(
        children: [
          // Scan line effect
          Positioned.fill(
            child: CustomPaint(
              painter: ScanlinePainter(),
            ),
          ),
          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.radio, size: 80, color: AppColors.amber)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 600.ms)
                    .then()
                    .fadeOut(duration: 400.ms, delay: 1000.ms),
                const SizedBox(height: 16),
                Text('HAM 日志', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.amber))
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms)
                    .then()
                    .fadeOut(duration: 400.ms, delay: 800.ms),
                const SizedBox(height: 8),
                Text('业余无线电通联日志', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .then()
                    .fadeOut(duration: 400.ms, delay: 700.ms),
              ],
            ),
          ),
          // Bottom scan line
          Positioned(
            left: 0, right: 0, bottom: 60,
            child: Container(height: 1.5, color: AppColors.ionBlue.withValues(alpha: 0.6))
                .animate(onPlay: (c) => c.repeat())
                .slideX(begin: -1, end: 1, duration: 1200.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }
}

class ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.amber.withValues(alpha: 0.02);
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
