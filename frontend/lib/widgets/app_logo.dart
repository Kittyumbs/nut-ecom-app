import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: width,
      height: height,
      color: color,
      fit: BoxFit.contain,
    );
  }
}

