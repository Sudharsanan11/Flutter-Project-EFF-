import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastComponent extends StatelessWidget {
  final String message;

  const ToastComponent({super.key, required this.message});

  void showToast(BuildContext context) {
    FToast fToast = FToast();
    fToast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.black87,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, color: Colors.white),
          const SizedBox(width: 12.0),
          Text(message, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showToast(context),
      child: Text("Show Toast: $message"),
    );
  }
}
