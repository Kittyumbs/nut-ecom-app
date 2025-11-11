import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class AppHeader extends StatelessWidget {
  final String title;
  final bool showVersion;

  const AppHeader({
    super.key,
    this.title = 'Chào, Anh Duy',
    this.showVersion = true,
  });

  // Scale factor dựa trên màn hình 390x844
  double _getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / 390.0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = _getScaleFactor(context);

    // Base dimensions từ design 390x844
    const baseHeaderWidth = 390.0;
    const baseHeaderHeight = 100.0;
    const baseGreetingLeft = 20.0;
    const baseGreetingTop = 42.0;
    const baseGreetingFontSize = 14.0; // Font size của "Chào, Anh Duy"
    const baseVersionLeft = 343.0; // Padding từ bên trái theo design
    const baseVersionTop = 46.0;
    const baseNotificationBoxWidth = 350.0;
    const baseNotificationBoxHeight = 30.0;
    const baseNotificationBoxLeft = 20.0;
    // Box thông báo: Nằm dưới text "Chào, Anh Duy" và đè lên header
    // Text "Chào, Anh Duy": Top: 42px, Font: 14px → kết thúc khoảng 56px
    // Khoảng cách từ text đến box: ~10px
    // Box thông báo: Height 30px
    // Để đè lên header (100px): đặt top: 66px
    // - 34px trong header (66-100px)
    // - Overflow ra ngoài (100-130px) nhưng vẫn đè lên
    const baseNotificationBoxTop =
        66.0; // 66px từ top AppHeader (dưới text, đè lên header)
    const baseIconSize = 22.0;
    const baseIconLeft = 3.0;
    const baseIconTop = 4.0;
    const baseTextLeft = 29.0;
    const baseTextTop = 8.0;

    return Stack(
      clipBehavior: Clip.none, // Cho phép overflow để box thông báo đè lên
      children: [
        // Box nền trắng 390x100 (cố định)
        Container(
          width: screenWidth,
          height: baseHeaderHeight * scale,
          color: Colors.white,
        ),
        // Tam giác trang trí màu FFDE7D (chỉ trong phần header 100px)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: baseHeaderHeight * scale,
          child: CustomPaint(
            painter: TrianglePainter(scale: scale),
          ),
        ),
        // Text "Chào, Anh Duy"
        Positioned(
          left: baseGreetingLeft * scale,
          top: baseGreetingTop * scale,
          child: Text(
            title,
            style: GoogleFonts.andadaPro(
              fontSize: 14 * scale,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
        // Text "ver: 1.0.0"
        if (showVersion)
          Positioned(
            left: baseVersionLeft * scale,
            top: baseVersionTop * scale,
            child: Text(
              'ver: 1.0.0',
              style: GoogleFonts.andadaPro(
                fontSize: 8 * scale,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
        // Box thông báo
        Positioned(
          left: baseNotificationBoxLeft * scale,
          top: baseNotificationBoxTop * scale,
          child: Container(
            width: (baseNotificationBoxWidth * scale).clamp(
                0.0, screenWidth - (baseNotificationBoxLeft * 2 * scale)),
            height: baseNotificationBoxHeight * scale,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: Offset(1 * scale, 1 * scale),
                  blurRadius: 10 * scale,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Icon bell
                Positioned(
                  left: baseIconLeft * scale,
                  top: baseIconTop * scale,
                  child: SizedBox(
                    width: baseIconSize * scale,
                    height: baseIconSize * scale,
                    child: SvgPicture.asset(
                      'assets/images/icons/bell_icon.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                // Text "Chưa có thông báo nào!"
                Positioned(
                  left: baseTextLeft * scale,
                  top: baseTextTop * scale,
                  child: Text(
                    'Chưa có thông báo nào!',
                    style: GoogleFonts.alumniSans(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  final double scale;

  TrianglePainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFDE7D) // FFDE7D
      ..style = PaintingStyle.fill;

    final headerHeight = size.height;
    final headerWidth = size.width;

    // 1. Large Left Triangle - tam giác lớn bên trái, right-angled, pointing left
    // Chiếm khoảng 1/3 bên trái, từ gần top đến gần bottom
    final path1 = Path()
      ..moveTo(5 * scale, 10 * scale) // Top-left vertex
      ..lineTo(5 * scale, 95 * scale) // Bottom-left vertex
      ..lineTo(120 * scale, 50 * scale) // Right vertex (hypotenuse)
      ..close();
    canvas.drawPath(path1, paint);

    // 2. Upper-Middle Thin Triangle - tam giác mỏng ở giữa trên, pointing up-right
    // Ở giữa trên, mỏng và dài
    canvas.save();
    canvas.translate(180 * scale, 20 * scale);
    canvas.rotate(35 * math.pi / 180);
    final path2 = Path()
      ..moveTo(0, 0)
      ..lineTo(45 * scale, -25 * scale)
      ..lineTo(45 * scale, 5 * scale)
      ..close();
    canvas.drawPath(path2, paint);
    canvas.restore();

    // 3. Small Top-Right Triangle - tam giác nhỏ ở góc trên phải, right-angled, pointing right
    // Rất nhỏ, ở góc trên phải
    canvas.save();
    canvas.translate(340 * scale, 5 * scale);
    canvas.rotate(50 * math.pi / 180);
    final path3 = Path()
      ..moveTo(0, 0)
      ..lineTo(20 * scale, 0)
      ..lineTo(0, 20 * scale)
      ..close();
    canvas.drawPath(path3, paint);
    canvas.restore();

    // 4. Bottom-Middle Upright Triangle - tam giác đứng ở giữa dưới, isosceles, pointing up
    // Đứng thẳng, ở giữa dưới
    final path4 = Path()
      ..moveTo(190 * scale, 95 * scale) // Bottom-left
      ..lineTo(230 * scale, 95 * scale) // Bottom-right
      ..lineTo(210 * scale, 50 * scale) // Top apex
      ..close();
    canvas.drawPath(path4, paint);

    // 5. Large Right Inverted Triangle - tam giác lớn bên phải, scalene, pointing down-left
    // Lớn, ở bên phải, đảo ngược
    canvas.save();
    canvas.translate(360 * scale, 35 * scale);
    canvas.rotate(-30 * math.pi / 180);
    final path5 = Path()
      ..moveTo(0, 0)
      ..lineTo(55 * scale, 0)
      ..lineTo(25 * scale, 55 * scale)
      ..close();
    canvas.drawPath(path5, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
