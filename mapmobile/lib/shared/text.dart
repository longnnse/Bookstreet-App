import 'package:flutter/material.dart';

class ThinSmText extends StatelessWidget {
  const ThinSmText({super.key, required this.text, this.color = Colors.black});

  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10, color: color),
    );
  }
}

class BoldXLText extends StatelessWidget {
  const BoldXLText({super.key, required this.text});

  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 40,
          color: Colors.black,
          letterSpacing: 3),
    );
  }
}

class BoldLGText extends StatelessWidget {
  const BoldLGText({super.key, required this.text, this.color = Colors.black});

  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        text,
        style:
            TextStyle(fontWeight: FontWeight.w600, fontSize: 30, color: color),
      ),
    );
  }
}

class DynamicText extends StatelessWidget {
  const DynamicText(
      {super.key, required this.text, this.textStyle, this.verMargin = 10});

  final String text;
  final TextStyle? textStyle;
  final double verMargin;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: verMargin),
      child: Text(
        text,
        style: textStyle,
        softWrap: true,
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    this.gradient = const LinearGradient(colors: [
      Color(0xffe16b5c),
      Color(0xffffb56b),
    ]),
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
