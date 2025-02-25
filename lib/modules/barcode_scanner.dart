import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:async';

class BarcodeScanner extends StatefulWidget {
  final Function(String) onScanResult;

  const BarcodeScanner({super.key, required this.onScanResult});

  @override
  _BarcodeScannerState createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  bool isScanning = false;

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
      widget.onScanResult(barcodeScannerRes);

      await Future.delayed(const Duration(seconds: 1));

      scanCode();
    } else {
      // setState(() {
      //   isScanning = false;
      // });
      Navigator.pop(context);
    }
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
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Barcode Scanner'),
        ),
        body: const Center(
          child: CircularProgressIndicator()
        ),
      ),
    );
  }
}




