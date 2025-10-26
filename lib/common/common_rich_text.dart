import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:antill_estates/model/text_segment_model.dart';

class CommonRichText extends StatelessWidget {
  final List<TextSegment> segments;
  final TextAlign textAlign;

  const CommonRichText({
    super.key,
    required this.segments,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        children: segments
            .map((segment) => TextSpan(
          text: segment.text,
          style: segment.style,
          recognizer: segment.onTap != null
              ? (TapGestureRecognizer()
            ..onTap = () {
              segment.onTap!();
            })
              : null,
        ))
            .toList(),
      ),
    );
  }
}
