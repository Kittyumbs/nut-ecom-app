import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/handover_details_modal.dart';
import 'main_screen.dart';
import 'scan_screen.dart';

// Enum for delivery partners
enum DeliveryPartner {
  SPX,
  JT,
  LAZADA,
  TIKI,
}

// Enum for handover status
enum HandoverStatus {
  CHUA_BAN_GIAO,
  DA_BAN_GIAO,
}

// Enum for order type
enum OrderType {
  THUONG,
  HOA_TOC,
}

// HandoverCard class
class HandoverCard {
  final String id;
  final DeliveryPartner partner;
  final DateTime creationTime;
  final HandoverStatus status;
  final OrderType type;

  HandoverCard({
    required this.id,
    required this.partner,
    required this.creationTime,
    required this.status,
    required this.type,
  });
}

class HandoverScreen extends StatefulWidget {
  const HandoverScreen({
    super.key,
  });

  @override
  State<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends State<HandoverScreen> {
  // State for dropdowns
  String? _selectedChannel = 'Tất cả các kênh';
  String? _selectedStatus = 'Tất cả trạng thái';

  // State for date pickers
  DateTime? _startDate = DateTime(2025, 1, 1);
  DateTime? _endDate = DateTime(2025, 1, 30);

  // State for search
  final TextEditingController _searchController = TextEditingController();

  // Mock data for handover cards
  final List<HandoverCard> _handoverCards = [
    HandoverCard(
      id: 'BG123456789',
      partner: DeliveryPartner.SPX,
      creationTime: DateTime.now(),
      status: HandoverStatus.CHUA_BAN_GIAO,
      type: OrderType.THUONG,
    ),
    HandoverCard(
      id: 'BG987654321',
      partner: DeliveryPartner.JT,
      creationTime: DateTime.now().subtract(const Duration(hours: 1)),
      status: HandoverStatus.DA_BAN_GIAO,
      type: OrderType.HOA_TOC,
    ),
    HandoverCard(
      id: 'BG456789123',
      partner: DeliveryPartner.LAZADA,
      creationTime: DateTime.now().subtract(const Duration(hours: 2)),
      status: HandoverStatus.CHUA_BAN_GIAO,
      type: OrderType.THUONG,
    ),
  ];

  String _getStatusText(HandoverStatus status) {
    switch (status) {
      case HandoverStatus.CHUA_BAN_GIAO:
        return 'Chưa bàn giao';
      case HandoverStatus.DA_BAN_GIAO:
        return 'Đã bàn giao';
    }
  }

  String _getTypeText(OrderType type) {
    switch (type) {
      case OrderType.THUONG:
        return 'Thường';
      case OrderType.HOA_TOC:
        return 'Hỏa tốc';
    }
  }

  Color _getTypeColor(OrderType type) {
    switch (type) {
      case OrderType.THUONG:
        return Colors.blue;
      case OrderType.HOA_TOC:
        return Colors.red;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Scale factor based on 390x844 screen
  double _getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / 390.0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = _getScaleFactor(context);

    // Base dimensions from design 390x844
    const baseHeaderHeight = 100.0;
    const baseTitleTop = 35.0;
    const baseTitleLeft = 25.0;
    const baseTitleFontSize = 20.0;
    const baseBackIconWidth = 25.0;
    const baseBackIconHeight = 35.0;
    const baseBackIconTop = 32.0;
    const baseBackIconLeft = 6.0;
    const baseNotificationBoxWidth = 350.0;
    const baseNotificationBoxHeight = 30.0;
    const baseNotificationBoxLeft = 20.0;
    const baseNotificationBoxTop = 67.0;
    const baseNotificationIconSize = 22.0;
    const baseNotificationIconLeft = 3.0;
    const baseNotificationIconTop = 4.0;
    const baseNotificationTextLeft = 29.0;
    const baseNotificationTextTop = 8.0;
    const baseNotificationTextFontSize = 12.0;

    const baseDateBoxTop = 105.0;
    const baseDateBoxLeft = 10.0;
    const baseDateBoxWidth = 175.0;
    const baseDateBoxHeight = 30.0;
    const baseDateBoxGap = 20.0;
    const baseArrowIconSize = 16.0;

    const baseDropdownTop = 139.0;
    const baseDropdownLeft = 10.0;
    const baseDropdownWidth = 180.0;
    const baseDropdownHeight = 30.0;
    const baseDropdownGap = 10.0;

    const baseSearchBoxTop = 173.0;
    const baseSearchBoxLeft = 10.0;
    const baseSearchBoxWidth = 370.0;
    const baseSearchBoxHeight = 30.0;

    const baseListTop = baseSearchBoxTop + baseSearchBoxHeight + 10.0;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(initialIndex: index),
              ),
              (route) => false,
            );
          }
        },
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // ListView for handover cards
          Positioned(
            top: baseListTop * scale,
            left: 10 * scale,
            right: 10 * scale,
            bottom: 0,
            child: ListView.builder(
              itemCount: _handoverCards.length,
              itemBuilder: (context, index) {
                final card = _handoverCards[index];
                return _buildHandoverCard(context, scale, card);
              },
            ),
          ),

          // 2 box date picker
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
          // Icon arrow between date boxes
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
                colorFilter: const ColorFilter.mode(
                  Color(0xFF00B8A9),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          // Box date to
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

          // 2 dropdown boxes
          Positioned(
            top: baseDropdownTop * scale,
            left: baseDropdownLeft * scale,
            child: _buildDropdownBox(
              context: context,
              scale: scale,
              width: baseDropdownWidth * scale,
              height: baseDropdownHeight * scale,
              value: _selectedChannel,
              items: ['Tất cả các kênh', 'Thường', 'Hỏa tốc'],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedChannel = newValue;
                });
              },
            ),
          ),
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
                'Chưa bàn giao',
                'Đã bàn giao',
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue;
                });
              },
            ),
          ),

          // Search box
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

          // Fixed Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: false,
              child: SizedBox(
                height: baseHeaderHeight * scale,
                child: OverflowBox(
                  maxHeight: double.infinity,
                  maxWidth: double.infinity,
                  alignment: Alignment.topLeft,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: screenWidth,
                        height: baseHeaderHeight * scale,
                        color: Colors.white,
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: baseHeaderHeight * scale,
                        child: CustomPaint(
                          painter: TrianglePainter(scale: scale),
                        ),
                      ),
                      Positioned(
                        left: baseTitleLeft * scale,
                        top: baseTitleTop * scale,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Bàn giao HÀNG HÓA',
                            style: TextStyle(
                              fontFamily: 'AndadaPro',
                              fontSize: baseTitleFontSize * scale,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
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
                                Color(0xFF000000),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
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
                              Positioned(
                                left: baseNotificationIconLeft * scale,
                                top: baseNotificationIconTop * scale,
                                child: SizedBox(
                                  width: baseNotificationIconSize * scale,
                                  height: baseNotificationIconSize * scale,
                                  child: SvgPicture.asset(
                                    'assets/images/icons/info_icon.svg',
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFF00B8A9),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
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

          // Floating Action Buttons
          Positioned(
            bottom: 10 * scale,
            left: 10 * scale,
            right: 10 * scale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFloatingActionButton(
                  scale: scale,
                  text: 'Tạo biên bản trả hàng',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanScreen(),
                      ),
                    );
                  },
                ),
                _buildFloatingActionButton(
                  scale: scale,
                  text: 'Tạo đợt bàn giao',
                  onPressed: () async {
                    final List<String>? scannedCodes =
                        await Navigator.push<List<String>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanScreen(),
                      ),
                    );

                    if (scannedCodes != null && scannedCodes.isNotEmpty) {
                      // Mock data for the new handover
                      final newHandoverId =
                          'BG${DateTime.now().millisecondsSinceEpoch}';
                      final newHandoverCard = HandoverCard(
                        id: newHandoverId,
                        partner: DeliveryPartner.SPX, // Mock partner
                        creationTime: DateTime.now(),
                        status: HandoverStatus.CHUA_BAN_GIAO,
                        type: OrderType.THUONG, // Mock type
                      );

                      setState(() {
                        _handoverCards.insert(0, newHandoverCard);
                      });

                      // Create details object for the modal
                      final newHandoverDetails = HandoverDetails(
                        handoverId: newHandoverId,
                        totalOrders: scannedCodes.length,
                        shippingPartner:
                            newHandoverCard.partner.toString().split('.').last,
                        channel: _getTypeText(newHandoverCard.type),
                        status: _getStatusText(newHandoverCard.status),
                      );

                      // Show the details modal
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => HandoverDetailsModal(
                          details: newHandoverDetails,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandoverCard(
      BuildContext context, double scale, HandoverCard card) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10 * scale),
      child: Ink(
        width: 360 * scale,
        height: 60 * scale,
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
        child: InkWell(
          borderRadius: BorderRadius.circular(8 * scale),
          onTap: () {
            // Create details object from the card
            final details = HandoverDetails(
              handoverId: card.id,
              totalOrders: 15, // Mock total orders for existing cards
              shippingPartner: card.partner.toString().split('.').last,
              channel: _getTypeText(card.type),
              status: _getStatusText(card.status),
            );
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => HandoverDetailsModal(
                details: details,
              ),
            );
          },
          child: Row(
            children: [
              SizedBox(width: 15 * scale),
              // Card details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          card.id,
                          style: TextStyle(
                            fontFamily: 'Anaheim',
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6 * scale,
                            vertical: 2 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(card.type),
                            borderRadius: BorderRadius.circular(4 * scale),
                          ),
                          child: Text(
                            _getTypeText(card.type),
                            style: TextStyle(
                              fontFamily: 'Anaheim',
                              fontSize: 10 * scale,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Thời gian tạo: ${DateFormat('HH:mm:ss').format(card.creationTime)}',
                      style: TextStyle(
                        fontFamily: 'Anaheim',
                        fontSize: 12 * scale,
                        color: const Color(0xFFAEAEAE),
                      ),
                    ),
                  ],
                ),
              ),
              // Partner and status indicators
              Padding(
                padding: EdgeInsets.only(right: 10 * scale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * scale,
                        vertical: 4 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B8A9),
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                      child: Text(
                        card.partner.toString().split('.').last,
                        style: TextStyle(
                          fontFamily: 'Anaheim',
                          fontSize: 12 * scale,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      _getStatusText(card.status),
                      style: TextStyle(
                        fontFamily: 'Anaheim',
                        fontSize: 12 * scale,
                        color: card.status == HandoverStatus.DA_BAN_GIAO
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF00B8A9),
                    BlendMode.srcIn,
                  ),
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
                    fontWeight: FontWeight.w900,
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
                  fontWeight: FontWeight.w900,
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
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8 * scale),
            child: SizedBox(
              width: 25 * scale,
              height: 25 * scale,
              child: SvgPicture.asset(
                'assets/images/icons/dropdown_icon.svg',
                colorFilter: const ColorFilter.mode(
                  Color(0xFF00B8A9),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                  Color(0xFF00B8A9),
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
                  fontWeight: FontWeight.w900,
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
                    fontWeight: FontWeight.w900,
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
              width: 20 * scale,
              height: 20 * scale,
              child: SvgPicture.asset(
                'assets/images/icons/grid_icon.svg',
                colorFilter: const ColorFilter.mode(
                  Color(0xFF00B8A9),
                  BlendMode.srcIn,
                ),
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
      ..color = const Color(0xFF00B8A9).withOpacity(0.5)
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

Widget _buildFloatingActionButton({
  required double scale,
  required String text,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: 180 * scale,
    height: 35 * scale,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00B8A9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5 * scale),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Anaheim',
          fontSize: 18 * scale,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    ),
  );
}
