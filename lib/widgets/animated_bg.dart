// lib/widgets/animated_background.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // List of shapes to be displayed in the background
  final List<BackgroundShape> _shapes = List.generate(
    15, // Number of shapes
    (index) => BackgroundShape(
      left: math.Random().nextDouble() * 400,
      top: math.Random().nextDouble() * 800,
      size: math.Random().nextDouble() * 60 + 20,
      opacity: math.Random().nextDouble() * 0.3 + 0.05,
      type: math.Random().nextInt(3), // 0: circle, 1: square, 2: triangle
      rotation: math.Random().nextDouble() * 360,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDarkMode 
                        ? Theme.of(context).scaffoldBackgroundColor 
                        : primaryColor.withOpacity(0.05),
                    isDarkMode 
                        ? Theme.of(context).scaffoldBackgroundColor.withBlue(
                            Theme.of(context).scaffoldBackgroundColor.blue + 15) 
                        : primaryColor.withOpacity(0.1),
                  ],
                ),
              ),
            ),
            
            // Animated shapes
            ..._shapes.map((shape) {
              // Calculate animation value for this shape
              double animValue = (_controller.value + shape.offset) % 1.0;
              
              return Positioned(
                left: shape.left + (30 * math.sin(animValue * math.pi * 2)),
                top: shape.top + (30 * math.cos(animValue * math.pi * 2)),
                child: Transform.rotate(
                  angle: shape.rotation + (_controller.value * math.pi / 6),
                  child: Opacity(
                    opacity: shape.opacity,
                    child: Container(
                      width: shape.size,
                      height: shape.size,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: shape.type == 0 ? BoxShape.circle : BoxShape.rectangle,
                        borderRadius: shape.type == 1 
                            ? BorderRadius.circular(8) 
                            : null,
                      ),
                      child: shape.type == 2 
                          ? CustomPaint(
                              painter: TrianglePainter(color: primaryColor),
                            ) 
                          : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

// Shape data class
class BackgroundShape {
  final double left;
  final double top;
  final double size;
  final double opacity;
  final int type; // 0: circle, 1: square, 2: triangle
  final double rotation;
  final double offset;

  BackgroundShape({
    required this.left,
    required this.top,
    required this.size,
    required this.opacity,
    required this.type,
    required this.rotation,
  }) : offset = math.Random().nextDouble();
}

// Custom painter for triangle shape
class TrianglePainter extends CustomPainter {
  final Color color;
  
  TrianglePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
      
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldPainter) => false;
}