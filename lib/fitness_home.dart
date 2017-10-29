import 'package:flutter/material.dart';
import 'user_data.dart';
import 'main.dart';
import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart'; 

import 'user_list.dart';
import 'fitness_login.dart';
import 'firebase_globals.dart' as globals;

enum FitnessHomeTab { users, something, test }
enum _FitnessMenuItem { logout, nothing }

class FitnessHome extends StatefulWidget {
  FitnessHome(this.users);

  final UserData users;


  @override
  FitnessHomeState createState() => new FitnessHomeState();
}

class FitnessHomeState extends State<FitnessHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _handleFitnessMenu(BuildContext context, _FitnessMenuItem value) {
    switch (value) {
      case _FitnessMenuItem.logout: {
        globals.googleSignIn.disconnect();
        Navigator.pushReplacementNamed(context, '/');
        break;
      }
      default:
        break;
    }
  }

  Widget _buildAppBar() {
    return new AppBar(
      elevation: 2.0,
      title: new Text('Flutter Fitness'),
      actions: <Widget>[
        new PopupMenuButton<_FitnessMenuItem>(
          onSelected: (_FitnessMenuItem value) { _handleFitnessMenu(context, value); },
          itemBuilder: (BuildContext context) => <PopupMenuItem<_FitnessMenuItem>>[
            new PopupMenuItem(
              value: _FitnessMenuItem.nothing,
              child: const Text('Test 1')
            ),
            new PopupMenuItem(
              value: _FitnessMenuItem.nothing,
              child: const Text('Test 2')
            ),
            new PopupMenuItem(
              value: _FitnessMenuItem.logout,
              child: const Text('Logout'),
            )
          ],
        )
      ],
      bottom: new TabBar(
        tabs: <Widget>[
          new Tab(text: 'users'),
          new Tab(text: 'something'),
          new Tab(text: 'test'),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          const DrawerHeader(
            child: const Center(
              child: const Text('Fitness')
            )
          ),
          const ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            selected: true,
          ),
          const ListTile(
            leading: const Icon(Icons.details),
            title: const Text('Account Details'),
            enabled: false,
          ),
          new ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: _handleShowSettings,
          ),
        ],
      )
    );
  }

  void _handleShowSettings() {
    Navigator.popAndPushNamed(context, '/settings');
  }

  static Iterable<User> _getUserList(UserData users, Iterable<String> symbols) {
    return symbols.map<User>((String symbol) => users[symbol])
        .where((User user) => user != null);
  }

  Widget _buildUserTab(BuildContext context, FitnessHomeTab tab, Iterable<String> userSymbols) {
    return new AnimatedBuilder(
      key: new ValueKey<FitnessHomeTab>(tab),
      animation: new Listenable.merge(<Listenable>[widget.users]),
      builder: (BuildContext context, Widget child) {
        return _buildUserList(context, tab, _getUserList(widget.users, userSymbols));
      },
    );
  }

  Widget _buildUserList(BuildContext context, FitnessHomeTab tab, Iterable<User> users) {
    return new UserList(
      users: users.toList(),
      onAction: _expandUser,
      onOpen: (user) {
        Navigator.pushNamed(context, '/user:${user.symbol}');
      }
    );
  }

  void _expandUser(User user) {}

  static const List<String> somethingSymbols = const <String>["jon-boyd-2"];
  static const List<String> testSymbols = const <String>["jon-boyd-1", "jon-boyd-2", "jon-boyd-3"];

  Future<bool> _checkLoginStatus() async {
    globals.currentUser = globals.googleSignIn.currentUser;
    print(globals.currentUser);
    // return currentUser == null ? false : true;
    if (globals.currentUser == null) {
      globals.currentUser = await globals.googleSignIn.signInSilently();
    }
    if (globals.currentUser == null) {
      return false;
    } else if (await globals.auth.currentUser() == null) {
      GoogleSignInAuthentication credentials = await globals.googleSignIn.currentUser.authentication;
      await globals.auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
    }
    return true;
  }


  @override
  Widget build(BuildContext context) {
    Future<bool> loginStatus = _checkLoginStatus();
    return new FutureBuilder<bool>(
      future: loginStatus,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch (snapshot.connectionState) {
          default: {
            print('SNAPSHOT');
            print(snapshot);
            print(snapshot.connectionState);
            print(snapshot.data);
            // if (snapshot.hasData && !snapshot.data) {
            //   Navigator.pushNamed(context, '/login');
            // }
            if (snapshot.hasData && snapshot.data) {
              return new DefaultTabController(
                length: 3,
                child: new Scaffold(
                  key: _scaffoldKey,
                  appBar: _buildAppBar(),
                  drawer: _buildDrawer(context),
                  body: new TabBarView(
                    children: <Widget>[
                      _buildUserTab(context, FitnessHomeTab.users, widget.users.allSymbols),
                      _buildUserTab(context, FitnessHomeTab.something, somethingSymbols),
                      _buildUserTab(context, FitnessHomeTab.test, testSymbols),
                    ],
                  )
                )
              );
            } else {
              return new FitnessLogin();
            }
          }
        }
      },
    );
  }
}