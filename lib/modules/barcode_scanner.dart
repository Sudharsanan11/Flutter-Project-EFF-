import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  _BarcodeScannerState createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  String _scanResult = "";

  Future<void> scanCode() async {
    String barcodeScannerRes;
    try {
      barcodeScannerRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 
        'Cancel', 
        true, 
        ScanMode.BARCODE
      );
    } on PlatformException {
      barcodeScannerRes = "Failed to scan";
    }

    if (!mounted) return;

    setState(() {
      _scanResult = barcodeScannerRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Scan result: $_scanResult'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: scanCode,
              child: const Text('Scan Barcode'),
            ),
          ],
        ),
      ),
    );
  }
}
