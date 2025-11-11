import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Mock data class for handover details
class HandoverDetails {
  final String handoverId;
  final int totalOrders;
  final String shippingPartner;
  final String channel;
  final String status;

  HandoverDetails({
    required this.handoverId,
    required this.totalOrders,
    required this.shippingPartner,
    required this.channel,
    required this.status,
  });
}

class HandoverDetailsModal extends StatefulWidget {
  final HandoverDetails details;

  HandoverDetailsModal({
    super.key,
    required this.details,
  });

  @override
  State<HandoverDetailsModal> createState() => _HandoverDetailsModalState();
}

class _HandoverDetailsModalState extends State<HandoverDetailsModal> {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chỉ có thể chọn tối đa 3 hình ảnh.')),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 390.0;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.67,
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
              'ĐỢIT BÀN GIAO (#${widget.details.handoverId})',
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
              'Số lượng đơn: ${widget.details.totalOrders}',
              style: TextStyle(
                fontSize: 16 * scale,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Handover details
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(scale, 'Đơn vị vận chuyển:',
                    widget.details.shippingPartner),
                _buildDetailRow(scale, 'Kênh:', widget.details.channel),
                _buildDetailRow(
                    scale, 'Trạng thái bàn giao:', widget.details.status),
              ],
            ),
          ),
          SizedBox(height: 16 * scale),
          // Image upload section
          _buildImageUploadSection(scale),
          const Spacer(),
          // Action buttons
          _buildActionButtons(scale),
        ],
      ),
    );
  }

  Widget _buildDetailRow(double scale, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16 * scale,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hình ảnh (không bắt buộc, tối đa 3 tấm):',
            style: TextStyle(
              fontSize: 16 * scale,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8 * scale),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._images.asMap().entries.map((entry) {
                  int idx = entry.key;
                  File image = entry.value;
                  return Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8 * scale),
                        width: 80 * scale,
                        height: 80 * scale,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8 * scale),
                          image: DecorationImage(
                            image: FileImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 8 * scale,
                        child: GestureDetector(
                          onTap: () => _removeImage(idx),
                          child: Container(
                            padding: EdgeInsets.all(2 * scale),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14 * scale,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                if (_images.length < 3)
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 80 * scale,
                      height: 80 * scale,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8 * scale),
                        border: Border.all(
                          color: Colors.grey[400]!,
                          style: BorderStyle.solid,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.add_a_photo,
                        color: Colors.grey[600],
                        size: 30 * scale,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double scale) {
    return Padding(
      padding: EdgeInsets.all(16 * scale),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Handle "IN BIÊN BẢN BÀN GIAO"
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B8A9),
                padding: EdgeInsets.symmetric(vertical: 16 * scale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
              ),
              child: Text(
                'IN BIÊN BẢN BÀN GIAO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const HandoverConfirmationDialog(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B8A9),
                padding: EdgeInsets.symmetric(vertical: 16 * scale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
              ),
              child: Text(
                'XÁC NHẬN BÀN GIAO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HandoverConfirmationDialog extends StatelessWidget {
  const HandoverConfirmationDialog({super.key});

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
              'XÁC NHẬN?',
              style: TextStyle(
                fontSize: 18 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16 * scale),
            Text(
              'Lưu ý: Thao tác này không thể hoàn tác. Sau khi bàn giao sẽ không cập nhật được hình ảnh + in biên bản ban giao.',
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
                    Navigator.pop(context); // Close dialog
                  },
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      fontSize: 18 * scale,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close bottom sheet
                    // TODO: Add logic for handover confirmation
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B8A9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                  ),
                  child: Text(
                    'Xác nhận',
                    style: TextStyle(
                      fontSize: 18 * scale,
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
