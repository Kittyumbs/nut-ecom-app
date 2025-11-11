import 'package:flutter/material.dart';

// Mock data class cho sản phẩm
class QuickPickProduct {
  final String name;
  final String sku;
  final String location;
  final int requiredQuantity;
  final bool isComplete;

  QuickPickProduct({
    required this.name,
    required this.sku,
    required this.location,
    required this.requiredQuantity,
    required this.isComplete,
  });
}

// Mock data
final List<QuickPickProduct> mockProducts = [
  QuickPickProduct(
    name: 'Bánh hạt điều 250g',
    sku: 'SKU001',
    location: 'K1.A03.R4',
    requiredQuantity: 5,
    isComplete: true,
  ),
  QuickPickProduct(
    name: 'Hạt điều rang muối 500g',
    sku: 'SKU002',
    location: 'K1.A02.R2',
    requiredQuantity: 3,
    isComplete: false,
  ),
  QuickPickProduct(
    name: 'Hạt điều mật ong 300g',
    sku: 'SKU003',
    location: 'K1.A01.R1',
    requiredQuantity: 2,
    isComplete: true,
  ),
];

class QuickPickingModal extends StatelessWidget {
  final String orderId;

  const QuickPickingModal({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 390.0;
    final screenHeight = MediaQuery.of(context).size.height;

    // Tính tổng số lượng cần soạn
    final totalQuantity = mockProducts.fold<int>(
      0,
      (sum, product) => sum + product.requiredQuantity,
    );

    return Container(
      height: screenHeight * 0.67, // Set height to 2/3 of screen height
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFDE7D),
            Colors.white,
          ],
          stops: [0.0, 0.3],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20 * scale),
          topRight: Radius.circular(20 * scale),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 50 * scale,
            height: 4 * scale,
            margin: EdgeInsets.only(top: 10 * scale),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2 * scale),
            ),
          ),
          // Title
          Padding(
            padding: EdgeInsets.only(
              top: 16 * scale,
              left: 16 * scale,
              right: 16 * scale,
              bottom: 8 * scale,
            ),
            child: Text(
              'Soạn hàng (#$orderId)',
              style: TextStyle(
                fontSize: 20 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Total quantity
          Padding(
            padding: EdgeInsets.only(
              bottom: 16 * scale,
            ),
            child: Text(
              'Cần soạn: $totalQuantity',
              style: TextStyle(
                fontSize: 16 * scale,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Product list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              itemCount: mockProducts.length,
              itemBuilder: (context, index) {
                final product = mockProducts[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12 * scale),
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Product info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            Text(
                              'SKU: ${product.sku}',
                              style: TextStyle(
                                fontSize: 14 * scale,
                                color: Colors.grey[600],
                              ),
                            ),
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
                      // Quantity
                      Text(
                        'Cần soạn: ${product.requiredQuantity}',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Action button
          Padding(
            padding: EdgeInsets.all(16 * scale),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ConfirmationDialog(
                    orderId: orderId,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF6416C),
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * scale,
                  vertical: 16 * scale,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
              ),
              child: Text(
                'HOÀN TẤT SOẠN HÀNG\nvà IN BILL VẬN CHUYỂN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  final String orderId;

  const ConfirmationDialog({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 390.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Xác nhận?',
              style: TextStyle(
                fontSize: 18 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16 * scale),
            Text(
              'Bạn chắc chắn đã soạn hàng đủ và sẵn sàng in Bill vận chuyển?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14 * scale,
              ),
            ),
            SizedBox(height: 24 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng dialog
                  },
                  child: Text(
                    'Kiểm tra lại',
                    style: TextStyle(
                      fontSize: 16 * scale,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng dialog
                    Navigator.pop(context); // Đóng bottom sheet
                    // TODO: Thêm logic xử lý khi hoàn tất
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6416C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                  ),
                  child: Text(
                    'Xác nhận',
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
