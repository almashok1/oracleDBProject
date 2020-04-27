import 'package:flutter/material.dart';

BoxDecoration decoration(Color startColor) => BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black54,
                offset: Offset(3, 4),
                blurRadius: 5.0,
                spreadRadius: 2.0)
          ],
          gradient: LinearGradient(colors: [startColor, Color(0xffffbd69)]),
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Color(0xffffbd69), width: 3.0));

RoundedRectangleBorder shapeBorder(radius, [borderBold = true]) =>
      RoundedRectangleBorder(
          side: BorderSide(
              color: Color(0xffffbd69), width: borderBold ? 3.0 : 1.5),
          borderRadius: BorderRadius.all(Radius.circular(radius)));
