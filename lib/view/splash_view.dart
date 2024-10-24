import 'package:efeone_mobile/controllers/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final splashprovider = Provider.of<Splashcontroller>(context, listen: true);

    // Trigger the scale animation after a delay
    Future.delayed(const Duration(milliseconds: 500)).whenComplete(() {
      splashprovider.startAnimation();
      Future.delayed(const Duration(seconds: 2)).whenComplete(() {
        splashprovider.checklogin(context);
      });
    });

    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double imageWidth = constraints.maxWidth * 0.4;
            final double imageHeight = imageWidth * 0.3;

            return Container(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedScale(
                scale: splashprovider.isScaled ? 1.0 : 0.0, // Scale to 1.0 to show the image
                duration: const Duration(seconds: 1), // Animation duration
                curve: Curves.easeInOut, // Animation curve
                child: Image.asset(
                  'assets/images/efeone Logo.png',
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
