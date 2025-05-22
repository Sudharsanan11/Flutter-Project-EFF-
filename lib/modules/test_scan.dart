
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'dart:async';

// class TestBarcodeScanner extends StatefulWidget {
//   final Function(List<String>) onSaveBarcodes;
//   final List<String> existingBarcodes;
//   final List<Map<String, Map<String, List<String>>>> allowedBarcodes;
//   final String doctype;

//   const TestBarcodeScanner({
//     super.key,
//     required this.doctype,
//     required this.onSaveBarcodes,
//     required this.existingBarcodes,
//     required this.allowedBarcodes,
//   });

//   @override
//   _TestBarcodeScannerState createState() => _TestBarcodeScannerState();
// }

// class _TestBarcodeScannerState extends State<TestBarcodeScanner> {
//   bool isScanning = false;
//   final List<String> scannedBarcodes = [];
//   final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
//   int currentCategoryIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _initializeNotifications();
//     isScanning = true;
//     scanCode();
//   }

//   Future<void> _initializeNotifications() async {
//     const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initializationSettings = InitializationSettings(android: androidSettings);
    
//     await notificationsPlugin.initialize(initializationSettings);
//     await _requestNotificationPermissions();
//   }

//   Future<void> _requestNotificationPermissions() async {
//     final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
//         notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
//     await androidImplementation?.requestNotificationsPermission();
//   }

//   void _showNotification(String title, String body) {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'barcode_channel',
//       'Barcode Scanner Notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//       playSound: true,
//     );

//     const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
//     notificationsPlugin.show(0, title, body, platformDetails);
//   }

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

//     if (barcodeScannerRes != '-1') {
//       _processScannedBarcode(barcodeScannerRes);
//       Future.delayed(const Duration(milliseconds: 700), scanCode);
//     } else {
//       setState(() {
//         isScanning = false;
//       });
//     }
//   }

//   void _processScannedBarcode(String value) {
//     if (value.isEmpty) return;

//     // Check if barcode is already scanned or exists
//     if (scannedBarcodes.contains(value) || widget.existingBarcodes.contains(value)) {
//       _showNotification("Duplicate Barcode", "The barcode $value has already been scanned.");
//       return;
//     }

//     // Different handling based on doctype
//     if (widget.doctype == 'Loading Details') {
//       // For Loading Details, enforce category restrictions
//       String currentCategory = widget.allowedBarcodes[currentCategoryIndex].keys.first;
//       Map<String, List<String>> currentAllowedItems = widget.allowedBarcodes[currentCategoryIndex][currentCategory] ?? {};
//       bool barcodeExists = currentAllowedItems.values.any((barcodes) => barcodes.contains(value));

//       if (!barcodeExists) {
//         _showNotification("Invalid Scan", "Barcode does not belong to category '$currentCategory'");
//       } else {
//         setState(() {
//           scannedBarcodes.add(value);
//         });

//         if (_isCategoryComplete(currentAllowedItems)) {
//           if (currentCategoryIndex < widget.allowedBarcodes.length - 1) {
//             setState(() {
//               currentCategoryIndex++;
//             });

//             String nextCategory = widget.allowedBarcodes[currentCategoryIndex].keys.first;
//             _showNotification("Next Category", "Now scan barcodes from '$nextCategory'");
//           }
//         }
//       }
//     } else if (widget.doctype == 'Unloading Details') {
//       // For Unloading Details, check if barcode is allowed but don't enforce category order
//       bool isAllowed = false;
//       for (var categoryMap in widget.allowedBarcodes) {
//         categoryMap.forEach((cat, items) {
//           items.forEach((itm, barcodes) {
//             if (barcodes.contains(value)) {
//               isAllowed = true;
//             }
//           });
//         });
//       }

//       if (!isAllowed) {
//         _showNotification("Invalid Scan", "Barcode $value is not in the allowed list");
//       } else {
//         setState(() {
//           scannedBarcodes.add(value);
//         });
//       }
//     } else {
//       // For LR or any other doctype, accept all scans without special validation
//       setState(() {
//         scannedBarcodes.add(value);
//       });
//       _showNotification("Barcode Added", "Successfully added barcode: $value");
//     }
//   }

