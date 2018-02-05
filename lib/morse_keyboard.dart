import 'package:flutter/material.dart';
import 'package:morse_chat/binary_status.dart';

typedef ChangeHandlerType(BinaryStatus newStatus, Duration previousDuration, DateTime timestamp);

class MorseKeyboard extends StatefulWidget {
  final ChangeHandlerType changeHandler;

  MorseKeyboard(this.changeHandler);

  @override
  _MorseKeyboardState createState() => new _MorseKeyboardState();
}

class _MorseKeyboardState extends State<MorseKeyboard> {
  DateTime _lastChange;
  BinaryStatus _status = BinaryStatus.UP;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTapUp: (_) => _handleChange(BinaryStatus.UP),
      onTapDown: (_) => _handleChange(BinaryStatus.DOWN),
      child: new Container(
        color: BINARY_STATUS_COLORS[_status],
      ),
    );
  }

  void _handleChange(BinaryStatus newStatus) {
    DateTime now = new DateTime.now();
    Duration previousDuration = _lastChange == null ? null : now.difference(_lastChange);
    _lastChange = now;
    widget.changeHandler(newStatus, previousDuration, now);
    setState(() {
      _status = newStatus;
    });
  }
}
