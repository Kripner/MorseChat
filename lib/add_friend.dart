import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morse_chat/main.dart';
import 'package:morse_chat/utils.dart';

class AddFriendDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text('Add friend'),
          bottom: new TabBar(isScrollable: false, tabs: <Tab>[
            new Tab(text: 'Get my code'),
            new Tab(text: 'Enter someone\'s code'),
          ]),
        ),
        body: new TabBarView(
          children: <Widget>[
            new GetMyCode(),
            new EnterCode(),
          ],
        ),
      ),
    );
  }
}

// TODO
const CODE_LENGTH = 3;

class EnterCode extends StatefulWidget {
  @override
  _EnterCodeState createState() => new _EnterCodeState();
}

class _EnterCodeState extends State<EnterCode> {
  final TextEditingController _textController = new TextEditingController();
  bool _searchingDatabase = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Text(_errorMessage),
        _buildTextField(),
      ],
    );
  }

  void _handleCodeChanged(String text) {
    setState(() => _errorMessage = '');

    if (text.length < CODE_LENGTH) return;
    if (text.length > CODE_LENGTH) {
      setState(() {
        _textController.text = text.substring(0, CODE_LENGTH);
      });
      return;
    }

    setState(() {
      _searchingDatabase = true;
      _textController.text = '';
    });
    _applyCode(text).whenComplete(() {
      setState(() {
        _searchingDatabase = false;
      });
    });
  }

  // TODO: apply timeout to the codes
  Future _applyCode(String code) async {
    DataSnapshot dataSnapshot = (await codesReference.child(code).once());
//    print(dataSnapshot); // might cause it to work

    if (dataSnapshot == null) {
      setState(() => _errorMessage = 'No such code found');
      return;
    }

    String creatorUid = dataSnapshot.value;
    String myUid = (await auth.currentUser()).uid;
//    if (creatorUid == myUid) {
//      setState(() => _errorMessage = 'You can\'t use your own code. Ask a friend to send you their.');
//      return;
//    }
    await codesReference.child(code).remove();
    await appliedCodesReference.child(code).set({
      'creatorUid': creatorUid,
      'acceptorUid': myUid,
    });
    print(myUid);
    print(creatorUid);

    Navigator.pop(context, true);
  }

  Widget _buildTextField() {
    ThemeData theme = Theme.of(context);
    TextField textField = new TextField(
      controller: _textController,
      onChanged: (String text) => _handleCodeChanged(text),
      decoration: new InputDecoration.collapsed(hintText: "Enter the code"),
      autocorrect: false,
      style: !_searchingDatabase
          ? null
          : theme.textTheme.subhead.copyWith(
              color: theme.disabledColor,
            ),
    );
    return !_searchingDatabase
        ? textField
        : new FocusScope(
            node: new FocusScopeNode(),
            child: textField,
          );
  }

  Future _handlePaste() async {
    String paste = (await Clipboard.getData(Clipboard.kTextPlain)).text;
    setState(() {
      _textController.text = paste;
    });
  }
}

class GetMyCode extends StatefulWidget {
  @override
  _GetMyCodeState createState() => new _GetMyCodeState();
}

class _GetMyCodeState extends State<GetMyCode> {
  static const Duration MIN_TIME_WAIT = const Duration(milliseconds: 3210);

  String currentCode;
  DateTime nextRegenerationAvailable;

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(currentCode),
            new IconButton(icon: new Icon(Icons.content_copy), onPressed: _handleCopyCode),
          ],
        ),
        new FlatButton(
          onPressed: _generateNewCode,
          child: new Text('Generate new code'),
        )
      ],
    );
  }

  void _generateNewCode() {
    if (nextRegenerationAvailable != null && (new DateTime.now()).isBefore(nextRegenerationAvailable)) {
      showTextSnackBar(context, 'Please use this code first');
      return;
    }
    nextRegenerationAvailable = new DateTime.now().add(MIN_TIME_WAIT);
    Random r = new Random();
    int a = 'a'.codeUnitAt(0);
    int z = 'z'.codeUnitAt(0);
    String code = new String.fromCharCodes(
      new List.generate(CODE_LENGTH, (_) => r.nextInt(z - a + 1) + a),
    );

    setState(() {
      currentCode = code;
    });
    _saveCode(code);
  }

  Future _saveCode(String code) async {
    print(code);
    String userUid = (await auth.currentUser()).uid;
    codesReference.child(code).set(userUid);
  }

  void _handleCopyCode() {
    Clipboard.setData(new ClipboardData(text: currentCode));
    showTextSnackBar(context, 'Code copied to clipboard');
  }

  @override
  void initState() {
    super.initState();
    _generateNewCode();
  }
}
