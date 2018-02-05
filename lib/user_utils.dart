import 'dart:math';

import 'package:flutter/material.dart';

Widget buildAvatar(photoUrl, uid) {
  return new Container(
    margin: const EdgeInsets.only(right: 16.0),
    child: new CircleAvatar(
      backgroundColor: photoUrl == null ? _randomColor(uid) : null,
      backgroundImage: photoUrl == null ? null : new NetworkImage(photoUrl),
    ),
  );
}

Color _randomColor(String seed) {
  Random r = new Random(seed.codeUnits.reduce((a, b) => (a * b) % 876));
  return new Color.fromARGB(255, r.nextInt(256), 100, r.nextInt(256));
}
