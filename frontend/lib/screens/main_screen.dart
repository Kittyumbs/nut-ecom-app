import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'warehouse_screen.dart';
import 'products_screen.dart';
import 'transactions_screen.dart';
import 'scan_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  final int? initialIndex;
  
  const MainScreen({super.key, this.initialIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const WarehouseScreen(),
    const ProductsScreen(), // QR Code sẽ navigate đến ScanScreen thay vì hiển thị ở đây
    const ProductsScreen(),
    const TransactionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Lấy padding từ MediaQuery để xử lý home indicator
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      // Không dùng SafeArea để app fill toàn màn hình (bao gồm notch/island)
      body: _screens[_currentIndex],
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // Khi click vào QR code (index 2), navigate đến ScanScreen
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanScreen(),
                ),
              );
            } else {
              // Các tab khác thì chuyển tab bình thường
              setState(() {
                _currentIndex = index;
              });
            }
          },
        ),
      ),
    );
  }
}

