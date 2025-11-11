import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:nut_ecom_app/services/upload_service.dart';

// ProductDeclarationScreen
// - Adapted from product_declare_demo/lib/product_declaration_ui.dart
// - Works inside existing Material app (no nested CupertinoApp)
// - Keeps Cupertino look-and-feel for form controls
class ProductDeclarationScreen extends StatefulWidget {
  final String? productId; // null = create, not null = edit
  const ProductDeclarationScreen({super.key, this.productId});

  @override
  State<ProductDeclarationScreen> createState() => _ProductDeclarationScreenState();
}

class _ProductDeclarationScreenState extends State<ProductDeclarationScreen> {
  // Basic product fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _generalPriceController = TextEditingController();
  final TextEditingController _generalLocationController = TextEditingController();
  static const double _titleFontSize = 16.0;

  // Single image
  File? _selectedImage; // null = no image (for mobile)
  Uint8List? _selectedImageBytes; // null = no image (for web)
  final ImagePicker _imagePicker = ImagePicker();

  // Classification groups
  final List<_ClassificationGroup> _classGroups = [];

  // SKU rows generated from classifications
  List<_SkuRow> _skuRows = [];

  // Color palette
  final Color _primary = const Color(0xFFFFDE7D); // header stripe
  final Color _bg = const Color(0xFFF8F3D4); // background
  final Color _save = const Color(0xFFF6416C); // save button
  final Color _accent = const Color(0xFF00B8A9); // accent

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _generalPriceController.text = '';
    _regenerateSkus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _generalPriceController.dispose();
    _generalLocationController.dispose();
    for (final g in _classGroups) {
      g.dispose();
    }
    for (final s in _skuRows) {
      s.dispose();
    }
    super.dispose();
  }

  // Image handlers
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // For web: read bytes
          final bytes = await pickedFile.readAsBytes();
          if (mounted) {
            setState(() {
              _selectedImageBytes = bytes;
              _selectedImage = null;
            });
          }
        } else {
          // For mobile: use File
          if (mounted) {
            setState(() {
              _selectedImage = File(pickedFile.path);
              _selectedImageBytes = null;
            });
          }
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

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _selectedImageBytes = null;
    });
  }

  bool get _hasImage => kIsWeb ? _selectedImageBytes != null : _selectedImage != null;

  // Classification handlers
  void _addClassificationGroup() {
    setState(() {
      _classGroups.add(_ClassificationGroup());
    });
  }

  void _removeClassificationGroup(int index) {
    setState(() {
      _classGroups[index].dispose();
      _classGroups.removeAt(index);
      _regenerateSkus();
    });
  }

  void _addValueToGroup(int groupIndex) {
    final group = _classGroups[groupIndex];
    final valueText = group.valueController.text.trim();
    if (valueText.isEmpty) return;
    setState(() {
      group.values.add(valueText);
      group.valueController.clear();
      _regenerateSkus();
    });
  }

  void _removeValueFromGroup(int groupIndex, int valueIndex) {
    setState(() {
      _classGroups[groupIndex].values.removeAt(valueIndex);
      _regenerateSkus();
    });
  }

  // Generate cartesian product of classification values -> sku rows
  void _regenerateSkus() {
    for (final r in _skuRows) {
      r.dispose();
    }
    final lists = _classGroups.map((g) => g.values).toList();
    if (lists.isEmpty || lists.any((l) => l.isEmpty)) {
      final priceCtrl = TextEditingController(text: _generalPriceController.text);
      final locCtrl = TextEditingController(text: _generalLocationController.text);
      _skuRows = [
        _SkuRow(
          combination: '—',
          sku: _formatSku(1),
          priceController: priceCtrl,
          locationController: locCtrl,
        )
      ];
      return;
    }
    final combos = _cartesianProduct(lists);
    final rows = <_SkuRow>[];
    int counter = 1;
    for (final combo in combos) {
      rows.add(_SkuRow(
        combination: combo.join(' / '),
        sku: _formatSku(counter),
        priceController: TextEditingController(),
        locationController: TextEditingController(),
      ));
      counter++;
    }
    _skuRows = rows;
  }

  String _formatSku(int n) => 'SKU' + n.toString().padLeft(3, '0');

  List<List<String>> _cartesianProduct(List<List<String>> lists) {
    if (lists.isEmpty) return [];
    List<List<String>> results = [[]];
    for (var list in lists) {
      final temp = <List<String>>[];
      for (var res in results) {
        for (var item in list) {
          temp.add([...res, item]);
        }
      }
      results = temp;
    }
    return results;
  }

  Future<void> _onSave() async {
    if (_isSaving) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (_) => const CupertinoAlertDialog(
          title: Text('Thiếu thông tin'),
          content: Text('Vui lòng nhập Tên sản phẩm.'),
        ),
      );
      return;
    }

    // Kiểm tra ảnh bắt buộc
    if (!_hasImage) {
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (_) => const CupertinoAlertDialog(
          title: Text('Thiếu thông tin'),
          content: Text('Vui lòng chọn hình sản phẩm.'),
        ),
      );
      return;
    }

    final hasClassGroups = _classGroups.isNotEmpty;
    final anyGroupIncomplete = _classGroups.any(
      (g) => g.titleController.text.trim().isEmpty || g.values.isEmpty,
    );
    if (hasClassGroups && anyGroupIncomplete) {
      showCupertinoDialog(
        context: context,
        builder: (_) => const CupertinoAlertDialog(
          title: Text('Lỗi'),
          content: Text('Nếu khai báo phân loại, phải nhập tên phân loại và ít nhất 1 giá trị cho mỗi phân loại.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Bước 1: Upload ảnh lên backend (backend sẽ upload lên Google Drive)
      String? imageUrl;
      if (_hasImage) {
        try {
          final uploadService = UploadService();
          
          // Upload ảnh lên backend
          if (kIsWeb && _selectedImageBytes != null) {
            // For web: upload bytes directly
            imageUrl = await uploadService.uploadImageBytes(
              _selectedImageBytes!,
              fileName: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
          } else if (!kIsWeb && _selectedImage != null) {
            // For mobile: upload File
            imageUrl = await uploadService.uploadImage(_selectedImage!);
          }
        } catch (e) {
          setState(() => _isSaving = false);
          if (!mounted) return;
          showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: const Text('Lỗi upload ảnh'),
              content: Text('Không thể upload ảnh:\n$e\n\nVui lòng kiểm tra:\n- Backend server đang chạy\n- URL backend đúng\n- Kết nối internet'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Đóng'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
          return;
        }
      }

      // Bước 2: Lưu vào Firestore với URL ảnh
      final payload = _buildPayload(imageUrl: imageUrl);
      final db = FirebaseFirestore.instance;
      final products = db.collection('products');

      if (widget.productId == null) {
        await products.add({
          ...payload,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await products.doc(widget.productId).set({
          ...payload,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      setState(() => _isSaving = false);
      if (!mounted) return;
      
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Thành công'),
          content: Text(widget.productId == null
              ? 'Đã tạo sản phẩm mới.'
              : 'Đã cập nhật sản phẩm.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context, true); // back to previous
              },
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Lỗi'),
          content: Text('Không thể lưu sản phẩm.\n$e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Đóng'),
              onPressed: () => Navigator.pop(context),
            )
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
        title: const Text('Khai báo sản phẩm'),
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
            _buildImageSection(),
            const SizedBox(height: 16),
            _buildLabeledField('Tên sản phẩm', _buildNameField(), requiredField: true),
            const SizedBox(height: 12),
            _buildClassificationsSection(),
            const SizedBox(height: 12),
            if (_classGroups.isEmpty) ...[
              _buildLabeledField('Giá bán', _buildGeneralPriceField(), requiredField: true),
              const SizedBox(height: 12),
              _buildLabeledField('Vị trí', _buildGeneralLocationField(), requiredField: true),
            ] else ...[
              _buildLabeledField('Giá/Vị trí theo phân loại', _buildSkuTable(), requiredField: true),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
              'Hình sản phẩm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: !_hasImage ? _pickImage : null,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: !_hasImage
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_a_photo, size: 28, color: _accent),
                        const SizedBox(height: 8),
                        const Text('Thêm hình sản phẩm', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb && _selectedImageBytes != null
                              ? Image.memory(
                                  _selectedImageBytes!,
                                  fit: BoxFit.cover,
                                )
                              : !kIsWeb && _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : const SizedBox(),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            child: const Icon(Icons.close, size: 18),
                          ),
                        ),
                      )
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField(String label, Widget field, {bool requiredField = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: _titleFontSize, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            if (requiredField)
              const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  Widget _buildNameField() {
    return CupertinoTextField(
      controller: _nameController,
      placeholder: 'Nhập tên sản phẩm',
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildGeneralPriceField() {
    return CupertinoTextField(
      controller: _generalPriceController,
      keyboardType: TextInputType.number,
      placeholder: 'VD: 250000',
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildGeneralLocationField() {
    return CupertinoTextField(
      controller: _generalLocationController,
      placeholder: 'VD: Kệ A1',
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      onChanged: (_) {
        // Keep the single SKU row synced when no classifications
        if (_classGroups.isEmpty && _skuRows.isNotEmpty) {
          _skuRows.first.locationController.text = _generalLocationController.text;
        }
      },
    );
  }

  Widget _buildClassificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phân loại sản phẩm (tùy chọn)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black87)),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _classGroups.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final group = _classGroups[index];
            return _buildClassGroupCard(index, group);
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CupertinoButton(
              color: Color(0xFF00B8A9),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: const Text('+ Thêm phân loại', style: TextStyle(color: Colors.white)),
              onPressed: _addClassificationGroup,
            ),
            const SizedBox(width: 12),
            const Flexible(child: Text('Note: Nếu không có phân loại, nhập giá bán và vị trí chung', style: TextStyle(color: Colors.black54))),
          ],
        ),
      ],
    );
  }

  Widget _buildClassGroupCard(int index, _ClassificationGroup group) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: group.titleController,
                  placeholder: 'Tên phân loại (VD: Màu sắc)',
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _removeClassificationGroup(index),
                child: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
              )
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < group.values.length; i++)
                _buildChip(group.values[i], () => _removeValueFromGroup(index, i)),
              SizedBox(
                width: 180,
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: group.valueController,
                        placeholder: 'Thêm giá trị (VD: Đỏ)',
                        onSubmitted: (_) => _addValueToGroup(index),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      onPressed: () => _addValueToGroup(index),
                      child: const Icon(CupertinoIcons.add, color: Colors.redAccent),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          GestureDetector(onTap: onRemove, child: const Icon(CupertinoIcons.clear_circled_solid, size: 18, color: Colors.black38)),
        ],
      ),
    );
  }

  Widget _buildSkuTable() {
    if (_skuRows.isEmpty) _regenerateSkus();
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          for (final row in _skuRows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(flex: 4, child: Text(row.combination, style: const TextStyle(fontSize: 13))),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: CupertinoTextField(
                      controller: row.priceController,
                      placeholder: 'Giá (VD: 250000)',
                      keyboardType: TextInputType.number,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: CupertinoTextField(
                      controller: row.locationController,
                      placeholder: 'Vị trí (VD: Kệ A1)',
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    ),
                  ),
                ],
              ),
            ),
        ],
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
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Lưu sản phẩm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: _isSaving ? null : _onSave,
      ),
    );
  }
}

