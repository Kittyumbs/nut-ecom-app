import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nut_ecom_app/services/upload_service.dart';
import 'package:intl/intl.dart';

class TransactionsAddScreen extends StatefulWidget {
  const TransactionsAddScreen({super.key});

  @override
  State<TransactionsAddScreen> createState() => _TransactionsAddScreenState();
}

class _TransactionsAddScreenState extends State<TransactionsAddScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<XFile> _selectedImageFiles = []; // Lưu XFile cho cả web và mobile
  final List<Uint8List> _selectedImageBytes = []; // Lưu bytes cho web preview
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSaving = false;

  // Color palette from product_declaration_screen.dart
  final Color _primary = const Color(0xFFFFDE7D); // header stripe
  final Color _bg = const Color(0xFFF8F3D4); // background
  final Color _save = const Color(0xFFF6416C); // save button
  final Color _accent = const Color(0xFF00B8A9); // accent

  @override
  void dispose() {
    _amountController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedImageFiles.length >= 3) {
      showCupertinoDialog(
        context: context,
        builder: (_) => const CupertinoAlertDialog(
          title: Text('Đã đạt giới hạn'),
          content: Text('Bạn chỉ có thể upload tối đa 3 hình ảnh.'),
        ),
      );
      return;
    }

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // For web: read bytes for preview
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedImageFiles.add(pickedFile);
            _selectedImageBytes.add(bytes);
          });
        } else {
          // For mobile: just save XFile
          setState(() {
            _selectedImageFiles.add(pickedFile);
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Lỗi'),
          content: Text('Không thể chọn ảnh: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Đóng'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImageFiles.removeAt(index);
      if (kIsWeb && index < _selectedImageBytes.length) {
        _selectedImageBytes.removeAt(index);
      }
    });
  }

  Future<void> _onSave() async {
    if (_amountController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (_) => const CupertinoAlertDialog(
          title: Text('Thiếu thông tin'),
          content: Text('Vui lòng nhập Số tiền.'),
        ),
      );
      return;
    }
    if (_contentController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (_) => const CupertinoAlertDialog(
          title: Text('Thiếu thông tin'),
          content: Text('Vui lòng nhập Nội dung.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Parse số tiền
      final amountText = _amountController.text.trim();
      final isExpense = amountText.startsWith('-');
      final amountValue = double.tryParse(
        amountText.replaceAll(RegExp(r'[^\d.]'), ''),
      );

      if (amountValue == null) {
        throw Exception('Số tiền không hợp lệ');
      }

      final amount = isExpense ? -amountValue : amountValue;

      // Tạo date string theo format ddmmyy (VD: 161125)
      final now = DateTime.now();
      final dateStr = DateFormat('ddMMyy').format(now);

      // Upload ảnh lên Google Drive
      final List<String> imageUrls = [];
      final uploadService = UploadService();

      if (_selectedImageFiles.isNotEmpty) {
        final List<String> failedImages = [];
        
        for (int i = 0; i < _selectedImageFiles.length; i++) {
          try {
            print('Đang upload ảnh ${i + 1}/${_selectedImageFiles.length}...');
            String imageUrl;
            
            if (kIsWeb) {
              // For web: upload bytes
              final bytes = _selectedImageBytes[i];
              imageUrl = await uploadService.uploadTransactionImageBytes(
                bytes,
                fileName: 'transaction_${dateStr}_${i + 1}.jpg',
                dateStr: dateStr,
                imageNumber: (i + 1).toString(),
              );
            } else {
              // For mobile: upload File
              // ignore: undefined_class
              // File chỉ tồn tại trên mobile, không có trên web
              final file = File(_selectedImageFiles[i].path);
              imageUrl = await uploadService.uploadTransactionImage(
                file,
                dateStr: dateStr,
                imageNumber: (i + 1).toString(),
              );
            }
            
            print('Upload ảnh ${i + 1} thành công: $imageUrl');
            if (imageUrl.isNotEmpty) {
              imageUrls.add(imageUrl);
            } else {
              failedImages.add('Ảnh ${i + 1}');
              print('Warning: Upload ảnh ${i + 1} trả về URL rỗng');
            }
          } catch (e) {
            print('Lỗi upload ảnh ${i + 1}: $e');
            failedImages.add('Ảnh ${i + 1}');
            // Log lỗi nhưng tiếp tục upload các ảnh khác
          }
        }
        
        print('Tổng số ảnh đã upload thành công: ${imageUrls.length}/${_selectedImageFiles.length}');
        
        // Hiển thị cảnh báo nếu có ảnh upload thất bại
        if (failedImages.isNotEmpty && mounted) {
          // Không block UI, chỉ log warning
          print('Warning: ${failedImages.length} ảnh không upload được: ${failedImages.join(", ")}');
        }
      }

      // Lưu transaction vào Firestore
      final db = FirebaseFirestore.instance;
      final transactions = db.collection('transactions');

      await transactions.add({
        'amount': amount,
        'content': _contentController.text.trim(),
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'date': DateFormat('dd/MM/yyyy').format(now),
        'time': DateFormat('HH:mm:ss').format(now),
        'timestamp': now.toIso8601String(),
      });

      if (!mounted) return;

      // Hiển thị thông báo thành công và quay lại
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Thành công'),
          content: const Text('Đã lưu giao dịch thành công.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
                Navigator.pop(context); // Quay lại màn hình trước
              },
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Lỗi'),
          content: Text('Không thể lưu giao dịch:\n$e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Đóng'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: const Text('Tạo giao dịch mới'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(height: 4, color: _primary),
        ),
      ),
      body: Stack(
        children: [
          _buildForm(context),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabeledField(
              'Nhập số tiền',
              _buildAmountField(),
              requiredField: true,
            ),
            const SizedBox(height: 16),
            _buildLabeledField(
              'Nội dung',
              _buildContentField(),
              requiredField: true,
            ),
            const SizedBox(height: 16),
            _buildLabeledField(
              'Upload hình ảnh (tùy chọn)',
              _buildImageSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField(String label, Widget field,
      {bool requiredField = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87),
            ),
            if (requiredField)
              const Text(' *',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  Widget _buildAmountField() {
    return CupertinoTextField(
      controller: _amountController,
      placeholder: 'Nhập thêm dấu - nếu là khoản CHI',
      keyboardType: TextInputType.text, // Dùng text để có đầy đủ ký tự bao gồm dấu -
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      inputFormatters: [
        // Cho phép số, dấu chấm, dấu phẩy và dấu trừ ở đầu
        FilteringTextInputFormatter.allow(RegExp(r'^-?[\d.,]*')),
      ],
    );
  }

  Widget _buildContentField() {
    return CupertinoTextField(
      controller: _contentController,
      placeholder: 'Nhập nội dung giao dịch',
      maxLines: 4,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...List.generate(_selectedImageFiles.length, (index) {
              return _buildImageThumbnail(index);
            }),
            if (_selectedImageFiles.length < 3) _buildAddImageButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(int index) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb && index < _selectedImageBytes.length
                  ? Image.memory(
                      _selectedImageBytes[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, color: Colors.red),
                        );
                      },
                    )
                  : !kIsWeb && index < _selectedImageFiles.length
                      ? Builder(
                          builder: (context) {
                            // ignore: undefined_class
                            // File chỉ tồn tại trên mobile, không có trên web
                            final file = File(_selectedImageFiles[index].path);
                            return Image.file(
                              file,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error, color: Colors.red),
                                );
                              },
                            );
                          },
                        )
                      : const SizedBox(),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white),
                child: const Icon(Icons.close, size: 16),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo, size: 28, color: _accent),
              const SizedBox(height: 8),
              const Text('Thêm hình',
                  style: TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 18,
      child: CupertinoButton(
        color: _save,
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: BorderRadius.circular(12),
        onPressed: _isSaving ? null : _onSave,
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text('Lưu giao dịch',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
