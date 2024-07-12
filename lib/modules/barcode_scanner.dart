  import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  final Function(String) onScanResult;

  const BarcodeScanner({super.key, required this.onScanResult});

  @override
  _BarcodeScannerState createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  Future<void> scanCode() async {
    String barcodeScannerRes;
    try {
      barcodeScannerRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
    } on PlatformException {
      barcodeScannerRes = "Failed to scan";
    }

    if (!mounted) return;

    widget.onScanResult(barcodeScannerRes);
    Navigator.of(context).pop(); // Close the scanner screen
  }

  @override
  void initState() {
    super.initState();
    scanCode(); // Start scanning as soon as the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
      ),
      body: const Center(
        child: CircularProgressIndicator(), // Show a loading indicator while scanning
      ),
    );
  }
}