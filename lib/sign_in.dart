import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:morse_chat/main.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => new _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Text('Signing in ...'),
    );
  }

  @override
  void initState() {
    super.initState();
    prepare().then((_) {
      print('Signed in!');
      Navigator.pushReplacementNamed(context, '/chat_list');
    });
  }

  Future prepare() async {
    await FirebaseDatabase.instance.setPersistenceEnabled(true);
    await auth.signInAnonymously();
    FirebaseUser currentUser = await auth.currentUser();
    userReference = usersReference.child(currentUser.uid);
    chatListReference = userReference.child('chats');

    if ((await userReference.once()).value == null) {
      print('Setting up name and photo URL');
      String displayName = currentUser.displayName == null || currentUser.displayName.isEmpty ? 'Anonymous' : currentUser.displayName;

      userReference.child('info/displayName').set(displayName);
      userReference.child('info/photoUrl').set(currentUser.photoUrl);
    }
  }
}
