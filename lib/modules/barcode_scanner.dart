//   import 'package:erpnext_logistics_mobile/home.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

// class BarcodeScanner extends StatefulWidget {
//   final Function(String) onScanResult;

//   const BarcodeScanner({super.key, required this.onScanResult});

//   @override
//   _BarcodeScannerState createState() => _BarcodeScannerState();
// }

// class _BarcodeScannerState extends State<BarcodeScanner> {
//   Future<void> scanCode() async {
//     String barcodeScannerRes;
//     try {
//       barcodeScannerRes = await FlutterBarcodeScanner.scanBarcode(
//         '#ff6666',
//         'Cancel',
//         true,
//         ScanMode.BARCODE,
//       );
//     } on PlatformException {
//       barcodeScannerRes = "Failed to scan";
//     }

//     if (!mounted) return;

//     widget.onScanResult(barcodeScannerRes);
//     scan();
//     // Navigator.of(context).pop(); // Close the scanner screen
//   }
//  void scan() {
//   scanCode();
//   }

//   @override
//   void initState() {
//     super.initState();
//     scanCode(); // Start scanning as soon as the widget is initialized
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if(didPop) {return;}
//         Navigator.push(context, 
//         MaterialPageRoute(builder: (context) => const EFF()));
//       },
//     child:  Scaffold(
//       appBar: AppBar(
//         title: const Text('Barcode Scanner'),
//       ),
//       body: const Center(
//         child: CircularProgressIndicator(), // Show a loading indicator while scanning
//       ),
//     )
//     );
//   }
// }









// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

// class BarcodeScanner extends StatefulWidget {
//   final Function(String) onScanResult;

//   const BarcodeScanner({super.key, required this.onScanResult});

//   @override
//   _BarcodeScannerState createState() => _BarcodeScannerState();
// }

// class _BarcodeScannerState extends State<BarcodeScanner> {
//   bool isScanning = false;

//   Future<void> scanCode() async {
//     String barcodeScannerRes;
//     try {
//       barcodeScannerRes = await FlutterBarcodeScanner.scanBarcode(
//         '#ff6666',
//         'Cancel',
//         true,
//         ScanMode.BARCODE,
//       );
//     } on PlatformException {
//       barcodeScannerRes = "Failed to scan";
//     }

//     if (!mounted) return;

//     if (barcodeScannerRes != '-1') {  // If scan is not canceled
//       widget.onScanResult(barcodeScannerRes);
//       // Automatically scan again
//       scanCode();
//     } else {
//       setState(() {
//         isScanning = false;  // Stop scanning if canceled
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     isScanning = true;
//     scanCode(); // Start scanning as soon as the widget is initialized
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         // Allow the back button to navigate to the previous screen
//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Barcode Scanner'),
//         ),
//         body: Center(
//           child: isScanning
//               ? const CircularProgressIndicator() // Show loading while scanning
//               : const Text('Scanning stopped'), // Show message when scanning stops
//         ),
//       ),
//     );
//   }
// }







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
      setState(() {
        isScanning = false;
      });
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
        body: Center(
          child: isScanning
              ? const CircularProgressIndicator()
              : const Text('Scanning stopped'),
        ),
      ),
    );
  }
}




