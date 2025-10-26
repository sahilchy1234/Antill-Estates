import 'package:flutter/material.dart';

class TextSegment {
  final String text;
  final TextStyle style;
  final VoidCallback? onTap;

  TextSegment({required this.text, required this.style, this.onTap});
}
