import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/app_header.dart';

class WarehouseScreen extends StatelessWidget {
  const WarehouseScreen({super.key});

  // Scale factor dựa trên màn hình 390x844
  double _getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / 390.0;
  }

  @override
  Widget build(BuildContext context) {
    final scale = _getScaleFactor(context);
    final headerHeight = 100.0 * scale;

    // Base dimensions from design 390x844, similar to HomeScreen
    const baseIconSize = 70.0;
    const baseTop = 120.0;
    const baseLeft1 = 30.0;
    const baseLeft2 = 160.0;
    const baseLeft3 = 290.0;
    const baseTextFontSize = 14.0;
    const baseTextSpacing = 8.0; // Khoảng cách giữa icon và text

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main content - icons
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Icon stock.svg with text
              _buildMenuIcon(
                context: context,
                scale: scale,
                iconPath: 'assets/images/stock.svg',
                label: 'Tồn kho',
                top: baseTop * scale,
                left: baseLeft1 * scale,
                onTap: () {
                  // TODO: Navigate to stock screen
                },
              ),
              // Icon return.svg with text
              _buildMenuIcon(
                context: context,
                scale: scale,
                iconPath: 'assets/images/return.svg',
                label: 'Nhập trả',
                top: baseTop * scale,
                left: baseLeft2 * scale,
                onTap: () {
                  // TODO: Navigate to return screen
                },
              ),
              // Icon destroy.svg with text
              _buildMenuIcon(
                context: context,
                scale: scale,
                iconPath: 'assets/images/destroy.svg',
                label: 'Tiêu hủy',
                top: baseTop * scale,
                left: baseLeft3 * scale,
                onTap: () {
                  // TODO: Navigate to destroy screen
                },
              ),
            ],
          ),
          // Fixed Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: false,
              child: SizedBox(
                height: headerHeight,
                child: const OverflowBox(
                  maxHeight: double.infinity,
                  maxWidth: double.infinity,
                  alignment: Alignment.topLeft,
                  child: AppHeader(
                    title: 'Quản lý KHO HÀNG',
                    showVersion: false,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuIcon({
    required BuildContext context,
    required double scale,
    required String iconPath,
    required String label,
    required double top,
    required double left,
    required VoidCallback onTap,
  }) {
    const baseIconSize = 70.0;
    const baseTextFontSize = 14.0;
    const baseTextSpacing = 8.0;

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: baseIconSize * scale,
              height: baseIconSize * scale,
              child: SvgPicture.asset(
                iconPath,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: baseTextSpacing * scale),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'AlumniSans',
                fontSize: baseTextFontSize * scale,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
