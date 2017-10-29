import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart'; 

import 'firebase_globals.dart' as globals;

class FitnessLogin extends StatelessWidget {
  FitnessLogin();

  Future<Null> _handleLogin(BuildContext context) async {
    // Ask user to login with google
    globals.currentUser = await globals.googleSignIn.signIn(); 
    globals.analytics.logLogin();
    
    // Try to auth with firebase
    if (await globals.auth.currentUser() == null) {
      GoogleSignInAuthentication credentials = await globals.googleSignIn.currentUser.authentication;
      await globals.auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
    }
  
    // if successfully signed in close the login screen
    if (globals.currentUser != null) {
      Navigator.pushReplacementNamed(context, '/');
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Login'),
        leading: null,
      ),
      body: new SingleChildScrollView(
        child: new Container(
          margin: const EdgeInsets.all(20.0),
          child: new SimpleDialog(
            title: const Text('Sign in'),
            children: <Widget>[
              new SimpleDialogOption(
                onPressed: () async { 
                  await _handleLogin(context);
                },
                child: const Text('Sign in with Google'),
              ),
              new SimpleDialogOption(
                onPressed: () async { 
                  await globals.googleSignIn.signIn(); 
                },
                child: const Text('Sign in with Facebook'),
              ),
            ],
          )
        ),
      )
    );
  }
}