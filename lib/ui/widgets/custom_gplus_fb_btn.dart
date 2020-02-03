import 'package:flutter/material.dart';

class CustomCircleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  final Color splashColor;
  final Color borderColor;
  final double borderWidth;
  final Icon customIcon;

  CustomCircleButton(
      {this.onPressed,
      this.color,
      this.splashColor,
      this.borderColor,
      this.borderWidth,
      this.customIcon});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      color: color,
      splashColor: splashColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0),
        child: customIcon,
      ),
      shape: CircleBorder(
        side: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
      ),
    );
  }
}