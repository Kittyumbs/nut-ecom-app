import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

import '../screens/scan_screen.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController; // Cho QR code
  final Map<int, bool> _hoverStates = {}; // Track hover state cho từng item
  final Map<int, bool> _hasShownSelectAnimation =
      {}; // Track xem đã hiển thị animation khi select chưa
  final Map<int, AnimationController> _selectAnimationControllers =
      {}; // Animation controller cho mỗi item khi select
  int? _previousSelectedIndex; // Track index được chọn trước đó

  @override
  void initState() {
    super.initState();
    // Animation có frame rate ~60fps và out point ~150 frames
    // Duration mặc định: 150/60 = 2.5 giây
    // Để làm chậm xuống 0.5x: duration = 2.5 * 2 = 5 giây
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 5000), // 5 giây để làm chậm animation xuống 0.5x
    );
    _animationController.repeat();
    _previousSelectedIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Khi index thay đổi (user click vào item mới)
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Trigger animation hiện lên rồi biến mất cho item mới được chọn
      final newIndex = widget.currentIndex;
      if (!_selectAnimationControllers.containsKey(newIndex)) {
        // Tạo animation controller mới cho item này
        final controller = AnimationController(
          vsync: this,
          duration: const Duration(
              milliseconds:
                  250), // Thời gian để to dần từ 0 đến 100 (nhanh gấp 3: 400/3 ≈ 133ms)
        );
        _selectAnimationControllers[newIndex] = controller;

        // Khi animation hoàn thành (đạt kích thước 100), dừng lại 100ms rồi biến mất
        controller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            // Dừng lại 100ms rồi mới biến mất
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                setState(() {
                  _hasShownSelectAnimation[newIndex] = false;
                });
                // Dispose controller sau khi hoàn thành
                _selectAnimationControllers[newIndex]?.dispose();
                _selectAnimationControllers.remove(newIndex);
              }
            });
          }
        });

        setState(() {
          _hasShownSelectAnimation[newIndex] = true;
        });
        controller.forward(); // Bắt đầu animation
      }
      _previousSelectedIndex = widget.currentIndex;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Dispose tất cả animation controllers
    for (var controller in _selectAnimationControllers.values) {
      controller.dispose();
    }
    _selectAnimationControllers.clear();
    super.dispose();
  }

  // Scale factor dựa trên màn hình 390x844
  double _getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / 390.0;
  }

  @override
  Widget build(BuildContext context) {
    final scale = _getScaleFactor(context);

    // Base dimensions từ design 390x844
    const baseNavBarWidth = 390.0;
    const baseNavBarHeight = 60.0;
    const baseIconWidth = 78.0;
    const baseIconHeight = 60.0;
    const baseStrokeWidth = 2.0;

    final screenWidth = MediaQuery.of(context).size.width;

    return ClipRect(
      child: Container(
        width: screenWidth,
        height: baseNavBarHeight * scale,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          clipBehavior: Clip
              .hardEdge, // Clip để hình tròn không tràn ra ngoài bottom nav bar
          children: [
            // Stroke top inside (vẽ bên trong)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: baseStrokeWidth * scale,
                color: const Color(0xFFFFDE7D)
                    .withOpacity(0.7), // FFDE7D với 70% opacity
              ),
            ),
            // Row chứa các icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Trang chủ
                _buildNavItem(
                  context: context,
                  scale: scale,
                  width: baseIconWidth * scale,
                  height: baseIconHeight * scale,
                  iconPathLight: 'assets/images/icons/home_light.svg',
                  iconPathFill: 'assets/images/icons/home_fill.svg',
                  label: 'Trang chủ',
                  index: 0,
                  isSelected: widget.currentIndex == 0,
                  onTap: () => widget.onTap(0),
                  onHover: (bool isHovering) {
                    setState(() {
                      _hoverStates[0] = isHovering;
                    });
                  },
                  isHovered: _hoverStates[0] ?? false,
                ),
                // Kho
                _buildNavItem(
                  context: context,
                  scale: scale,
                  width: baseIconWidth * scale,
                  height: baseIconHeight * scale,
                  iconPathLight: 'assets/images/icons/warehouse_light.svg',
                  iconPathFill: 'assets/images/icons/warehouse_fill.svg',
                  label: 'Kho',
                  index: 1,
                  isSelected: widget.currentIndex == 1,
                  onTap: () => widget.onTap(1),
                  onHover: (bool isHovering) {
                    setState(() {
                      _hoverStates[1] = isHovering;
                    });
                  },
                  isHovered: _hoverStates[1] ?? false,
                ),
                // QR Code (không có text)
                _buildQRCodeItem(
                  context: context,
                  scale: scale,
                  width: baseIconWidth * scale,
                  height: baseIconHeight * scale,
                  isSelected: widget.currentIndex == 2,
                  onTap: () => widget.onTap(2),
                  animationController: _animationController,
                ),
                // Sản phẩm
                _buildNavItem(
                  context: context,
                  scale: scale,
                  width: baseIconWidth * scale,
                  height: baseIconHeight * scale,
                  iconPathLight: 'assets/images/icons/product_light.svg',
                  iconPathFill: 'assets/images/icons/product_fill.svg',
                  label: 'Sản phẩm',
                  index: 3,
                  isSelected: widget.currentIndex == 3,
                  onTap: () => widget.onTap(3),
                  onHover: (bool isHovering) {
                    setState(() {
                      _hoverStates[3] = isHovering;
                    });
                  },
                  isHovered: _hoverStates[3] ?? false,
                ),
                // Giao dịch
                _buildNavItem(
                  context: context,
                  scale: scale,
                  width: baseIconWidth * scale,
                  height: baseIconHeight * scale,
                  iconPathLight: 'assets/images/icons/transaction_light.svg',
                  iconPathFill: 'assets/images/icons/transaction_fill.svg',
                  label: 'Giao dịch',
                  index: 4,
                  isSelected: widget.currentIndex == 4,
                  onTap: () => widget.onTap(4),
                  onHover: (bool isHovering) {
                    setState(() {
                      _hoverStates[4] = isHovering;
                    });
                  },
                  isHovered: _hoverStates[4] ?? false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required double scale,
    required double width,
    required double height,
    required String iconPathLight,
    required String iconPathFill,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
    required Function(bool) onHover,
    required bool isHovered,
  }) {
    // Hiển thị fill icon khi selected hoặc hover
    final shouldShowFill = isSelected || isHovered;
    final iconPath = shouldShowFill ? iconPathFill : iconPathLight;

    // Hiển thị hình tròn khi:
    // 1. Hover (luôn hiển thị khi hover)
    // 2. Hoặc khi select lần đầu (to dần từ center rồi biến mất)
    final isShowingSelectAnimation =
        isSelected && (_hasShownSelectAnimation[index] ?? false);
    final shouldShowCircle = isHovered || isShowingSelectAnimation;

    // Animation value cho select animation (0.0 -> 1.0)
    final selectAnimationValue =
        _selectAnimationControllers[index]?.value ?? 0.0;

    // Kích thước hình tròn: 100 * scale
    // Khi hover: full size (100 * scale)
    // Khi select: to dần từ 0 đến 100 * scale
    final baseCircleSize = 100 * scale;
    final hoverCircleSize = isHovered ? baseCircleSize : 0.0;
    final selectCircleSize =
        isShowingSelectAnimation ? baseCircleSize * selectAnimationValue : 0.0;
    final actualCircleSize =
        hoverCircleSize > selectCircleSize ? hoverCircleSize : selectCircleSize;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip
                .none, // Cho phép hình tròn tràn ra ngoài item nhưng vẫn trong bottom nav bar
            children: [
              // Hình tròn màu xám nhạt khi hover hoặc khi select lần đầu
              // To dần từ center của item (78x60), có thể tràn ra 2 icon bên cạnh
              if (shouldShowCircle)
                // Nếu đang có animation select, dùng AnimatedBuilder
                isShowingSelectAnimation &&
                        _selectAnimationControllers[index] != null
                    ? AnimatedBuilder(
                        animation: _selectAnimationControllers[index]!,
                        builder: (context, child) {
                          final animValue =
                              _selectAnimationControllers[index]!.value;
                          final currentSize = baseCircleSize * animValue;
                          if (currentSize <= 0) return const SizedBox.shrink();
                          return Positioned(
                            // Căn giữa tại center của item (78x60)
                            top: (height / 2) - (currentSize / 2),
                            left: (width / 2) - (currentSize / 2),
                            child: Container(
                              width: currentSize,
                              height: currentSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey
                                    .withOpacity(0.25), // Màu xám nhạt
                              ),
                            ),
                          );
                        },
                      )
                    // Nếu chỉ hover (không có animation select), hiển thị bình thường
                    : Positioned(
                        // Căn giữa tại center của item (78x60) - cho hover
                        top: (height / 2) - (actualCircleSize / 2),
                        left: (width / 2) - (actualCircleSize / 2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: actualCircleSize,
                          height: actualCircleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                Colors.grey.withOpacity(0.25), // Màu xám nhạt
                          ),
                        ),
                      ),
              // Column chứa icon và text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon căn giữa (với animation khi hover)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 24 * scale,
                    height: 24 * scale,
                    child: SvgPicture.asset(
                      iconPath,
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  // Padding giữa icon và text (giảm để text gần icon hơn)
                  SizedBox(height: 2 * scale),
                  // Text
                  Text(
                    label,
                    style: GoogleFonts.alef(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRCodeItem({
    required BuildContext context,
    required double scale,
    required double width,
    required double height,
    required bool isSelected,
    required VoidCallback onTap,
    required AnimationController animationController,
  }) {
    return GestureDetector(
      onTap: () async {
        final scannedCode = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => const ScanScreen(isSingleScanMode: true),
          ),
        );
        if (scannedCode != null && scannedCode.isNotEmpty) {
          // Handle the single scanned code, e.g., show a dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Scanned Code'),
              content: Text(scannedCode),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Lottie.asset(
              'assets/animations/Scan_qr_code.json',
              fit: BoxFit.contain,
              controller: animationController,
            ),
          ),
        ),
      ),
    );
  }
}
