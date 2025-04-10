import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:async';

class BarcodeScanner extends StatefulWidget {
  final Function(List<String>) onSaveBarcodes;

  const BarcodeScanner({super.key, required this.onSaveBarcodes});

  @override
  _BarcodeScannerState createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  bool isScanning = false;
  final List<String> scannedBarcodes = [];

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

    if (barcodeScannerRes != '-1') {
      if (scannedBarcodes.contains(barcodeScannerRes)) {
        // Show in-app notification for duplicate barcode
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Duplicate barcode: $barcodeScannerRes'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          scannedBarcodes.add(barcodeScannerRes);
        });
      }

      // Delay before next scan
      await Future.delayed(const Duration(milliseconds: 700));

      scanCode();
    } else {
      // Stop scanning when user cancels
      setState(() {
        isScanning = false;
      });
    }
  }

  void _saveBarcodes() {
    widget.onSaveBarcodes(scannedBarcodes);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    isScanning = true;
    scanCode();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          isScanning = false;
        });
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Barcode Scanner'),
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Scanned Barcodes:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: scannedBarcodes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.qr_code),
                    title: Text(scannedBarcodes[index]),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _saveBarcodes,
                child: const Text('Submit Barcodes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