//   bool _isCategoryComplete(Map<String, List<String>> currentAllowedItems) {
//     return currentAllowedItems.values.every((barcodes) =>
//         barcodes.every((barcode) => scannedBarcodes.contains(barcode) || widget.existingBarcodes.contains(barcode)));
//   }

//   void _validateBeforeSubmit() {
//     if (widget.doctype == 'Loading Details') {
//       List<String> missingCategories = [];

//       for (var categoryMap in widget.allowedBarcodes) {
//         String category = categoryMap.keys.first;
//         Map<String, List<String>> categoryItems = categoryMap[category] ?? {};
//         bool allScanned = categoryItems.values.every((barcodes) =>
//             barcodes.every((barcode) => scannedBarcodes.contains(barcode) || widget.existingBarcodes.contains(barcode)));

//         if (!allScanned) {
//           missingCategories.add(category);
//         }
//       }

//       if (missingCategories.isNotEmpty) {
//         _showNotification("Incomplete Scans", "You missed scanning: ${missingCategories.join(', ')}");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Missing scans in: ${missingCategories.join(', ')}'),
//             backgroundColor: Colors.orange,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       } else {
//         _saveBarcodes();
//       }
//     } else {
//       // For LR or Unloading Details, no special validation before submit
//       _saveBarcodes();
//     }
//   }

