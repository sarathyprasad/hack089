import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// GovLoadingIndicator — Premium National Cooperative Identity Loading Buffer
/// Features dual-ring concentric orbital rotation (Saffron, Ashoka Green, Deep Navy),
/// a pulsing center shield emblem, and animated civic telemetry status text.
class GovLoadingIndicator extends StatefulWidget {
  final String title;
  final String subtitle;
  final double size;
  final bool isFullScreen;
  final bool isInline;
  final bool? isDark;

  const GovLoadingIndicator({
    super.key,
    this.title = 'Synchronizing Cooperative Federation...',
    this.subtitle = 'Verifying encrypted 93-2-5 escrow ledger & live GIS telemetry',
    this.size = 72,
    this.isFullScreen = false,
    this.isInline = false,
    this.isDark,
  });

  /// Full-screen modal or screen replacement buffer
  const GovLoadingIndicator.fullScreen({
    super.key,
    this.title = 'Synchronizing Cooperative Federation...',
    this.subtitle = 'Verifying encrypted 93-2-5 escrow ledger & live GIS telemetry',
    this.size = 84,
    this.isDark,
  })  : isFullScreen = true,
        isInline = false;

  /// Card / in-page section loading buffer
  const GovLoadingIndicator.card({
    super.key,
    this.title = 'Loading Cooperative Records...',
    this.subtitle = 'Connecting to encrypted State Cooperative node',
    this.size = 64,
    this.isDark,
  })  : isFullScreen = false,
        isInline = false;

  /// Compact inline spinner for buttons or small tiles
  const GovLoadingIndicator.inline({
    super.key,
    this.title = '',
    this.subtitle = '',
    this.size = 20,
    this.isDark,
  })  : isFullScreen = false,
        isInline = true;

  @override
  State<GovLoadingIndicator> createState() => _GovLoadingIndicatorState();
}

class _GovLoadingIndicatorState extends State<GovLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDark = widget.isDark ?? (Theme.of(context).brightness == Brightness.dark);

    if (widget.isInline) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  effectiveDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                ),
              ),
            );
          },
        ),
      );
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── DUAL-RING TRICOLOR ORBITAL ANIMATION ──
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (ctx, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Clockwise Rotating Ring (Saffron & Ashoka Green Gradient)
                  Transform.rotate(
                    angle: _controller.value * 2 * math.pi,
                    child: CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _OrbitalRingPainter(
                        color: AppColors.secondarySaffron,
                        accentColor: AppColors.accentGreen,
                        strokeWidth: 3.5,
                      ),
                    ),
                  ),

                  // Inner Counter-Clockwise Rotating Ring (Navy / White)
                  Transform.rotate(
                    angle: -_controller.value * 2 * math.pi,
                    child: CustomPaint(
                      size: Size(widget.size * 0.7, widget.size * 0.7),
                      painter: _OrbitalRingPainter(
                        color: effectiveDark ? Colors.white70 : AppColors.primaryNavy,
                        accentColor: AppColors.secondarySaffron,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),

                  // Center Breathing Core Emblem
                  Transform.scale(
                    scale: 0.85 + (math.sin(_controller.value * 2 * math.pi).abs() * 0.25),
                    child: Container(
                      width: widget.size * 0.38,
                      height: widget.size * 0.38,
                      decoration: BoxDecoration(
                        color: effectiveDark ? const Color(0xFF131B38) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondarySaffron.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shield_rounded,
                        size: widget.size * 0.22,
                        color: AppColors.secondarySaffron,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        // ── TITLE & CIVIC STATUS ──
        if (widget.title.isNotEmpty) ...[
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: effectiveDark ? Colors.white : AppColors.primaryNavy,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
        ],

        if (widget.subtitle.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: effectiveDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // ── 3 STAGGERED CIVIC DOTS ──
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0, t, AppColors.secondarySaffron),
                const SizedBox(width: 6),
                _buildDot(1, t, effectiveDark ? Colors.white : AppColors.primaryNavy),
                const SizedBox(width: 6),
                _buildDot(2, t, AppColors.accentGreen),
              ],
            );
          },
        ),
      ],
    );

    if (widget.isFullScreen) {
      return Scaffold(
        backgroundColor: effectiveDark ? const Color(0xFF0A0F24) : AppColors.backgroundLight,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: content,
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: content,
      ),
    );
  }

  Widget _buildDot(int index, double t, Color color) {
    final offset = (t * 3 - index).clamp(0.0, 1.0);
    final scale = 0.8 + (math.sin(offset * math.pi) * 0.4);
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Custom painter for orbital ring sweep
class _OrbitalRingPainter extends CustomPainter {
  final Color color;
  final Color accentColor;
  final double strokeWidth;

  _OrbitalRingPainter({
    required this.color,
    required this.accentColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track background
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Active sweep arc
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0.0), color, accentColor],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      1.8 * math.pi,
      false,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitalRingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
