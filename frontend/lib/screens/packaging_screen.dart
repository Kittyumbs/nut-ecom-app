import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/quick_picking_modal.dart';
import 'main_screen.dart';
import 'packagingdetail_screen.dart';

// Platform colors
const Map<Platform, Color> platformColors = {
  Platform.SHOPEE: Color.fromARGB(255, 236, 84, 54),
  Platform.TIKTOK: Color(0xFF000000),
  Platform.LAZADA: Color(0xFF1A237E),
  Platform.TIKI: Color(0xFF1890FF),
};

// Status colors
const Map<OrderStatus, Color> statusColors = {
  OrderStatus.CHUA_SOAN: Color(0xFF9E9E9E),
  OrderStatus.DANG_SOAN: Color(0xFF2196F3),
  OrderStatus.DA_SOAN: Color(0xFF4CAF50),
};

class PackagingScreen extends StatefulWidget {
  final String orderType; // "ĐƠN THƯỜNG" hoặc "HỎA TỐC"

  const PackagingScreen({
    super.key,
    required this.orderType,
  });

  @override
  State<PackagingScreen> createState() => _PackagingScreenState();
}

// Enum để định nghĩa các platform
enum Platform {
  SHOPEE,
  TIKTOK,
  LAZADA,
  TIKI,
}

// Enum để định nghĩa các trạng thái
enum OrderStatus {
  CHUA_SOAN,
  DANG_SOAN,
  DA_SOAN,
}

// Class Order Card
class OrderCard {
  final String id;
  final String customerName;
  final Platform platform;
  final OrderStatus status;
  bool isSelected;

  OrderCard({
    required this.id,
    required this.customerName,
    required this.platform,
    required this.status,
    this.isSelected = false,
  });
}

