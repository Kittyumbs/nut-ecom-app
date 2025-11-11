import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class TransactionsAddScreen extends StatefulWidget {
  const TransactionsAddScreen({super.key});

  @override
  State<TransactionsAddScreen> createState() => _TransactionsAddScreenState();
}

class _TransactionsAddScreenState extends State<TransactionsAddScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<File> _selectedImages = [];
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
    if (_selectedImages.length >= 3) {
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
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
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
    // --- TODO: Implement saving logic ---
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
    setState(() => _isSaving = false);
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
      body: Column(
        children: [
          Expanded(
            child: _buildForm(context),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
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
            ..._selectedImages.asMap().entries.map((entry) {
              int index = entry.key;
              File image = entry.value;
              return _buildImageThumbnail(image, index);
            }),
            if (_selectedImages.length < 3) _buildAddImageButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(File image, int index) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(image, fit: BoxFit.cover),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
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
