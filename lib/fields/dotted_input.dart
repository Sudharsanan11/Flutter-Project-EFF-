import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class DottedInput extends StatelessWidget {
  final double borderRadius;
  final List<double> dashPattern;
  final Color borderColor;
  final double strokeWidth;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final String labelText;

  const DottedInput({
    super.key,
    this.borderRadius = 12.0,
    this.dashPattern = const [8, 4],
    this.borderColor = Colors.black,
    this.strokeWidth = 2.0,
    this.padding = const EdgeInsets.all(16),
    required this.child,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 3.0),
        ),
        DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(borderRadius),
          dashPattern: dashPattern,
          color: borderColor,
          strokeWidth: strokeWidth,
          child: Container(
            padding: padding,
            child: Center(child: child),
          ),
        ),
      ],
    );
  }
}
