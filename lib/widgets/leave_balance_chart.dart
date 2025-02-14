
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class HalfDoughnutChart extends StatelessWidget {
  final double totalLeaves;
  final double leavesRemaining;
  final Color baseColor;
  final String title;

  const HalfDoughnutChart({
    super.key,
    required this.totalLeaves,
    required this.leavesRemaining,
    required this.baseColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
   double leavePercentage = (totalLeaves > 0) 
      ? (leavesRemaining / totalLeaves).clamp(0.0, 1.0) * 180
      : 0.0; // Prevent division by zero

  Color dynamicColor = (totalLeaves > 0)
      ? baseColor.withOpacity(1 - (leavesRemaining / totalLeaves) * 0.5)
      : baseColor.withOpacity(0.2); // Use base opacity if no leaves

    return Container(
      width: 160,
      height: 160, // Adjusted height for better fit
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 60, // Adjusted to fit half-doughnut properly
            child: CustomPaint(
              size: const Size(100, 50),
              painter:
                  HalfDoughnutPainter(leavePercentage, baseColor, dynamicColor),
            ),
          ),
          const SizedBox(height: 6),
          custom_text(
          text:  '${leavesRemaining.toInt()} / ${totalLeaves.toInt()}',
          
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
          
          ),
          const SizedBox(height: 8),
          custom_text(
          text:  title,
            textAlign: TextAlign.center,
            
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
           
          ),
        ],
      ),
    );
  }
}

class HalfDoughnutPainter extends CustomPainter {
  final double leaveAngle;
  final Color baseColor;
  final Color fillColor;

  HalfDoughnutPainter(this.leaveAngle, this.baseColor, this.fillColor);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = baseColor.withOpacity(0.2) // Softer background color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16 // Increased thickness
      ..strokeCap = StrokeCap.round;

    final Paint foregroundPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16 // Increased thickness
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2.4; // Slightly adjusted for better alignment

    // Draw full half-circle background
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      backgroundPaint,
    );

    // Draw the leave usage portion
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      leaveAngle * (pi / 180),
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(HalfDoughnutPainter oldDelegate) {
    return oldDelegate.leaveAngle != leaveAngle ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.baseColor != baseColor;
  }
}