// Internal helper classes (private to this screen)
class _ClassificationGroup {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final List<String> values = [];

  void dispose() {
    titleController.dispose();
    valueController.dispose();
  }
}

class _SkuRow {
  final String combination;
  final String sku;
  final TextEditingController priceController;
  final TextEditingController locationController;

  _SkuRow({
    required this.combination,
    required this.sku,
    required this.priceController,
    required this.locationController,
  });

  void dispose() {
    priceController.dispose();
    locationController.dispose();
  }
}

Map<String, dynamic> _buildClassificationGroupMap(_ClassificationGroup g) {
  return {
    'title': g.titleController.text.trim(),
    'values': g.values,
  };
}

extension on _ProductDeclarationScreenState {
  Map<String, dynamic> _buildPayload({String? imageUrl}) {
    return {
      'name': _nameController.text.trim(),
      'imageUrl': imageUrl, // URL ảnh từ Google Drive
      'hasClassifications': _classGroups.isNotEmpty,
      'generalPrice': _classGroups.isEmpty ? _generalPriceController.text.trim() : null,
      'generalLocation': _classGroups.isEmpty ? _generalLocationController.text.trim() : null,
      'classifications': _classGroups.map(_buildClassificationGroupMap).toList(),
      'skus': _skuRows
          .map((s) => {
                'combination': s.combination,
                'sku': s.sku,
                'price': s.priceController.text.trim(),
                'location': s.locationController.text.trim(),
              })
          .toList(),
    };
  }
}


