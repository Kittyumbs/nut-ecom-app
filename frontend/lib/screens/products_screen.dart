import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/app_header.dart';
import 'product_declaration_screen.dart';

class Product {
  final String name;
  final String price;
  final String category;
  final String imageUrl;
  final String sku;
  final String location;

  Product({
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.sku,
    required this.location,
  });
}

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // Mock data for filters
  final List<String> _allCategories = [
    'Áo Thun',
    'Quần Jean',
    'Váy',
    'Giày Sneaker'
  ];
  final List<String> _allPrices = [
    'Dưới 100k',
    '100k - 200k',
    '200k - 500k',
    'Trên 500k'
  ];

  // Mock product data
  late final List<Product> _allProducts;

  // State for selected filters
  List<String> _selectedCategories = [];
  List<String> _selectedPrices = [];

  // State for sorting
  bool _isSortAscending = true;

  // Search
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Keys for positioning the popover
  final GlobalKey _categoriesKey = GlobalKey();
  final GlobalKey _pricesKey = GlobalKey();

  // Overlay entry for the popover
  OverlayEntry? _overlayEntry;

  // Scale factor
  double _getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / 390.0;
  }

  @override
  void initState() {
    super.initState();
    _allProducts = List.generate(
      20,
      (index) => Product(
        name: 'Sản phẩm ${index + 1}',
        price: '${(index + 1) * 50}k',
        category: ['Áo Thun', 'Quần Jean', 'Váy', 'Giày Sneaker'][index % 4],
        imageUrl: 'https://via.placeholder.com/150',
        sku: 'SKU${(index + 1).toString().padLeft(4, '0')}',
        location: 'Kệ A${(index % 5) + 1}',
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay(); // Ensure overlay is removed when screen is disposed
    _searchController.dispose();
    super.dispose();
  }

  // Method to remove the overlay and finalize selection
  void _removeOverlay({
    List<String>? finalSelection,
    ValueChanged<List<String>>? onSelectionChanged,
  }) {
    if (finalSelection != null && onSelectionChanged != null) {
      // Use setState here to update the UI with the final selection
      setState(() {
        onSelectionChanged(finalSelection);
      });
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Method to show the popover overlay
  void _showOverlay({
    required BuildContext context,
    required GlobalKey buttonKey,
    required List<String> allItems,
    required List<String> selectedItems,
    required ValueChanged<List<String>> onSelectionChanged,
  }) {
    // If an overlay is already showing, remove it.
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }

    final RenderBox renderBox =
        buttonKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final scale = _getScaleFactor(context);

    List<String> tempSelectedItems = List.from(selectedItems);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          onTap: () => _removeOverlay(
            finalSelection: tempSelectedItems,
            onSelectionChanged: onSelectionChanged,
          ), // Tap outside to close and save
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Positioned(
                top: offset.dy + size.height,
                left: offset.dx,
                width: size.width,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(5 * scale),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 200 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5 * scale),
                      border: Border.all(color: const Color(0xFFAEAEAE)),
                    ),
                    child: StatefulBuilder(
                      builder:
                          (BuildContext context, StateSetter listSetState) {
                        return ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: allItems.map((item) {
                            return CheckboxListTile(
                              value: tempSelectedItems.contains(item),
                              title: Text(item,
                                  style: TextStyle(fontSize: 14 * scale)),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              onChanged: (bool? value) {
                                listSetState(() {
                                  if (value == true) {
                                    tempSelectedItems.add(item);
                                  } else {
                                    tempSelectedItems.remove(item);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _getScaleFactor(context);
    final headerHeight = 100.0 * scale;
    final List<Product> visibleProducts = _getVisibleProducts();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content area
          Padding(
            padding: EdgeInsets.only(top: headerHeight),
            child: Column(
              children: [
                SizedBox(height: 10 * scale), // Khoảng cách 10px từ header
                // Search bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                  child: Container(
                    height: 30 * scale,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5 * scale),
                      border: Border.all(color: const Color(0xFFAEAEAE)),
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
                                Color(0xFF000000),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: _searchController,
                              textAlignVertical: TextAlignVertical.center,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
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
                                hintText: 'Tìm theo tên/ SKU ...',
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
                                Color(0xFF000000),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8 * scale),
                // Filter and Sort section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMultiSelectDropdown(
                          key: _categoriesKey,
                          context: context,
                          scale: scale,
                          label: 'Tất cả phân loại',
                          allItems: _allCategories,
                          selectedItems: _selectedCategories,
                          onSelectionChanged: (selected) {
                            _selectedCategories = selected;
                          },
                        ),
                      ),
                      SizedBox(width: 10 * scale),
                      Expanded(
                        child: _buildMultiSelectDropdown(
                          key: _pricesKey,
                          context: context,
                          scale: scale,
                          label: 'Tất cả giá bán',
                          allItems: _allPrices,
                          selectedItems: _selectedPrices,
                          onSelectionChanged: (selected) {
                            _selectedPrices = selected;
                          },
                        ),
                      ),
                      SizedBox(width: 10 * scale),
                      _buildSortIcon(scale),
                    ],
                  ),
                ),
                // Product list
                Expanded(
                  child: Stack(
                    children: [
                      ListView.builder(
                        itemCount: visibleProducts.length,
                        itemBuilder: (context, index) {
                          final product = visibleProducts[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10 * scale, vertical: 5 * scale),
                            child: Padding(
                              padding: EdgeInsets.all(8 * scale),
                              child: Row(
                                children: [
                                  _buildImagePlaceholder(scale),
                                  SizedBox(width: 10 * scale),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: TextStyle(
                                            fontSize: 16 * scale,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Giá: ${product.price}',
                                          style:
                                              TextStyle(fontSize: 14 * scale),
                                        ),
                                        Text(
                                          'Phân loại: ${product.category}',
                                          style:
                                              TextStyle(fontSize: 14 * scale),
                                        ),
                                        Text(
                                          'SKU: ${product.sku} • Vị trí: ${product.location}',
                                          style: TextStyle(
                                            fontSize: 12 * scale,
                                            color: const Color(0xFF9CA3AF),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8 * scale),
                                  SizedBox(
                                    width: 20 * scale,
                                    height: 20 * scale,
                                    child: SvgPicture.asset(
                                      'assets/images/icons/search_order_icon.svg',
                                      colorFilter: const ColorFilter.mode(
                                        Color(0xFF000000),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Progressive fade at bottom (non-blocking)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 60 * scale,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.white,
                                  Colors.white.withOpacity(0.0),
                                ],
                                stops: const [0.0, 1.0],
                              ),
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
          // Fixed Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: false,
              child: SizedBox(
                height: headerHeight,
                child: const OverflowBox(
                  maxHeight: double.infinity,
                  maxWidth: double.infinity,
                  alignment: Alignment.topLeft,
                  child: AppHeader(
                    title: 'Quản lý SẢN PHẨM',
                    showVersion: false,
                  ),
                ),
              ),
            ),
          ),
          // Floating Action Button: add product declaration
          Positioned(
            right: 16,
            bottom: 16,
            child: SizedBox(
              width: 56,
              height: 56,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProductDeclarationScreen(),
                    ),
                  );
                },
                backgroundColor: const Color(0xFF00B8A9),
                elevation: 3,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build visible products based on selected filters and sort order
  List<Product> _getVisibleProducts() {
    List<Product> products = List<Product>.from(_allProducts);

    // Search by name or SKU
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.sku.toLowerCase().contains(q))
          .toList();
    }

    // Filter by categories
    if (_selectedCategories.isNotEmpty) {
      products = products
          .where((p) => _selectedCategories.contains(p.category))
          .toList();
    }

    // Filter by price ranges
    if (_selectedPrices.isNotEmpty) {
      products = products.where((p) {
        final price = _parsePriceK(p.price); // e.g., '150k' -> 150
        return _selectedPrices.any((range) => _matchPriceRange(price, range));
      }).toList();
    }

    // Sort by price ascending/descending
    products.sort((a, b) {
      final pa = _parsePriceK(a.price);
      final pb = _parsePriceK(b.price);
      return _isSortAscending ? pa.compareTo(pb) : pb.compareTo(pa);
    });

    return products;
  }

  int _parsePriceK(String priceText) {
    final cleaned = priceText.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return 0;
    return int.tryParse(cleaned) ?? 0;
  }

  bool _matchPriceRange(int priceK, String label) {
    switch (label) {
      case 'Dưới 100k':
        return priceK < 100;
      case '100k - 200k':
        return priceK >= 100 && priceK <= 200;
      case '200k - 500k':
        return priceK >= 200 && priceK <= 500;
      case 'Trên 500k':
        return priceK > 500;
      default:
        return true;
    }
  }

  // Simple image placeholder box with text
  Widget _buildImagePlaceholder(double scale) {
    return Container(
      width: 80 * scale,
      height: 80 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        'Ảnh',
        style: TextStyle(
          fontSize: 14 * scale,
          color: const Color(0xFF9CA3AF),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMultiSelectDropdown({
    required Key key,
    required BuildContext context,
    required double scale,
    required String label,
    required List<String> allItems,
    required List<String> selectedItems,
    required ValueChanged<List<String>> onSelectionChanged,
  }) {
    return GestureDetector(
      key: key,
      onTap: () {
        _showOverlay(
          context: context,
          buttonKey: key as GlobalKey,
          allItems: allItems,
          selectedItems: selectedItems,
          onSelectionChanged: onSelectionChanged,
        );
      },
      child: Container(
        height: 30 * scale,
        padding: EdgeInsets.symmetric(horizontal: 8 * scale),
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
              child: Text(
                selectedItems.isEmpty ? label : selectedItems.join(', '),
                style: TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
                softWrap: false,
              ),
            ),
            SizedBox(
              width: 25 * scale,
              height: 25 * scale,
              child: SvgPicture.asset(
                'assets/images/icons/dropdown_icon.svg',
                colorFilter: const ColorFilter.mode(
                  Color(0xFF000000),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortIcon(double scale) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSortAscending = !_isSortAscending;
        });
      },
      child: Container(
        width: 30 * scale,
        height: 30 * scale,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5 * scale),
          border: Border.all(
            color: const Color(0xFFAEAEAE),
            width: 1 * scale,
          ),
        ),
        child: Icon(
          _isSortAscending ? Icons.sort_by_alpha : Icons.sort,
          size: 20 * scale,
          color: const Color(0xFF000000),
        ),
      ),
    );
  }
}
