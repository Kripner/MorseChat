import 'package:flutter/material.dart';

enum BinaryStatus { UP, DOWN }

const BINARY_STATUS_COLORS = const <BinaryStatus, Color>{
  BinaryStatus.UP: Colors.white,
  BinaryStatus.DOWN: Colors.black,
};
