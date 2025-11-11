import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/app_header.dart';
import 'handover_screen.dart';
import 'packaging_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Scale factor dựa trên màn hình 390x844
  double _getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / 390.0;
  }

  @override
  Widget build(BuildContext context) {
    final scale = _getScaleFactor(context);
    final headerHeight = 100.0 * scale;

    // Base dimensions từ design 390x844
    const baseIconSize = 70.0;
    // Top = 120 là tính từ top của màn hình (bao gồm cả header)
    const baseOrdersTop = 120.0;
    const baseOrdersLeft = 30.0;
    const baseOrdersHotTop = 120.0;
    const baseOrdersHotLeft = 160.0;
    const baseHandoverTop = 120.0;
    const baseHandoverLeft = 290.0;
    const baseTextFontSize = 14.0;
    const baseTextSpacing = 8.0; // Khoảng cách giữa icon và text

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Nội dung chính - chứa các icon
          // Top = 120 tính từ top màn hình (bao gồm header), nên không cần offset headerHeight
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Icon orders.svg với text
              Positioned(
                top: baseOrdersTop * scale,
                left: baseOrdersLeft * scale,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PackagingScreen(
                          orderType: 'ĐƠN THƯỜNG',
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: baseIconSize * scale,
                        height: baseIconSize * scale,
                        child: SvgPicture.asset(
                          'assets/images/orders.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: baseTextSpacing * scale),
                      Text(
                        'Đơn hàng thường',
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
              ),
              // Icon ordershot.svg với text
              Positioned(
                top: baseOrdersHotTop * scale,
                left: baseOrdersHotLeft * scale,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PackagingScreen(
                          orderType: 'HỎA TỐC',
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: baseIconSize * scale,
                        height: baseIconSize * scale,
                        child: SvgPicture.asset(
                          'assets/images/ordershot.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: baseTextSpacing * scale),
                      Text(
                        'Đơn hàng hỏa tốc',
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
              ),
              // Icon handover.svg với text
              Positioned(
                top: baseHandoverTop * scale,
                left: baseHandoverLeft * scale,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HandoverScreen(),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: baseIconSize * scale,
                        height: baseIconSize * scale,
                        child: SvgPicture.asset(
                          'assets/images/handover.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: baseTextSpacing * scale),
                      Text(
                        'Bàn giao hàng hóa',
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
              ),
            ],
          ),
          // Header cố định - height 100px, box thông báo sẽ overflow đè lên
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: false,
              child: SizedBox(
                height: headerHeight, // Height cố định 100px
                child: OverflowBox(
                  maxHeight: double.infinity,
                  maxWidth: double.infinity,
                  alignment: Alignment.topLeft,
                  child: const AppHeader(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