//   void _saveBarcodes() {
//     widget.onSaveBarcodes([...widget.existingBarcodes, ...scannedBarcodes]);
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         setState(() {
//           isScanning = false;
//         });
//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Barcode Scanner - ${widget.doctype}'),
//         ),
//         body: Column(
//           children: [
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Text(
//                 'Scanned Barcodes:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//             Expanded(
//               child: widget.doctype == 'LR' 
//                   ? _buildLRScannedBarcodesView() 
//                   : ListView(
//                       children: _buildCategorizedScannedBarcodesView(),
//                     ),
//             ),
//             const Divider(),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: _validateBeforeSubmit,
//                 child: const Text('Submit Barcodes'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLRScannedBarcodesView() {
//     return scannedBarcodes.isEmpty
//         ? const Center(child: Text('No barcodes scanned yet'))
//         : ListView.builder(
//             itemCount: scannedBarcodes.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 leading: const Icon(Icons.qr_code),
//                 title: Text(scannedBarcodes[index]),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () {
//                     setState(() {
//                       scannedBarcodes.removeAt(index);
//                     });
//                   },
//                 ),
//               );
//             },
//           );
//   }

//   List<Widget> _buildCategorizedScannedBarcodesView() {
//     List<Widget> scannedWidgets = [];
//     int categoryIndex = 1;

//     for (var categoryMap in widget.allowedBarcodes) {
//       String category = categoryMap.keys.first;
//       Map<String, List<String>> categoryItems = categoryMap[category] ?? {};

//       List<Widget> itemWidgets = [];

//       for (var entry in categoryItems.entries) {
//         String itemName = entry.key;
//         List<String> barcodes = entry.value;

//         for (String barcode in barcodes) {
//           if (scannedBarcodes.contains(barcode) || widget.existingBarcodes.contains(barcode)) {
//             itemWidgets.add(
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Text("      $itemName: $barcode", style: const TextStyle(fontSize: 16)),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () {
//                         setState(() {
//                           scannedBarcodes.remove(barcode);
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//         }
//       }

//       if (itemWidgets.isNotEmpty) {
//         scannedWidgets.add(
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             child: Text(
//               "$categoryIndex. $category:",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ),
//         );
//         scannedWidgets.addAll(itemWidgets);
//         categoryIndex++;
//       }
//     }

//     if (widget.doctype == 'Unloading Details') {
//       List<Widget> uncategorizedItems = [];
      
//       for (String barcode in scannedBarcodes) {
//         bool isCategorized = false;
        
//         for (var categoryMap in widget.allowedBarcodes) {
//           categoryMap.forEach((cat, items) {
//             items.forEach((itm, barcodes) {
//               if (barcodes.contains(barcode)) {
//                 isCategorized = true;
//               }
//             });
//           });
//         }
        
//         if (!isCategorized) {
//           uncategorizedItems.add(
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text("      Uncategorized: $barcode", style: const TextStyle(fontSize: 16)),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.delete, color: Colors.red),
//                     onPressed: () {
//                       setState(() {
//                         scannedBarcodes.remove(barcode);
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//       }
      
//       if (uncategorizedItems.isNotEmpty) {
//         scannedWidgets.add(
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             child: Text(
//               "$categoryIndex. Uncategorized:",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ),
//         );
//         scannedWidgets.addAll(uncategorizedItems);
//       }
//     }

//     return scannedWidgets.isEmpty 
//       ? [
//           const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Text('No barcodes scanned yet'),
//           )
//         ]
//       : scannedWidgets;
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'dart:async';

// class TestBarcodeScanner extends StatefulWidget {
//   final Function(List<String>) onSaveBarcodes;
//   final List<String> existingBarcodes;
//   final List<Map<String, Map<String, List<String>>>> allowedBarcodes;
//   final String doctype;

//   const TestBarcodeScanner({
//     super.key,
//     required this.doctype,
//     required this.onSaveBarcodes,
//     required this.existingBarcodes,
//     required this.allowedBarcodes,
//   });

//   @override
//   _TestBarcodeScannerState createState() => _TestBarcodeScannerState();
// }

// class _TestBarcodeScannerState extends State<TestBarcodeScanner> {
//   bool isScanning = false;
//   final List<String> scannedBarcodes = [];
//   final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
//   int currentCategoryIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _initializeNotifications();
//     isScanning = true;
//     scanCode();
//   }

//   Future<void> _initializeNotifications() async {
//     const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initializationSettings = InitializationSettings(android: androidSettings);
    
//     await notificationsPlugin.initialize(initializationSettings);
//     await _requestNotificationPermissions();
//   }

//   Future<void> _requestNotificationPermissions() async {
//     final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
//         notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
//     await androidImplementation?.requestNotificationsPermission();
//   }

//   void _showNotification(String title, String body) {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'barcode_channel',
//       'Barcode Scanner Notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//       playSound: true,
//     );

//     const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
//     notificationsPlugin.show(0, title, body, platformDetails);
//   }

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

//     if (barcodeScannerRes != '-1') {
//       _processScannedBarcode(barcodeScannerRes);
//       Future.delayed(const Duration(milliseconds: 700), scanCode);
//     } else {
//       setState(() {
//         isScanning = false;
//       });
//     }
//   }

//   bool _isValidBarcodeFormat(String barcode) {
//     // Check if barcode is exactly 11 characters with a space between 4th and 5th characters
//     final RegExp barcodePattern = RegExp(r'^\d{4}\s\d{7}$');
//     return barcodePattern.hasMatch(barcode) && barcode.length == 11;
//   }

//   void _processScannedBarcode(String value) {
//     if (value.isEmpty) return;

//     // Validate barcode format only for LR doctype
//     if (widget.doctype == 'LR' && !_isValidBarcodeFormat(value)) {
//       _showNotification(
//         "Invalid Barcode Format",
//         "Barcode must be 11 characters in format '1234 5678901'",
//       );
//       return;
//     }

//     // Check if barcode is already scanned or exists
//     if (scannedBarcodes.contains(value) || widget.existingBarcodes.contains(value)) {
//       _showNotification("Duplicate Barcode", "The barcode $value has already been scanned.");
//       return;
//     }

//     // Different handling based on doctype
//     if (widget.doctype == 'Loading Details') {
//       // For Loading Details, enforce category restrictions
//       String currentCategory = widget.allowedBarcodes[currentCategoryIndex].keys.first;
//       Map<String, List<String>> currentAllowedItems = widget.allowedBarcodes[currentCategoryIndex][currentCategory] ?? {};
//       bool barcodeExists = currentAllowedItems.values.any((barcodes) => barcodes.contains(value));

//       if (!barcodeExists) {
//         _showNotification("Invalid Scan", "Barcode does not belong to category '$currentCategory'");
//       } else {
//         setState(() {
//           scannedBarcodes.add(value);
//         });
//       }
//     } else if (widget.doctype == 'Unloading Details') {
//       // For Unloading Details, check if barcode is allowed but don't enforce category order
//       bool isAllowed = false;
//       for (var categoryMap in widget.allowedBarcodes) {
//         categoryMap.forEach((cat, items) {
//           items.forEach((itm, barcodes) {
//             if (barcodes.contains(value)) {
//               isAllowed = true;
//             }
//           });
//         });
//       }

//       if (!isAllowed) {
//         _showNotification("Invalid Scan", "Barcode $value is not in the allowed list");
//       } else {
//         setState(() {
//           scannedBarcodes.add(value);
//         });
//       }
//     } else {
//       // For LR or any other doctype, accept all scans (format already validated above for LR)
//       setState(() {
//         scannedBarcodes.add(value);
//       });
//       _showNotification("Barcode Added", "Successfully added barcode: $value");
//     }
//   }

//   void _saveBarcodes() {
//     widget.onSaveBarcodes([...widget.existingBarcodes, ...scannedBarcodes]);
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         setState(() {
//           isScanning = false;
//         });
//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Barcode Scanner - ${widget.doctype}'),
//         ),
//         body: Column(
//           children: [
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Text(
//                 'Scanned Barcodes:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//             Expanded(
//               child: ListView(
//                 children: _buildCategorizedScannedBarcodesView(),
//               ),
//             ),
//             const Divider(),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         isScanning = true;
//                         scanCode();
//                       });
//                     },
//                     child: const Text('Scan Again'),
//                   ),
//                   ElevatedButton(
//                     onPressed: _saveBarcodes,
//                     child: const Text('Submit Barcodes'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildCategorizedScannedBarcodesView() {
//     List<Widget> scannedWidgets = [];
//     Map<String, Map<String, List<String>>> categorizedBarcodes = {};

//     // Organize barcodes by category and item
//     for (var categoryMap in widget.allowedBarcodes) {
//       String category = categoryMap.keys.first;
//       Map<String, List<String>> categoryItems = categoryMap[category] ?? {};
      
//       categorizedBarcodes[category] = {};
//       for (var entry in categoryItems.entries) {
//         String itemName = entry.key;
//         List<String> barcodes = entry.value;
        
//         categorizedBarcodes[category]![itemName] = barcodes
//             .where((barcode) => 
//                 scannedBarcodes.contains(barcode) || 
//                 widget.existingBarcodes.contains(barcode))
//             .toList();
//       }
//     }

//     // Handle uncategorized barcodes for Unloading Details
//     if (widget.doctype == 'Unloading Details') {
//       List<String> uncategorized = scannedBarcodes.where((barcode) {
//         return !widget.allowedBarcodes.any((categoryMap) =>
//             categoryMap.values.first.values.any((barcodes) => 
//                 barcodes.contains(barcode)));
//       }).toList();
      
//       if (uncategorized.isNotEmpty) {
//         categorizedBarcodes['Uncategorized'] = {
//           'Uncategorized': uncategorized
//         };
//       }
//     }

//     // Handle LR or other doctypes with no categorization
//     if (widget.doctype == 'LR' && scannedBarcodes.isNotEmpty) {
//       categorizedBarcodes['Scanned Items'] = {
//         'Item': scannedBarcodes
//       };
//     }

//     // Build widgets
//     int categoryIndex = 1;
//     for (var categoryEntry in categorizedBarcodes.entries) {
//       String category = categoryEntry.key;
//       Map<String, List<String>> items = categoryEntry.value;

//       List<Widget> itemWidgets = [];
//       for (var itemEntry in items.entries) {
//         String itemName = itemEntry.key;
//         List<String> barcodes = itemEntry.value;

//         if (barcodes.isNotEmpty) {
//           for (String barcode in barcodes) {
//             itemWidgets.add(
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         "  $itemName: $barcode",
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () {
//                         setState(() {
//                           scannedBarcodes.remove(barcode);
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//         }
//       }

//       if (itemWidgets.isNotEmpty) {
//         scannedWidgets.add(
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             child: Text(
//               "$categoryIndex. $category:",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ),
//         );
//         scannedWidgets.addAll(itemWidgets);
//         categoryIndex++;
//       }
//     }

//     return scannedWidgets.isEmpty 
//       ? [
//           const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Text('No barcodes scanned yet'),
//           )
//         ]
//       : scannedWidgets;
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class TestBarcodeScanner extends StatefulWidget {
  final Function(List<String>) onSaveBarcodes;
  final List<String> existingBarcodes;
  final List<Map<String, Map<String, List<String>>>> allowedBarcodes;
  final String doctype;

  const TestBarcodeScanner({
    super.key,
    required this.doctype,
    required this.onSaveBarcodes,
    required this.existingBarcodes,
    required this.allowedBarcodes,
  });

  @override
  _TestBarcodeScannerState createState() => _TestBarcodeScannerState();
}

class _TestBarcodeScannerState extends State<TestBarcodeScanner> {
  bool isScanning = false;
  final List<String> scannedBarcodes = [];
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  int currentCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    isScanning = true;
    scanCode();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: androidSettings);
    
    await notificationsPlugin.initialize(initializationSettings);
    await _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    await androidImplementation?.requestNotificationsPermission();
  }

  void _showNotification(String title, String body) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'barcode_channel',
      'Barcode Scanner Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    notificationsPlugin.show(0, title, body, platformDetails);
  }

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
      _processScannedBarcode(barcodeScannerRes);
      Future.delayed(const Duration(milliseconds: 700), scanCode);
    } else {
      setState(() {
        isScanning = false;
      });
    }
  }

  bool _isValidBarcodeFormat(String barcode) {
    final RegExp barcodePattern = RegExp(r'^\d{4}\s\d{7}$');
    return barcodePattern.hasMatch(barcode) && barcode.length == 11;
  }

  void _processScannedBarcode(String value) {
    if (value.isEmpty) return;

    // Validate barcode format only for LR doctype
    if (widget.doctype == 'LR' && !_isValidBarcodeFormat(value)) {
      _showNotification(
        "Invalid Barcode Format",
        "Barcode must be 11 characters in format '1234 5678901'",
      );
      return;
    }

    // Check if barcode is already scanned or exists
    if (scannedBarcodes.contains(value) || widget.existingBarcodes.contains(value)) {
      _showNotification("Duplicate Barcode", "The barcode $value has already been scanned.");
      return;
    }

    // Different handling based on doctype
    if (widget.doctype == 'Loading Details') {
      String currentCategory = widget.allowedBarcodes[currentCategoryIndex].keys.first;
      Map<String, List<String>> currentAllowedItems = widget.allowedBarcodes[currentCategoryIndex][currentCategory] ?? {};
      bool barcodeExists = currentAllowedItems.values.any((barcodes) => barcodes.contains(value));

      if (!barcodeExists) {
        _showNotification("Invalid Scan", "Barcode does not belong to category '$currentCategory'");
      } else {
        setState(() {
          scannedBarcodes.add(value);
        });
      }
    } else if (widget.doctype == 'Unloading Details') {
      bool isAllowed = false;
      for (var categoryMap in widget.allowedBarcodes) {
        categoryMap.forEach((cat, items) {
          items.forEach((itm, barcodes) {
            if (barcodes.contains(value)) {
              isAllowed = true;
            }
          });
        });
      }

      if (!isAllowed) {
        _showNotification("Invalid Scan", "Barcode $value is not in the allowed list");
      } else {
        setState(() {
          scannedBarcodes.add(value);
        });
      }
    } else {
      setState(() {
        scannedBarcodes.add(value);
      });
      _showNotification("Barcode Added", "Successfully added barcode: $value");
    }
  }

  void _saveBarcodes() {
    widget.onSaveBarcodes([...widget.existingBarcodes, ...scannedBarcodes]);
    Navigator.pop(context);
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
          title: Text('Barcode Scanner - ${widget.doctype}'),
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
              child: ListView(
                children: _buildCategorizedScannedBarcodesView(),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isScanning = true;
                        scanCode();
                      });
                    },
                    child: const Text('Scan Again'),
                  ),
                  ElevatedButton(
                    onPressed: _saveBarcodes,
                    child: const Text('Submit Barcodes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategorizedScannedBarcodesView() {
    List<Widget> scannedWidgets = [];
    Map<String, Map<String, List<String>>> categorizedBarcodes = {};

    // Process allowed barcodes for categorization
    for (var categoryMap in widget.allowedBarcodes) {
      String category = categoryMap.keys.first;
      Map<String, List<String>> categoryItems = categoryMap[category] ?? {};
      
      categorizedBarcodes[category] = {};
      for (var entry in categoryItems.entries) {
        String itemName = entry.key;
        List<String> barcodes = entry.value;
        
        // Check both existing and scanned barcodes against allowed barcodes
        List<String> matchingBarcodes = barcodes
            .where((barcode) => 
                scannedBarcodes.contains(barcode) || 
                widget.existingBarcodes.contains(barcode))
            .toList();
        
        if (matchingBarcodes.isNotEmpty) {
          categorizedBarcodes[category]![itemName] = matchingBarcodes;
        }
      }
    }

    // Handle uncategorized barcodes for Unloading Details
    if (widget.doctype == 'Unloading Details') {
      // Uncategorized scanned barcodes
      List<String> uncategorizedScanned = scannedBarcodes.where((barcode) {
        return !widget.allowedBarcodes.any((categoryMap) =>
            categoryMap.values.first.values.any((barcodes) => 
                barcodes.contains(barcode)));
      }).toList();
      
      // Uncategorized existing barcodes
      List<String> uncategorizedExisting = widget.existingBarcodes.where((barcode) {
        return !widget.allowedBarcodes.any((categoryMap) =>
            categoryMap.values.first.values.any((barcodes) => 
                barcodes.contains(barcode)));
      }).toList();
      
      if (uncategorizedScanned.isNotEmpty || uncategorizedExisting.isNotEmpty) {
        categorizedBarcodes['Uncategorized'] = {
          'Uncategorized': [...uncategorizedScanned, ...uncategorizedExisting]
        };
      }
    }

    // Handle LR doctype
    if (widget.doctype == 'LR') {
      List<String> allBarcodes = [...widget.existingBarcodes, ...scannedBarcodes];
      if (allBarcodes.isNotEmpty) {
        categorizedBarcodes['Scanned Items'] = {
          'Item': allBarcodes
        };
      }
    }

    // Build widgets
    int categoryIndex = 1;
    for (var categoryEntry in categorizedBarcodes.entries) {
      String category = categoryEntry.key;
      Map<String, List<String>> items = categoryEntry.value;

      List<Widget> itemWidgets = [];
      for (var itemEntry in items.entries) {
        String itemName = itemEntry.key;
        List<String> barcodes = itemEntry.value;

        for (String barcode in barcodes) {
          itemWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "  $itemName: $barcode",
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.existingBarcodes.contains(barcode) 
                            ? Colors.grey 
                            : Colors.black,
                      ),
                    ),
                  ),
                  if (!widget.existingBarcodes.contains(barcode)) // Delete only for new scans
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          scannedBarcodes.remove(barcode);
                        });
                      },
                    ),
                ],
              ),
            ),
          );
        }
      }

      if (itemWidgets.isNotEmpty) {
        scannedWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              "$categoryIndex. $category:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
        scannedWidgets.addAll(itemWidgets);
        categoryIndex++;
      }
    }

    return scannedWidgets.isEmpty 
      ? [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No barcodes scanned yet'),
          )
        ]
      : scannedWidgets;
  }
}