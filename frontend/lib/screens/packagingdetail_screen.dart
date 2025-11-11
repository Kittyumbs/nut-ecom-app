import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

// Mock data class for product
class Product {
  final String id;
  final String sku;
  final String name;
  final String location;
  final int requiredQuantity;
  final String imageUrl;
  int currentQuantity;

  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.location,
    required this.requiredQuantity,
    required this.imageUrl,
    this.currentQuantity = 0,
  });
}

class PackagingDetailScreen extends StatefulWidget {
  final String orderId;
  final String platform;

  const PackagingDetailScreen({
    super.key,
    required this.orderId,
    required this.platform,
  });

  @override
  State<PackagingDetailScreen> createState() => _PackagingDetailScreenState();
}

class _PackagingDetailScreenState extends State<PackagingDetailScreen> {
  // Mock products data
  final List<Product> _products = [
    Product(
      id: '1',
      sku: 'SKU001',
      name: 'Bánh hạt điều 250g',
      location: 'K1.A03.R4',
      requiredQuantity: 5,
      imageUrl: 'assets/images/product1.jpg',
    ),
    Product(
      id: '2',
      sku: 'SKU002',
      name: 'Hạt điều rang muối 500g',
      location: 'K1.A02.R2',
      requiredQuantity: 3,
      imageUrl: 'assets/images/product2.jpg',
    ),
    Product(
      id: '3',
      sku: 'SKU003',
      name: 'Hạt điều mật ong 300g',
      location: 'K1.A01.R1',
      requiredQuantity: 2,
      imageUrl: 'assets/images/product3.jpg',
    ),
  ];

