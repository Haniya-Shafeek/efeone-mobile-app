import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class custom_text extends StatelessWidget {
  const custom_text({
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    required this.text,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow? overflow;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.roboto(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
