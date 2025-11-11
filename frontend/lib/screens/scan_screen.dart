import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  final bool isSingleScanMode;

  const ScanScreen({super.key, this.isSingleScanMode = false});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late MobileScannerController _scannerController;
  final TextEditingController _manualInputController = TextEditingController();
  final List<String> _scannedCodes = [];
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      formats: [
        BarcodeFormat.qrCode,
        BarcodeFormat.code128,
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        BarcodeFormat.itf,
      ],
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _scannerController.toggleTorch();
  }

  void _addScannedCode(String code) {
    if (code.isNotEmpty && !_scannedCodes.contains(code)) {
      setState(() {
        _scannedCodes.add(code);
      });
    }
  }

  void _handleManualInput() {
    final String code = _manualInputController.text;
    if (code.isNotEmpty) {
      if (widget.isSingleScanMode) {
        Navigator.pop(context, code);
      } else {
        _addScannedCode(code);
        _manualInputController.clear();
      }
    }
  }

  void _removeScannedCode(int index) {
    setState(() {
      _scannedCodes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 390.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        centerTitle: true,
        title: Text(
          'Quét Mã SP/ĐH/VĐ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_off : Icons.flash_on,
              color: Colors.white,
              size: 24 * scale,
            ),
            onPressed: _toggleFlash,
          ),
        ],
        leading: Container(), // Hides the default back button
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Scanner Area
              SizedBox(
                width: screenWidth,
                height: screenWidth, // Make it square
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final String code = barcodes.first.rawValue ?? '---';
                          if (widget.isSingleScanMode) {
                            if (code.isNotEmpty) {
                              Navigator.pop(context, code);
                            }
                          } else {
                            _addScannedCode(code);
                          }
                        }
                      },
                    ),
                    // This is the overlay
                    Center(
                      child: SizedBox(
                        width: 250 * scale,
                        height: 250 * scale,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Manual Input and Scanned Codes List
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  color: const Color(0xFF1A1A2E),
                  child: Column(
                    children: [
                      SizedBox(height: 15 * scale),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _manualInputController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Nhập mã thủ công...',
                                hintStyle:
                                    const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: const Color(0xFF2A2A3E),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(10 * scale),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15 * scale,
                                  vertical: 12 * scale,
                                ),
                              ),
                              onSubmitted: (_) => _handleManualInput(),
                            ),
                          ),
                          SizedBox(width: 4 * scale),
                          GestureDetector(
                            onTap: _handleManualInput,
                            child: Container(
                              width: 38 * scale,
                              height: 38 * scale,
                              decoration: BoxDecoration(
                                color: Colors.pinkAccent,
                                borderRadius: BorderRadius.circular(10 * scale),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Scanned codes list (Conditional)
                      if (!widget.isSingleScanMode)
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(height: 15 * scale),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Số lượng: ${_scannedCodes.length}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8 * scale),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _scannedCodes.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin:
                                          EdgeInsets.only(bottom: 8 * scale),
                                      padding: EdgeInsets.all(12 * scale),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2A2A3E),
                                        borderRadius:
                                            BorderRadius.circular(8 * scale),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _scannedCodes[index],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14 * scale,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                              size: 20 * scale,
                                            ),
                                            onPressed: () =>
                                                _removeScannedCode(index),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                  height:
                                      80 * scale), // Space for floating buttons
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Floating Action Buttons
          Positioned(
            bottom: 20 * scale,
            left: 0,
            right: 0,
            child: widget.isSingleScanMode
                ? Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 60 * scale,
                        height: 60 * scale,
                        decoration: const BoxDecoration(
                          color: Colors.pinkAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30 * scale,
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 60 * scale,
                          height: 60 * scale,
                          decoration: const BoxDecoration(
                            color: Colors.pinkAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30 * scale,
                          ),
                        ),
                      ),
                      SizedBox(width: 20 * scale),
                      GestureDetector(
                        onTap: () {
                          // TODO: Add confirmation logic and pop with results
                          Navigator.pop(context, _scannedCodes);
                        },
                        child: Container(
                          width: 60 * scale,
                          height: 60 * scale,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
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
}