  // Controllers for SKU input fields
  final List<TextEditingController> _skuControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each product
    for (var i = 0; i < _products.length; i++) {
      _skuControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _skuControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Calculate total progress
  String _getProgress() {
    int total = 0;
    int current = 0;
    for (var product in _products) {
      total += product.requiredQuantity;
      current += product.currentQuantity;
    }
    return '$current/$total';
  }

  // Update quantity for a product
  void _updateQuantity(int index, int delta) {
    setState(() {
      final newQuantity = _products[index].currentQuantity + delta;
      if (newQuantity >= 0 &&
          newQuantity <= _products[index].requiredQuantity) {
        _products[index].currentQuantity = newQuantity;
      }
    });
  }

  // Set maximum quantity for a product
  void _setMaxQuantity(int index) {
    setState(() {
      _products[index].currentQuantity = _products[index].requiredQuantity;
    });
  }

  // Check if all products have been filled with required quantities
  bool _isAllProductsFilled() {
    for (var product in _products) {
      if (product.currentQuantity < product.requiredQuantity) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width / 390.0;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content area with products
          Positioned(
            top: 100 * scale, // Below header
            left: 0,
            right: 0,
            bottom: 60 * scale, // Above footer
            child: ListView.builder(
              padding: EdgeInsets.all(10 * scale),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 10 * scale),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8 * scale),
                      border: Border.all(
                        color: const Color(0xFFAEAEAE).withOpacity(0.1),
                        width: 1 * scale,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: Offset(1 * scale, 1 * scale),
                          blurRadius: 10 * scale,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // SKU Input Row
                        Padding(
                          padding: EdgeInsets.all(10 * scale),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: 40 * scale,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    border: Border.all(
                                      color: const Color(0xFFAEAEAE),
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(5 * scale),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _skuControllers[index],
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          decoration: InputDecoration(
                                            isCollapsed: true,
                                            hintText: 'Nhập mã SKU/Barcode',
                                            hintStyle: TextStyle(
                                              fontSize: 14 * scale,
                                              color: const Color(0xFF666666),
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 10 * scale,
                                            ),
                                            fillColor: Colors.white,
                                            filled: _skuControllers[index]
                                                .text
                                                .isNotEmpty,
                                          ),
                                          style: TextStyle(
                                            fontSize: 14 * scale,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 40 * scale,
                                        height: 40 * scale,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: Color(0xFFAEAEAE),
                                            ),
                                          ),
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/images/icons/grid_icon.svg',
                                            width: 24 * scale,
                                            height: 24 * scale,
                                            colorFilter: const ColorFilter.mode(
                                              Color(0xFF666666),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Product Info
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * scale,
                            vertical: 5 * scale,
                          ),
                          child: Row(
                            children: [
                              // Product Image
                              Container(
                                width: 80 * scale,
                                height: 80 * scale,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFAEAEAE),
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(5 * scale),
                                ),
                                child: Center(
                                  child: Text(
                                    'Hình ảnh',
                                    style: TextStyle(
                                      color: const Color(0xFFAEAEAE),
                                      fontSize: 12 * scale,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10 * scale),
                              // Grid Icon

                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SKU: ${product.sku}',
                                      style: TextStyle(
                                        fontSize: 14 * scale,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5 * scale),
                                    Text(
                                      product.name,
                                      style: TextStyle(
                                        fontSize: 14 * scale,
                                      ),
                                    ),
                                    SizedBox(height: 5 * scale),
                                    Text(
                                      'Vị trí: ${product.location}',
                                      style: TextStyle(
                                        fontSize: 14 * scale,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Quantity Control
                        Padding(
                          padding: EdgeInsets.all(10 * scale),
                          child: Row(
                            children: [
                              Text(
                                'Số lượng yêu cầu: ${product.requiredQuantity}',
                                style: TextStyle(
                                  fontSize: 14 * scale,
                                  color: const Color(0xFFAEAEAE),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFAEAEAE),
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(5 * scale),
                                ),
                                child: Row(
                                  children: [
                                    // Minus button
                                    GestureDetector(
                                      onTap: () => _updateQuantity(index, -1),
                                      child: Container(
                                        width: 30 * scale,
                                        height: 30 * scale,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                              color: const Color(0xFFAEAEAE),
                                            ),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          size: 20 * scale,
                                        ),
                                      ),
                                    ),
                                    // Current quantity
                                    Container(
                                      width: 40 * scale,
                                      height: 30 * scale,
                                      color: const Color(0xFFF5F5F5),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${product.currentQuantity}',
                                        style: TextStyle(
                                          fontSize: 16 * scale,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Plus button
                                    GestureDetector(
                                      onTap: () => _updateQuantity(index, 1),
                                      child: Container(
                                        width: 30 * scale,
                                        height: 30 * scale,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: const Color(0xFFAEAEAE),
                                            ),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 20 * scale,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10 * scale),
                              // MAX button
                              GestureDetector(
                                onTap: () => _setMaxQuantity(index),
                                child: Container(
                                  width: 50 * scale,
                                  height: 30 * scale,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFDE7D),
                                    borderRadius:
                                        BorderRadius.circular(5 * scale),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'MAX',
                                    style: TextStyle(
                                      fontSize: 14 * scale,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Fixed header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100 * scale,
              color: Colors.white,
              child: Stack(
                children: [
                  // Decorative triangles
                  CustomPaint(
                    painter: TrianglePainter(scale: scale),
                    size: Size(screenWidth, 100 * scale),
                  ),
                  // Back button
                  Positioned(
                    left: 6 * scale,
                    top: 32 * scale,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        width: 25 * scale,
                        height: 35 * scale,
                        child: SvgPicture.asset(
                          'assets/images/icons/back_arrow.svg',
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Title
                  Positioned(
                    left: 25 * scale,
                    top: 37 * scale, // Giống packaging_screen
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Soạn hàng CHI TIẾT ',
                              style: TextStyle(
                                fontFamily: 'AndadaPro',
                                fontSize: 20 * scale,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '(#${widget.orderId})',
                              style: TextStyle(
                                fontFamily: 'AndadaPro',
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Box thông báo
                  Positioned(
                    left: 20 * scale,
                    top: 67 * scale,
                    child: Container(
                      width: 350 * scale,
                      height: 30 * scale,
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
                          // Icon info
                          Positioned(
                            left: 3 * scale,
                            top: 4 * scale,
                            child: SizedBox(
                              width: 22 * scale,
                              height: 22 * scale,
                              child: SvgPicture.asset(
                                'assets/images/icons/info_icon.svg',
                                colorFilter: const ColorFilter.mode(
                                  Colors.black,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          // Text thông báo
                          Positioned(
                            left: 29 * scale,
                            top: 8 * scale,
                            child: Text(
                              'Chưa có thông báo nào!',
                              style: TextStyle(
                                fontFamily: 'AlumniSans',
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w900,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Fixed footer
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 100 * scale,
              padding: EdgeInsets.symmetric(
                horizontal: 15 * scale,
                vertical: 15 * scale,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, -2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'Đã soạn: ${_getProgress()}',
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: SizedBox(
                      height: 70 * scale,
                      child: ElevatedButton(
                        onPressed: _isAllProductsFilled()
                            ? () {
                                // Navigate back when all products are filled
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isAllProductsFilled()
                              ? const Color(0xFFF6416C)
                              : Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5 * scale),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 8 * scale,
                          ),
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                        child: Text(
                          'HOÀN TẤT SOẠN HÀNG\nvà IN BILL VẬN CHUYỂN',
                          style: TextStyle(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final double scale;

  TrianglePainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFDE7D)
      ..style = PaintingStyle.fill;

    // 1. Large Left Triangle
    final path1 = Path()
      ..moveTo(5 * scale, 10 * scale)
      ..lineTo(5 * scale, 95 * scale)
      ..lineTo(120 * scale, 50 * scale)
      ..close();
    canvas.drawPath(path1, paint);

    // 2. Upper-Middle Thin Triangle
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

    // 3. Small Top-Right Triangle
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

    // 4. Bottom-Middle Upright Triangle
    final path4 = Path()
      ..moveTo(190 * scale, 95 * scale)
      ..lineTo(230 * scale, 95 * scale)
      ..lineTo(210 * scale, 50 * scale)
      ..close();
    canvas.drawPath(path4, paint);

    // 5. Large Right Inverted Triangle
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
