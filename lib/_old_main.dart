import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'dart:io';
import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

final googleSignIn = new GoogleSignIn();
final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;

final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);


final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

void main() {
  runApp(new FriendlyChatApp());
}


class FriendlyChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'FriendlyChat',
      theme: defaultTargetPlatform == TargetPlatform.iOS
        ? kIOSTheme :
        kDefaultTheme,
      home: new ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  ChatScreenState createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final reference = FirebaseDatabase.instance.reference().child('messages');
  final TextEditingController _textController = new TextEditingController(); //new
  final ScrollController _scrollController = new ScrollController();
  StreamSubscription _subInit;
  StreamSubscription _subMessage;
  bool _isComposing = false;

  Future<Null> _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    await _ensureLoggedIn();
    _sendMessage(text: text);
  }

  Future<Null> _sendMessage({ String text, String imageUrl}) async {
    await reference.push().set({
      'text': text,
      'imageUrl': imageUrl,
      'senderName': googleSignIn.currentUser.displayName,
      'senderPhotoUrl': googleSignIn.currentUser.photoUrl,
    });
    analytics.logEvent(name: 'send_message');
    _subMessage = reference.onChildAdded.listen((onData) {
      new Timer(const Duration(milliseconds: 50), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut
        );
      });
    });
  }

  Future<Null> _ensureLoggedIn() async {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null) {
      user = await googleSignIn.signInSilently();
    }
    if (user == null) {
      await googleSignIn.signIn();
      analytics.logLogin();
    }
    if (await auth.currentUser() == null) {
      GoogleSignInAuthentication credentials = await googleSignIn.currentUser.authentication;
      await auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _subInit = reference.onChildAdded.listen((onData) {
      new Timer(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subInit.cancel();
    _subMessage.cancel();
  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Friendlychat"),
            elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: new Container(
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: new FirebaseAnimatedList(
                  query: reference,
                  padding: new EdgeInsets.all(8.0),
                  reverse: false,
                  controller: _scrollController,
                  // This isn't actually an error, the int index field is required for the app to run
                  itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, int index) {
                    return new ChatMessage(
                      snapshot: snapshot,
                      animation: animation,
                    );
                  }
                )
              ),
              new Divider(height: 1.0),
              new Container(
                decoration: new BoxDecoration(
                  color: Theme.of(context).cardColor
                ),
                child: _buildTextComposer(),
              ),
          ],
        ),
        decoration: Theme.of(context).platform == TargetPlatform.iOS
          ? new BoxDecoration(
              border: new Border(
                top: new BorderSide(
                  color: Colors.grey[200]
                )
              )
            )
          : null,
      )
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                icon: new Icon(Icons.photo_camera),
                onPressed: () async {
                  await _ensureLoggedIn();
                  File imageFile = await ImagePicker.pickImage();
                  int random = new Random().nextInt(100000);
                  StorageReference ref = FirebaseStorage.instance.ref().child("image_$random.jpg");
                  StorageUploadTask uploadTask = ref.put(imageFile);
                  Uri downloadUrl = (await uploadTask.future).downloadUrl;
                  _sendMessage(imageUrl: downloadUrl.toString());
                },
              ),
            ),
            new Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration: new InputDecoration.collapsed(
                    hintText: "Send a message"),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: Theme.of(context).platform == TargetPlatform.iOS ?
                new CupertinoButton(
                  child: new Text('Send'),
                  onPressed: _isComposing
                    ? () => _handleSubmitted(_textController.text)
                    : null,
                ) :
                new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: _isComposing
                    ? () => _handleSubmitted(_textController.text)
                    : null,
              ),
            )
          ]
        )
      )
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.snapshot, this.animation});
  final DataSnapshot snapshot;
  final Animation animation;

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut
      ),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(
                backgroundImage: 
                  new NetworkImage(snapshot.value['senderPhotoUrl']),
              ),
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  snapshot.value['senderName'],
                  style: Theme.of(context).textTheme.subhead
                ),
                new Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: snapshot.value['imageUrl'] != null
                    ? new Image.network(
                      snapshot.value['imageUrl'],
                      width: 250.0,
                    )
                    : new Text(
                      snapshot.value['text']
                    ),
                ),
              ],
            )
          ],
        )
      )
    );
  }
}