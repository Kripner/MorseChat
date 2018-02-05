import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:morse_chat/main.dart';
import 'package:morse_chat/utils.dart';
import 'package:path_provider/path_provider.dart';

enum SigningState { LOADING_NAME, ACCEPTING_NAME, VALIDATING_NAME, LOADING_FIREBASE }

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => new _SignInState();
}

class _SignInState extends State<SignIn> {
  SigningState state = SigningState.LOADING_NAME;
  TextEditingController nameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: getCurrentContent(),
        ),
      ),
    );
  }

  // most readable form I could think of
  List<Widget> getCurrentContent() {
    if (state == SigningState.LOADING_NAME) {
      return [new CircularProgressIndicator()];
    }
    if (state == SigningState.LOADING_FIREBASE) {
      return [
        new Text('Loading your chats'),
        new CircularProgressIndicator(),
      ];
    }
    if (state == SigningState.ACCEPTING_NAME) {
      return [
        new Text('Please choose a public name'),
        new TextField(
          controller: nameController,
          autocorrect: false,
          onSubmitted: handleNameSubmitted,
        ),
      ];
    }
    if (state == SigningState.VALIDATING_NAME) {
      return [
        new Text('Please choose a public name'),
        new CircularProgressIndicator(),
      ];
    }
    throw new Exception('Illegal state');
  }

  void handleNameSubmitted(String value) {
    setState(() => state = SigningState.VALIDATING_NAME);
    try {
      storeName(value);
    } on Exception {
      showTextSnackBar(context, 'Couldn\'t save the name, please try again');
      setState(() => state = SigningState.ACCEPTING_NAME);
      return;
    }
    userName = value;
  }

  @override
  void initState() {
    super.initState();
    loadName().then((String name) {
      if (name == null)
        setState(() => state = SigningState.ACCEPTING_NAME);
      else {
        userName = name;
        startLoading();
      }
    });
  }

  Future storeName(String value) async {
    try {
      File file = await getFile();
      file.writeAsStringSync(value);
      print('Name successfully stored!');
    } on FileSystemException {
      throw new Exception('Couldn\'t store the name');
    }
  }

  Future<String> loadName() async {
    try {
      File file = await getFile();
      String contents = await file.readAsString();
      return contents.length == 0 ? null : contents[0];
    } on FileSystemException {
      return null;
    }
  }

  Future<File> getFile() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/d.txt');
    return file;
  }

  void startLoading() {
    setState(() => state = SigningState.LOADING_FIREBASE);
    prepare().then((_) {
      print('Signed in!');
      Navigator.pushReplacementNamed(context, '/chat_list');
    });
  }

  Future prepare() async {
//    await FirebaseDatabase.instance.setPersistenceEnabled(true);
    await auth.signInAnonymously();
    FirebaseUser currentUser = await auth.currentUser();
    userReference = usersReference.child(currentUser.uid);
    chatListReference = userReference.child('chats');

    if ((await userReference.once()).value == null) {
      print('Setting up the profile in firebase');
      userReference.child('info/displayName').set(userName);
      // TODO: add user photo option
//      userReference.child('info/photoUrl').set(currentUser.photoUrl);
    }
  }
}
