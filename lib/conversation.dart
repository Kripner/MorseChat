import 'dart:async';
import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:morse_chat/binary_status.dart';
import 'package:morse_chat/main.dart';
import 'package:morse_chat/messages_stream_consumer.dart';
import 'package:morse_chat/morse_keyboard.dart';
import 'package:morse_chat/user_utils.dart';

class Conversation extends StatefulWidget {
  final String uid;
  final String otherUid;
  final DatabaseReference chatReference;

  Conversation(this.uid, this.otherUid) : chatReference = chatsReference.child('${_getChatName(uid, otherUid)}');

  static _getChatName(String firstUid, String secondUid) {
    return firstUid.compareTo(secondUid) > 0 ? firstUid + secondUid : secondUid + firstUid;
  }

  @override
  _ConversationState createState() => new _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final Queue<Message> _messages = new Queue<Message>();
  DataSnapshot _user;
  DataSnapshot _otherUser;
  int _startTimestamp;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _otherUser == null ? new Container() : _buildUserInfo(widget.otherUid, _otherUser),
          new Flexible(
            child: new MessagesStreamConsumer(_messages),
          ),
          new Flexible(
            child: new Container(),
          ),
          new Flexible(
            child: new MorseKeyboard(_handlePressChange),
          ),
          _user == null ? new Container() : _buildUserInfo(widget.uid, _user),
        ],
      ),
    );
  }

  Widget _buildUserInfo(String uid, DataSnapshot snapshot) {
    String name = snapshot.value['displayName'];
    String photoUrl = snapshot.value['photoUrl'];

    return new Container(
      margin: new EdgeInsets.all(5.0),
      child: new Row(
        children: <Widget>[buildAvatar(photoUrl, uid), new Text(name)],
      ),
    );
  }

  void _handlePressChange(BinaryStatus newStatus, Duration previousDuration, DateTime timestamp) {
    bool pressed = newStatus == BinaryStatus.DOWN;
    widget.chatReference
        .child(widget.uid)
        .child(timestamp.millisecondsSinceEpoch.toString())
        .set({'minPreviousDuration': previousDuration?.inMilliseconds, 'pressed': pressed});
  }

  void _listenForChanges() {
//    widget.chatReference.child(widget.otherUid).remove();
    DatabaseReference otherMessages = widget.chatReference.child(widget.otherUid);
    otherMessages.orderByKey().onChildAdded.listen((Event event) {
      int timestamp = int.parse(event.snapshot.key);
      if (timestamp >= _startTimestamp) {
        print(event.snapshot.value);
        bool pressed = event.snapshot.value['pressed'];
        int minPreviousDuration = event.snapshot.value['minPreviousDuration'] ?? 0;
        setState(() {
          _messages.add(new Message(minPreviousDuration, pressed ? BinaryStatus.DOWN : BinaryStatus.UP));
        });
      }
      otherMessages.child(event.snapshot.key).remove();
      print('deleting ' + event.snapshot.key);
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimestamp = new DateTime.now().millisecondsSinceEpoch;
    _initUsers();
    _listenForChanges();
  }

  Future _initUsers() async {
    usersReference.child('${widget.uid}/info').once().then((result) => setState(() => _user = result));
    usersReference.child('${widget.otherUid}/info').once().then((result) => setState(() => _otherUser = result));
  }
}
