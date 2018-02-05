import 'package:flutter/material.dart';

void showTextSnackBar(BuildContext context, String text) {
  Scaffold.of(context).showSnackBar(new SnackBar(
    content: new Text(text),
  ));
}