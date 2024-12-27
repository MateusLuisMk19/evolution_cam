import 'package:flutter/material.dart';

class MyText extends StatefulWidget {
  final String? size;
  final String value;
  final FontWeight? fontWeight;
  final Color? color;
  final double marginBottom;
  final double marginTop;
  final CrossAxisAlignment? textAlign;
  final MainAxisAlignment? mainAxisAlignment;
  final bool inviseble;

  const MyText({
    Key? key,
    this.size,
    required this.value,
    this.fontWeight,
    this.color,
    this.marginBottom = 0,
    this.marginTop = 0,
    this.textAlign,
    this.mainAxisAlignment,
    this.inviseble = false,
  }) : super(key: key);

  @override
  _MyTextState createState() => _MyTextState();
}

class _MyTextState extends State<MyText> {
  @override
  Widget build(BuildContext context) {
    if (widget.inviseble) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: widget.textAlign ?? CrossAxisAlignment.start,
      mainAxisAlignment: widget.mainAxisAlignment ?? MainAxisAlignment.center,
      children: [
        SizedBox(
          height: widget.marginTop,
        ),
        Text(
          widget.value,
          style: TextStyle(
            fontSize: widget.size == 'md'
                ? 20
                : widget.size == 'lg'
                    ? 25
                    : widget.size == 'sm'
                        ? 15
                        : 18,
            fontWeight: widget.fontWeight,
            color: widget.color,
          ),
        ),
        SizedBox(
          height: widget.marginBottom,
        )
      ],
    );
  }
}
