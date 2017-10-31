import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';

import '../client/client_create.dart';
import '../client/client_pending_list.dart';
import 'fitness_login.dart';
import '../user/user_list.dart';
import '../user/user_data.dart';
import '../common/firebase_globals.dart' as globals;

enum FitnessHomeTab { users, clients, test }
enum _FitnessMenuItem { logout, nothing }

class FitnessHome extends StatefulWidget {
  FitnessHome(this.users);
  final UserData users;

  @override
  FitnessHomeState createState() => new FitnessHomeState();
}

class FitnessHomeState extends State<FitnessHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DataSnapshot _clients;

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

  // List of pending clients, people that have been added by email/name
  // but have no yet created an account
  // TODO(jon): Create the ability for the coach to renotify this client 
  Widget _buildPendingList(BuildContext context, FitnessHomeTab tab, Map<String, dynamic> clients) {
    List<Client> pendingList = new List();
    clients.forEach((k,v) {
      pendingList.add(new Client.fromMap(v));
    });
    return new PendingClientList(
      clients: pendingList,
      // onAction: _expandUser,
      // onOpen: (user) {
      //   Navigator.pushNamed(context, '/user:${user.symbol}');
      // }
    );
  }

  Future<Null> _fetchClients() async {
    var clients = await globals.database.child('clients').orderByChild('coach_id').equalTo(globals.currentUser.id).once();
    // print(clients.value);
    setState(() {
      _clients = clients;
    });
  }

  Widget _buildTab(BuildContext context, FitnessHomeTab tab, Iterable<String> userSymbols) {
    switch (tab) {
      case FitnessHomeTab.clients:
        return new AnimatedBuilder(
          key: new ValueKey<FitnessHomeTab>(tab),
          animation: new Listenable.merge(<Listenable>[widget.users]),
          builder: (BuildContext context, Widget child) {
            return _buildPendingList(context, tab, _clients.value);
          },
        );
        break;
      case FitnessHomeTab.users:
      case FitnessHomeTab.test:
      default: {
        return new AnimatedBuilder(
          key: new ValueKey<FitnessHomeTab>(tab),
          animation: new Listenable.merge(<Listenable>[widget.users]),
          builder: (BuildContext context, Widget child) {
            return _buildUserList(context, tab, _getUserList(widget.users, userSymbols));
          },
        );
      }
    }
    
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

  Widget _buildFloatingActionButton(BuildContext context) {
    return new FloatingActionButton(
      tooltip: 'Add user',
      child: const Icon(Icons.add),
      backgroundColor: Theme.of(context).accentColor,
      onPressed: _handleCreateUser,
    );
  }

  void _handleCreateUser() {
    Navigator.pushNamed(context, '/addclient');
  }

  void _expandUser(User user) {}

  static const List<String> somethingSymbols = const <String>["jon-boyd-2"];
  static const List<String> testSymbols = const <String>["jon-boyd-1", "jon-boyd-2", "jon-boyd-3"];

  Future<bool> _checkLoginStatus() async {
    globals.currentUser = globals.googleSignIn.currentUser;
    if (globals.currentUser == null) {
      globals.currentUser = await globals.googleSignIn.signInSilently();
    }
    if (globals.currentUser == null) {
      return false;
    } else if (await globals.auth.currentUser() == null) {
      globals.analytics.logLogin();
      GoogleSignInAuthentication credentials = await globals.googleSignIn.currentUser.authentication;
      await globals.auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
    }
    await _fetchClients();
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
            if (snapshot.hasData && snapshot.data) {
              return new DefaultTabController(
                length: 3,
                child: new Scaffold(
                  key: _scaffoldKey,
                  appBar: _buildAppBar(),
                  floatingActionButton: _buildFloatingActionButton(context),
                  drawer: _buildDrawer(context),
                  body: new TabBarView(
                    children: <Widget>[
                      _buildTab(context, FitnessHomeTab.users, widget.users.allSymbols),
                      _buildTab(context, FitnessHomeTab.clients, null),
                      _buildTab(context, FitnessHomeTab.test, testSymbols),
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