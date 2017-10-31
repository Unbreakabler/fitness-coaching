import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'core/fitness_user.dart';
import 'core/fitness_settings.dart';
import 'core/fitness_home.dart';
import 'core/fitness_login.dart';
import 'user/user_data.dart';
import 'client/client_create.dart';

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
      // TODO(jon): switch theme based on device (ios/android)
      theme: new ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.orangeAccent[400],
      ),
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) => new FitnessHome(users),
        '/settings': (BuildContext context) => new FitnessSettings(users),
        '/login': (BuildContext context) => new FitnessLogin(),
        '/addclient': (BuildContext context) => new ClientCreateScreen(),
      },
      onGenerateRoute: _getRoute,
    );
  }
}