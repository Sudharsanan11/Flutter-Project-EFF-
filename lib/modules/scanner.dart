import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BluetoothBarcodeScanner extends StatefulWidget {
  final Function(List<String>) onSaveBarcodes;
  final List<String> existingBarcodes;
  final List<Map<String, Map<String, List<String>>>> allowedBarcodes;
  final String doctype;

  const BluetoothBarcodeScanner({
    Key? key,
    required this.doctype,
    required this.onSaveBarcodes,
    required this.existingBarcodes,
    required this.allowedBarcodes,
  }) : super(key: key);

  @override
  _BluetoothBarcodeScannerState createState() => _BluetoothBarcodeScannerState();
}

class _BluetoothBarcodeScannerState extends State<BluetoothBarcodeScanner> {
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> scannedBarcodes = [];
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  int currentCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _focusNode.dispose();
    super.dispose();
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

  bool _isValidBarcodeFormat(String barcode) {
    final RegExp barcodePattern = RegExp(r'^[A-Za-z]{4}\d{7}$');
    return barcodePattern.hasMatch(barcode) && barcode.length == 11;
  }

  bool _isCategoryComplete(Map<String, List<String>> currentAllowedItems) {
    return currentAllowedItems.values.every((barcodes) =>
        barcodes.every((barcode) => scannedBarcodes.contains(barcode) || widget.existingBarcodes.contains(barcode)));
  }

  void _processScannedBarcode(String value) {
    if (value.isEmpty) return;

    // Validate barcode format only for LR doctype
    if (widget.doctype == 'LR' && !_isValidBarcodeFormat(value)) {
      _showNotification(
        "Invalid Barcode Format",
        "Barcode must be 11 characters in format 'ABCD9876543'",
      );
      _barcodeController.clear();
      _focusNode.requestFocus();
      return;
    }

    // Check if barcode is already scanned or exists
    if (scannedBarcodes.contains(value) || widget.existingBarcodes.contains(value)) {
      _showNotification("Duplicate Barcode", "The barcode $value has already been scanned.");
      _barcodeController.clear();
      _focusNode.requestFocus();
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

        // Check if current category is complete and move to next if needed
        if (_isCategoryComplete(currentAllowedItems)) {
          if (currentCategoryIndex < widget.allowedBarcodes.length - 1) {
            setState(() {
              currentCategoryIndex++;
            });
            String nextCategory = widget.allowedBarcodes[currentCategoryIndex].keys.first;
            _showNotification("Next Category", "Now scan barcodes from '$nextCategory'");
          } else {
            _showNotification("Scanning Complete", "All categories have been scanned");
          }
        }
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
    }

    _barcodeController.clear();
    _focusNode.requestFocus();
  }

  void _saveBarcodes() {
    widget.onSaveBarcodes([...widget.existingBarcodes, ...scannedBarcodes]);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bluetooth Scanner - ${widget.doctype}'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _barcodeController,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  labelText: 'Scan Barcode',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                onSubmitted: _processScannedBarcode,
              ),
            ),
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
              child: ElevatedButton(
                onPressed: _saveBarcodes,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Submit Barcodes'),
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
      List<String> uncategorizedScanned = scannedBarcodes.where((barcode) {
        return !widget.allowedBarcodes.any((categoryMap) =>
            categoryMap.values.first.values.any((barcodes) => 
                barcodes.contains(barcode)));
      }).toList();
      
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
                  if (!widget.existingBarcodes.contains(barcode))
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