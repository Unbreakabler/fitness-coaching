import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';

import '../client/client_create.dart';
import '../common/firebase_globals.dart' as globals;
import '../user/user_data.dart';

class SignIn {
  String email;
  String password;
}

class SignUp {
  String email;
  String name;
  String password;
  String passwordTwo;
}

class FitnessLogin extends StatefulWidget {
  FitnessLogin();

  @override
  FitnessLoginState createState() => new FitnessLoginState();
}

class FitnessLoginState extends State<FitnessLogin> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

    void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value)
    ));
  }

  bool _showRegisterForm = false;
  bool _autovalidate = false;
  bool _formWasEdited = false;
  SignIn _signIn = new SignIn();
  SignUp _signUp = new SignUp();

  Future<Null> _handleLogin(BuildContext context) async {
    // Ask user to login with google
    final userRef = globals.database.child('users');
    globals.currentUser = await globals.googleSignIn.signIn(); 
    
    String uid;

    if (await globals.auth.currentUser() == null) {
      GoogleSignInAuthentication credentials = await globals.googleSignIn.currentUser.authentication;
      await globals.auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
    }
  
    // fetch authed user again, if it now exist we are going to save that user to the db
    final user = await globals.auth.currentUser();
    if (user != null) {
      uid = user.uid;
      var dbuser = await userRef.orderByChild('uid').equalTo(uid).once();
      if (dbuser.value == null) {
        await userRef.push().set({
          'uid': uid,
          'id': globals.currentUser.id,
          'displayName': globals.currentUser.displayName,
          'photoUrl': globals.currentUser.photoUrl,
          'email': globals.currentUser.email,
        });
      }
    }

    // if successfully signed in close the login screen
    if (globals.currentUser != null) {
      // if user successfully logged in fire analytics event
      globals.analytics.logLogin();
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  String _validateName(String value) {
    _formWasEdited = true;
    if (value.isEmpty)
      return 'Name is required.';
    final RegExp nameExp = new RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value))
      return 'Please enter only alphabetical characters.';
    return null;
  }

  String _validateEmail(String value) {
    _formWasEdited = true;
    final RegExp emailExp = new RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (!emailExp.hasMatch(value))
      return 'Please enter a valid email address.';
    return null;
  }


  Future<Null> _handleRegister() async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true;  // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else if (_showRegisterForm) {
      form.save();
      var user = await globals.auth.createUserWithEmailAndPassword(email: _signUp.email, password: _signUp.password)
        .catchError((onError) {
          print(onError);
        });
      if (user != null) {
        globals.database.child('users').push().set({
          'uid': user.uid,
          'email': user.email,
          'displayName': _signUp.name,
        });

        var ref = await globals.database.child('clients').orderByChild('email').equalTo(_signUp.email).limitToFirst(1).once();

        if (ref.value != null) {
          ref.value.forEach((k,v) {
            globals.database.child('clients').child(k).update({
              'client_uid': user.uid
            });
          });
        }
        showInSnackBar('${user.email} registered as a new user!');
      }
    }
  }

  void _doNothing() {}

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Login'),
        leading: null,
      ),
      body: new SingleChildScrollView(
        child: new Container(
          margin: const EdgeInsets.all(20.0),
          child: new Card(
            // title: const Text('Sign in'),
            child: new ListView(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: <Widget>[
                new Form(
                  key: _formKey,
                  autovalidate: _autovalidate,
                  child : new ListView(
                    padding: const EdgeInsets.all(10.0),
                    shrinkWrap: true,
                    children: _showRegisterForm ? <Widget>[
                      const Text(
                        'Sign up',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24.0),
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                        validator: _validateEmail,
                        onSaved: (String value) {
                          _signUp.email = value;
                        },
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                        validator: _validateName,
                        onSaved: (String value) {
                          _signUp.name = value;
                        },
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'password',
                        ),
                        onSaved: (String value) {
                          _signUp.password = value;
                        },
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Re-enter password',
                        ),
                        onSaved: (String value) {
                          _signUp.passwordTwo = value;
                        },
                      )
                    ] : <Widget>[
                      const Text(
                        'Sign in',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24.0),
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                        validator: _validateEmail,
                        onSaved: (String value) {
                          _signIn.email = value;
                        },
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'password',
                        ),
                        onSaved: (String value) {
                          _signIn.password = value;
                        },
                      )
                    ]
                  )
                ),
                const Divider(),
                new AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstChild: new Row( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Column(
                        children: <Widget>[
                          new RaisedButton(
                            onPressed: () {
                              setState(() {
                                _showRegisterForm = true;
                              });
                            },
                            child: new Text(
                              'Register with email',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.button,
                            ),
                          ),
                          new RaisedButton(
                            onPressed: () async { 
                              await _handleLogin(context);
                            },
                            child: new Text(
                              'Sign in with Google',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.button,
                            ),
                          ),
                          new RaisedButton(
                            onPressed: () async { 
                              await globals.googleSignIn.signIn(); 
                            },
                            child: new Text(
                              'Sign in with Facebook',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.button,
                            ),
                          ),
                        ],
                      ),
                    ]
                  ),
                  secondChild: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new RaisedButton(
                        onPressed: _handleRegister,
                        child: const Text(
                          'Register Account'
                        ),
                      ),
                      new RaisedButton(
                        onPressed: () {
                          setState(() {
                            _showRegisterForm = false;
                          });
                        },
                        child: const Text(
                          'Return to sign in'
                        ),
                      ),  
                    ],
                  ),
                  crossFadeState: _showRegisterForm ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                ),
              ],
            )
          )
        ),
      )
    );
  }
}