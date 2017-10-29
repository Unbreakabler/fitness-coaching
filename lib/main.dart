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

import 'fitness_user.dart';
import 'fitness_settings.dart';
import 'fitness_home.dart';
import 'fitness_login.dart';
import 'user_data.dart';

import 'firebase_globals.dart' as globals;

// final googleSignIn = new GoogleSignIn();
// final analytics = new FirebaseAnalytics();
// final auth = FirebaseAuth.instance;

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
  runApp(new FlutterFitness());
}

class FlutterFitness extends StatefulWidget {
  @override
  FlutterFitnessState createState() => new FlutterFitnessState();
}

class FlutterFitnessState extends State<FlutterFitness> {

  UserData users;

  @override
  void initState() {
    super.initState();
    users = new UserData();
  }

  Route<Null> _getRoute(RouteSettings settings) {
    final List<String> path = settings.name.split('/');

    if (path[0] != '')
      return null;

    if (path[1].startsWith('user:')) {
      if (path.length != 2) {
        return null;
      }
      final String symbol = path[1].substring(5);
      return new MaterialPageRoute(
        settings: settings,
        builder: (BuildContext context) => new FitnessUserPage(symbol: symbol, users: users),
      );
    }

    return null;
  }


  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Fitness',
      theme: new ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.orangeAccent[400],
      ),
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) => new FitnessHome(users),
        '/settings': (BuildContext context) => new FitnessSettings(users),
        '/login': (BuildContext context) => new FitnessLogin(),
      },
      onGenerateRoute: _getRoute,
    );
  }
}