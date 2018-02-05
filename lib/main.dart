import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:morse_chat/chat_list.dart';
import 'package:morse_chat/sign_in.dart';

final googleSignIn = new GoogleSignIn();
final auth = FirebaseAuth.instance;

final DatabaseReference codesReference = FirebaseDatabase.instance.reference().child('codes');
final DatabaseReference appliedCodesReference = FirebaseDatabase.instance.reference().child('applied_codes');
final DatabaseReference chatsReference = FirebaseDatabase.instance.reference().child('chats');
final DatabaseReference usersReference = FirebaseDatabase.instance.reference().child('users');
DatabaseReference userReference;
DatabaseReference chatListReference;

String userName;

void main() {
  runApp(new GreatestAppEver());
}

class GreatestAppEver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Morse chat',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new SignIn(),
      routes: <String, WidgetBuilder> {
        '/chat_list': (BuildContext context) => new ChatList(),
      },
    );
  }
}
