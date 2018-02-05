import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:morse_chat/add_friend.dart';
import 'package:morse_chat/conversation.dart';
import 'package:morse_chat/main.dart';
import 'package:morse_chat/user_utils.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => new _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Padding(
        padding: new EdgeInsets.only(top: 20.0),
        child: new FirebaseAnimatedList(
          query: chatListReference,
          sort: (a, b) => (b.value['lastInteraction'] as int).compareTo(a.value['lastInteraction'] as int),
          padding: new EdgeInsets.all(8.0),
          itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation) {
            return new ChatTile(
              snapshot: snapshot,
              animation: animation,
            );
          },
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _handleAddFriend,
        child: new Icon(Icons.person_add),
      ),
    );
  }

  void _handleAddFriend() {
    showDialog(context: context, child: new AddFriendDialog()).then((success) {
      // causes non-understandable issues (see https://docs.flutter.io/flutter/material/Scaffold/of.html)
//      if (success) showTextSnackBar(context, 'Friend successfully added!');
    });
  }
}

class ChatTile extends StatefulWidget {
  final DataSnapshot snapshot;
  final Animation animation;

  ChatTile({this.snapshot, this.animation});

  @override
  State<StatefulWidget> createState() {
    return new ChatTileState();
  }
}

class ChatTileState extends State<ChatTile> {
  @override
  Widget build(BuildContext context) {
    final participantUid = widget.snapshot.value['participantUid'];
    final participantName = widget.snapshot.value['participantName'];
    final participantPhotoUrl = widget.snapshot.value['participantPhotoUrl'];
    final lastInteraction = new DateTime.fromMillisecondsSinceEpoch(widget.snapshot.value['lastInteraction']);

    return new FadeTransition(
        opacity: new CurvedAnimation(
          parent: widget.animation,
          curve: Curves.easeOut,
        ),
        child: new GestureDetector(
          onTap: _handleOpenConversation,
          child: new Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildAvatar(participantPhotoUrl, participantUid),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(participantName, style: Theme.of(context).textTheme.subhead),
                    new Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      child: new Text(_formatDateTime(lastInteraction)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}. ${dateTime.month.toString().padLeft(2, '0')}. ${dateTime.year
        .toString()}";
  }

  Future _handleOpenConversation() async {
    String uid = (await auth.currentUser()).uid;
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) {
        return new Conversation(uid, widget.snapshot.value['participantUid']);
      }),
    );
  }
}
