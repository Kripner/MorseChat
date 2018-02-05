import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:morse_chat/binary_status.dart';

class Message {
  int minPreviousDuration;
  final BinaryStatus status;

  Message(this.minPreviousDuration, this.status) {
    adjustPreviousDuration();
  }

  // try to minimize the minimal duration
  void adjustPreviousDuration() {
    if (status == BinaryStatus.UP) return; // the previous state was pressed, which has to be precise
    if (minPreviousDuration > 3000) minPreviousDuration = 3000;
  }
}

class MessagesStreamConsumer extends StatefulWidget {
  final Queue<Message> _messagesQueue;

  MessagesStreamConsumer(this._messagesQueue);

  @override
  _MessagesStreamConsumerState createState() => new _MessagesStreamConsumerState();
}

class _MessagesStreamConsumerState extends State<MessagesStreamConsumer> {
  static final BinaryStatus defaultStatus = BinaryStatus.UP;

  int _lastChange;
  Timer _timer;
  Message _currentMessage;

  @override
  Widget build(BuildContext context) {
    _recalculateStatus(true);
    return new Container(
      color: BINARY_STATUS_COLORS[_currentMessage == null ? defaultStatus : _currentMessage.status],
//        child: new Text(widget._messagesQueue.isEmpty ? "Nothing" : "Received!!"),
    );
  }

  void _recalculateStatus(bool setDirectly) {
    print('recalculating');
    // TODO: synchronization issues
    if (_timer != null) return; // already sorted out
    if (widget._messagesQueue.isEmpty) return;
    Message nextMessage = widget._messagesQueue.first;
    int now = new DateTime.now().millisecondsSinceEpoch;
    int yetToWait = _lastChange == null ? 0 : (nextMessage.minPreviousDuration - (now - _lastChange));
    print(_lastChange);
    print(now);
    print(nextMessage.minPreviousDuration);
    if (yetToWait <= 0) {
      print('directly changing state');
      var update = () {
        _currentMessage = nextMessage;
        widget._messagesQueue.removeFirst();
        _lastChange = now;
      };
      if (setDirectly) update();
      else setState(update);
      _recalculateStatus(setDirectly);
    } else {
      print('setting up timer for $yetToWait');
      _timer = new Timer(new Duration(milliseconds: yetToWait), () => _timerOut());
    }
  }

  void _timerOut() {
    print('executing timed refresh');
    if (widget._messagesQueue.isEmpty)
      throw new Exception('There were some synchronization issues - the queue is empty after timeout');
    _timer = null;
    _recalculateStatus(false);
  }

//  void _recalculateStatus() {
//    print('recalculating');
//    // TODO: synchronization issues
//    if (_timer != null) return; // already sorted out
//    if (widget._messagesQueue.isEmpty) return;
//    Message nextMessage = widget._messagesQueue.first;
//    int now = new DateTime.now().millisecondsSinceEpoch;
//    int yetToWait = _lastChange == null ? 0 : nextMessage.minPreviousDuration - (now - _lastChange);
//    if (yetToWait <= 0) {
//      print('directly changing state');
//      _currentMessage = nextMessage;
//      widget._messagesQueue.removeFirst();
//      _lastChange = now;
//    } else {
//      print('setting up timer');
//      _timer = new Timer(new Duration(milliseconds: yetToWait), () => _timerOut());
//    }
//  }
//
//  void _timerOut() {
//    print('executing timed refresh');
//    if (widget._messagesQueue.isEmpty)
//      throw new Exception('There were some synchronization issues - the queue is empty after timeout');
//    setState(() {
//      _currentMessage = widget._messagesQueue.first;
//    });
//    widget._messagesQueue.removeFirst();
//    _lastChange = new DateTime.now().millisecondsSinceEpoch;
//    if (widget._messagesQueue.isEmpty)
//      _timer = null;
//    else
//      _timer =
//          new Timer(new Duration(milliseconds: widget._messagesQueue.first.minPreviousDuration), () => _timerOut());
//  }
}