class _PackagingScreenState extends State<PackagingScreen> {
  // State cho dropdowns
  String? _selectedPlatform = 'Tất cả các sàn';
  String? _selectedStatus = 'Tất cả trạng thái';
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    // Add listener for selectAll changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAllOrdersSelection();
    });
  }

  void _updateAllOrdersSelection() {
    setState(() {
      for (var order in _orders) {
        order.isSelected = _selectAll;
      }
    });
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.CHUA_SOAN:
        return 'Chưa soạn';
      case OrderStatus.DANG_SOAN:
        return 'Đang soạn';
      case OrderStatus.DA_SOAN:
        return 'Đã soạn và đóng gói';
    }
  }

  // List mock data cho orders
  final List<OrderCard> _orders = [
    OrderCard(
      id: 'SP123456789',
      customerName: 'Nguyễn Văn A',
      platform: Platform.SHOPEE,
      status: OrderStatus.CHUA_SOAN,
    ),
    OrderCard(
      id: 'TK987654321',
      customerName: 'Trần Thị B',
      platform: Platform.TIKTOK,
      status: OrderStatus.DANG_SOAN,
    ),
    OrderCard(
      id: 'LZ456789123',
      customerName: 'Lê Văn C',
      platform: Platform.LAZADA,
      status: OrderStatus.DA_SOAN,
    ),
    OrderCard(
      id: 'TI789123456',
      customerName: 'Phạm Thị D',
      platform: Platform.TIKI,
      status: OrderStatus.CHUA_SOAN,
    ),
  ];

  // State cho date pickers
  DateTime? _startDate = DateTime(2025, 1, 1);
  DateTime? _endDate = DateTime(2025, 1, 30);

  // State cho search
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Scale factor dựa trên màn hình 390x844
  double _getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / 390.0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = _getScaleFactor(context);
    final bool isAnyOrderSelected = _orders.any((order) => order.isSelected);

    // Base dimensions từ design 390x844
    const baseHeaderWidth = 390.0;
    const baseHeaderHeight = 100.0;
    const baseTitleTop = 35.0;
    const baseTitleLeft = 25.0;
    const baseTitleFontSize = 20.0;
    const baseBackIconWidth = 25.0;
    const baseBackIconHeight = 35.0;
    const baseBackIconTop = 32.0;
    const baseBackIconLeft = 6.0;
    // Box thông báo - căn chỉnh với back_arrow trên cùng 1 hàng
    const baseNotificationBoxWidth = 350.0;
    const baseNotificationBoxHeight = 30.0;
    const baseNotificationBoxLeft = 20.0;
    // Căn chỉnh box thông báo với back_arrow: back_arrow center y = 72 + 15 = 87
    // Box thông báo center y = 87, nên top = 87 - 15 = 72
    const baseNotificationBoxTop = 67.0; // Cùng hàng với back_arrow
    const baseNotificationIconSize = 22.0;
    const baseNotificationIconLeft = 3.0;
    const baseNotificationIconTop = 4.0;
    const baseNotificationTextLeft = 29.0;
    const baseNotificationTextTop = 8.0;
    const baseNotificationTextFontSize = 12.0;

    // Dimensions cho các widget mới
    const baseDateBoxTop = 105.0;
    const baseDateBoxLeft = 10.0;
    const baseDateBoxWidth = 175.0;
    const baseDateBoxHeight = 30.0;
    const baseDateBoxGap = 20.0; // Khoảng cách giữa 2 box + icon mũi tên
    const baseDateIconSize = 18.0;
    const baseDateIconLeft = 8.0;
    const baseDateTextLeft = 32.0;
    const baseDateTextFontSize = 14.0;
    const baseArrowIconSize = 16.0;

    const baseDropdownTop = 139.0;
    const baseDropdownLeft = 10.0;
    const baseDropdownWidth = 180.0;
    const baseDropdownHeight = 30.0;
    const baseDropdownGap = 10.0;
    const baseDropdownIconSize = 16.0;
    const baseDropdownIconRight = 8.0;
    const baseDropdownTextLeft = 10.0;
    const baseDropdownTextFontSize = 14.0;

    const baseSearchBoxTop = 173.0;
    const baseSearchBoxLeft = 10.0;
    const baseSearchBoxWidth = 370.0;
    const baseSearchBoxHeight = 30.0;
    const baseSearchIconSize = 18.0;
    const baseSearchIconLeft = 10.0;
    const baseSearchTextLeft = 35.0;
    const baseSearchTextFontSize = 14.0;
    const baseGridIconSize = 18.0;
    const baseGridIconRight = 10.0;

    // Lấy padding bottom cho home indicator
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: CustomBottomNavBar(
          currentIndex: 0, // Giữ nguyên index của HomeScreen
          onTap: (index) {
            if (index == 0) {
              // Nếu click vào tab Home, pop về HomeScreen
              Navigator.pop(context);
            } else {
              // Nếu click vào tab khác, navigate đến MainScreen với tab đó
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(initialIndex: index),
                ),
                (route) => false, // Xóa tất cả routes trước đó
              );
            }
          },
        ),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // ListView for order cards
          Positioned(
            top: 240 * scale,
            left: 10 * scale,
            right: 10 * scale,
            bottom: 0,
            child: ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 10 * scale),
                  child: Ink(
                    width: 360 * scale,
                    height: 60 * scale,
                    decoration: BoxDecoration(
                      color: order.isSelected
                          ? const Color(0xFFFFF9E6)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8 * scale),
                      border: Border.all(
                        color: order.isSelected
                            ? const Color(0xFFFFDE7D)
                            : const Color(0xFFAEAEAE).withOpacity(0.1),
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8 * scale),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => QuickPickingModal(
                            orderId: order.id,
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          // Checkbox
                          InkWell(
                            onTap: () {
                              setState(() {
                                order.isSelected = !order.isSelected;
                              });
                            },
                            borderRadius: BorderRadius.circular(100),
                            child: Padding(
                              padding: EdgeInsets.all(10 * scale),
                              child: Container(
                                width: 20 * scale,
                                height: 20 * scale,
                                decoration: BoxDecoration(
                                  color: order.isSelected
                                      ? const Color(0xFFFFDE7D)
                                      : Colors.white,
                                  border: Border.all(
                                    color: order.isSelected
                                        ? const Color(0xFFFFDE7D)
                                        : const Color(0xFFAEAEAE),
                                    width: 1 * scale,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(3 * scale),
                                ),
                                child: order.isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: 16 * scale,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          // Order details + Platform and status indicators
                          Expanded(
                            child: Row(
                              children: [
                                // Order details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Order ID
                                      Text(
                                        order.id,
                                        style: TextStyle(
                                          fontFamily: 'Anaheim',
                                          fontSize: 18 * scale,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      // Customer name
                                      Text(
                                        'Người mua: ${order.customerName}',
                                        style: TextStyle(
                                          fontFamily: 'Anaheim',
                                          fontSize: 12 * scale,
                                          color: const Color(0xFFAEAEAE),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Platform and status indicators
                                Padding(
                                  padding: EdgeInsets.only(right: 10 * scale),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Platform indicator
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8 * scale,
                                          vertical: 4 * scale,
                                        ),
                                        decoration: BoxDecoration(
                                          color: platformColors[order.platform],
                                          borderRadius:
                                              BorderRadius.circular(10 * scale),
                                        ),
                                        child: Text(
                                          order.platform
                                              .toString()
                                              .split('.')
                                              .last,
                                          style: TextStyle(
                                            fontFamily: 'Anaheim',
                                            fontSize: 12 * scale,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 4 * scale),
                                      // Status indicator
                                      Text(
                                        _getStatusText(order.status),
                                        style: TextStyle(
                                          fontFamily: 'Anaheim',
                                          fontSize: 12 * scale,
                                          color: statusColors[order.status],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Search icon (navigate to detail)
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PackagingDetailScreen(
                                    orderId: order.id,
                                    platform: order.platform
                                        .toString()
                                        .split('.')
                                        .last,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(100),
                            child: Padding(
                              padding: EdgeInsets.all(10 * scale),
                              child: SizedBox(
                                width: 20 * scale,
                                height: 20 * scale,
                                child: SvgPicture.asset(
                                  'assets/images/icons/search_order_icon.svg',
                                  colorFilter: const ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 2 box date picker
          // Box date từ
          Positioned(
            top: baseDateBoxTop * scale,
            left: baseDateBoxLeft * scale,
            child: _buildDateBox(
              context: context,
              scale: scale,
              width: baseDateBoxWidth * scale,
              height: baseDateBoxHeight * scale,
              date: _startDate,
              label: '01/01/2025',
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null && picked != _startDate) {
                  setState(() {
                    _startDate = picked;
                  });
                }
              },
            ),
          ),
          // Icon mũi tên giữa 2 box
          Positioned(
            top:
                (baseDateBoxTop + (baseDateBoxHeight - baseArrowIconSize) / 2) *
                    scale,
            left: (baseDateBoxLeft +
                    baseDateBoxWidth +
                    (baseDateBoxGap - baseArrowIconSize) / 2) *
                scale,
            child: SizedBox(
              width: baseArrowIconSize * scale,
              height: baseArrowIconSize * scale,
              child: SvgPicture.asset(
                'assets/images/icons/arrow_right_icon.svg',
              ),
            ),
          ),
          // Box date đến
          Positioned(
            top: baseDateBoxTop * scale,
            left: (baseDateBoxLeft + baseDateBoxWidth + baseDateBoxGap) * scale,
            child: _buildDateBox(
              context: context,
              scale: scale,
              width: baseDateBoxWidth * scale,
              height: baseDateBoxHeight * scale,
              date: _endDate,
              label: '30/01/2025',
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null && picked != _endDate) {
                  setState(() {
                    _endDate = picked;
                  });
                }
              },
            ),
          ),

          // 2 box dropdown
          // Dropdown "Tất cả các sàn"
          Positioned(
            top: baseDropdownTop * scale,
            left: baseDropdownLeft * scale,
            child: _buildDropdownBox(
              context: context,
              scale: scale,
              width: baseDropdownWidth * scale,
              height: baseDropdownHeight * scale,
              value: _selectedPlatform,
              items: ['Tất cả các sàn', 'Shopee', 'Tiktok', 'Lazada', 'Tiki'],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPlatform = newValue;
                });
              },
            ),
          ),
          // Dropdown "Tất cả trạng thái"
          Positioned(
            top: baseDropdownTop * scale,
            left: (baseDropdownLeft + baseDropdownWidth + baseDropdownGap) *
                scale,
            child: _buildDropdownBox(
              context: context,
              scale: scale,
              width: baseDropdownWidth * scale,
              height: baseDropdownHeight * scale,
              value: _selectedStatus,
              items: [
                'Tất cả trạng thái',
                'Chưa soạn',
                'Đang soạn',
                'Đã soạn và đóng gói'
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue;
                });
              },
            ),
          ),

          // Box search
          Positioned(
            top: baseSearchBoxTop * scale,
            left: baseSearchBoxLeft * scale,
            child: _buildSearchBox(
              context: context,
              scale: scale,
              width: baseSearchBoxWidth * scale,
              height: baseSearchBoxHeight * scale,
              controller: _searchController,
            ),
          ),

          // Checkbox "Chọn tất cả" và Box Printer
          // Box Chọn tất cả
          Positioned(
            top: 207 * scale,
            left: 20 * scale,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectAll = !_selectAll;
                      _updateAllOrdersSelection();
                    });
                  },
                  child: Container(
                    width: 20 * scale,
                    height: 20 * scale,
                    decoration: BoxDecoration(
                      color:
                          _selectAll ? const Color(0xFFFFDE7D) : Colors.white,
                      border: Border.all(
                        color: _selectAll
                            ? const Color(0xFFFFDE7D)
                            : const Color(0xFFAEAEAE),
                        width: 1 * scale,
                      ),
                      borderRadius: BorderRadius.circular(3 * scale),
                    ),
                    child: _selectAll
                        ? Icon(
                            Icons.check,
                            size: 16 * scale,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                SizedBox(width: 8 * scale),
                Text(
                  'Chọn tất cả',
                  style: TextStyle(
                    fontFamily: 'AlumniSans',
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Box printer
          Positioned(
            top: 207 * scale,
            left: 120 * scale,
            child: Container(
              width: 260 * scale,
              height: 20 * scale,
              decoration: BoxDecoration(
                color: isAnyOrderSelected
                    ? const Color(0xFFFFDE7D)
                    : const Color(0xFFF8F3D4),
                borderRadius: BorderRadius.circular(5 * scale),
                border: Border.all(
                  color: isAnyOrderSelected
                      ? const Color(0xFFFFDE7D)
                      : const Color(0xFFF8F3D4),
                  width: 1 * scale,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20 * scale,
                    height: 20 * scale,
                    child: SvgPicture.asset(
                      'assets/images/icons/printer_icon.svg',
                      colorFilter: ColorFilter.mode(
                        isAnyOrderSelected
                            ? Colors.black
                            : const Color(0xFFAEAEAE),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                  Text(
                    'In phiếu soạn hàng',
                    style: TextStyle(
                      fontFamily: 'AlumniSans',
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w900,
                      color: isAnyOrderSelected
                          ? Colors.black
                          : const Color(0xFFAEAEAE),
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Header cố định - height 100px, box thông báo sẽ overflow đè lên
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: false,
              child: SizedBox(
                height: baseHeaderHeight * scale, // Height cố định 100px
                child: OverflowBox(
                  maxHeight: double.infinity,
                  maxWidth: double.infinity,
                  alignment: Alignment.topLeft,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Box nền trắng 390x100
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
                      // Text "Soạn hàng" + orderType
                      Positioned(
                        left: baseTitleLeft * scale,
                        top: baseTitleTop * scale,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Soạn hàng ${widget.orderType}',
                            style: TextStyle(
                              fontFamily: 'AndadaPro',
                              fontSize: baseTitleFontSize * scale,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      // Icon back arrow
                      Positioned(
                        left: baseBackIconLeft * scale,
                        top: baseBackIconTop * scale,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                            width: baseBackIconWidth * scale,
                            height: baseBackIconHeight * scale,
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
                      // Box thông báo (overflow đè lên header, căn chỉnh với back_arrow)
                      Positioned(
                        left: baseNotificationBoxLeft * scale,
                        top: baseNotificationBoxTop * scale,
                        child: Container(
                          width: (baseNotificationBoxWidth * scale).clamp(
                              0.0,
                              screenWidth -
                                  (baseNotificationBoxLeft * 2 * scale)),
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
                              // Icon info (thay thế bell icon)
                              Positioned(
                                left: baseNotificationIconLeft * scale,
                                top: baseNotificationIconTop * scale,
                                child: SizedBox(
                                  width: baseNotificationIconSize * scale,
                                  height: baseNotificationIconSize * scale,
                                  child: SvgPicture.asset(
                                    'assets/images/icons/info_icon.svg',
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              // Text "Chưa có thông báo nào!"
                              Positioned(
                                left: baseNotificationTextLeft * scale,
                                top: baseNotificationTextTop * scale,
                                child: Text(
                                  'Chưa có thông báo nào!',
                                  style: TextStyle(
                                    fontFamily: 'AlumniSans',
                                    fontSize:
                                        baseNotificationTextFontSize * scale,
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
            ),
          ),
        ],
      ),
    );
  }

  // Widget date box
  Widget _buildDateBox({
    required BuildContext context,
    required double scale,
    required double width,
    required double height,
    required DateTime? date,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5 * scale),
          border: Border.all(
            color: const Color(0xFFAEAEAE),
            width: 1 * scale,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 5 * scale),
              child: SizedBox(
                width: 25 * scale,
                height: 25 * scale,
                child: SvgPicture.asset(
                  'assets/images/icons/calendar_icon.svg',
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5 * scale),
                child: Text(
                  date != null
                      ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                      : label,
                  style: TextStyle(
                    fontFamily: 'AlumniSans',
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w900, // Changed from w1000 to w900
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget dropdown box
  Widget _buildDropdownBox({
    required BuildContext context,
    required double scale,
    required double width,
    required double height,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5 * scale),
        border: Border.all(
          color: const Color(0xFFAEAEAE),
          width: 1 * scale,
        ),
      ),
      child: Row(
        children: [
          // Text dropdown căn trái
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8 * scale),
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                icon: const SizedBox.shrink(),
                style: TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w900, // Changed from w1000 to w900
                  color: Colors.black,
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontFamily: 'AlumniSans',
                        fontSize: 16 * scale,
                        fontWeight:
                            FontWeight.w900, // Changed from w1000 to w900
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          // Icon dropdown bên phải
          Padding(
            padding: EdgeInsets.only(right: 8 * scale),
            child: SizedBox(
              width: 20 * scale,
              height: 20 * scale,
              child: SvgPicture.asset(
                'assets/images/icons/dropdown_icon.svg',
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFFDE7D),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget search box
  Widget _buildSearchBox({
    required BuildContext context,
    required double scale,
    required double width,
    required double height,
    required TextEditingController controller,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5 * scale),
        border: Border.all(
          color: const Color(0xFFAEAEAE),
          width: 1 * scale,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(left: 8 * scale),
            child: SizedBox(
              width: 20 * scale,
              height: 20 * scale,
              child: SvgPicture.asset(
                'assets/images/icons/search_icon.svg',
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFFDE7D),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: controller,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w900, // Changed from w1000 to w900
                  height: 1,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(
                    left: 8 * scale,
                    right: 8 * scale,
                  ),
                  hintText: 'Tìm theo mã đơn hàng/ mã vận đơn/ ...',
                  hintStyle: TextStyle(
                    fontFamily: 'AlumniSans',
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w900, // Changed from w1000 to w900
                    color: const Color(0xFFAEAEAE),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 8 * scale),
            child: SizedBox(
              width: 25 * scale,
              height: 25 * scale,
              child: SvgPicture.asset(
                'assets/images/icons/grid_icon.svg',
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
      ..color = const Color(0xFFFFDE7D) // FFDE7D
      ..style = PaintingStyle.fill;

    // Use size if needed for painting

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
