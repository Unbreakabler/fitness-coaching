import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../common/firebase_globals.dart' as globals;
import '../user/user_data.dart';

class Client {
  Client();
  String coachId;
  String name;
  String trainingType;
  String email;
  bool activated = false;

  Client.fromMap(Map<String, dynamic> map)
    :
      coachId = map['coach_id'],
      name = map['name'],
      trainingType = map['training_type'],
      email = map['email'],
      activated = map['activated'];

  Map<String, dynamic> toMap() {
    return {
      'coach_id': coachId,
      'name': name,
      'training_type': trainingType,
      'email': email,
      'activated': activated,
    };
  }
}

class ClientCreateScreen extends StatefulWidget {
  ClientCreateScreen({this.users});

  final UserData users;

  @override
  ClientCreateState createState() => new ClientCreateState();
}

class ClientCreateState extends State<ClientCreateScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final Client client = new Client();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value)
    ));
  }

  bool _autovalidate = false;
  bool _formWasEdited = false;

  Future<Null> _handleSubmitted() async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true;  // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      final clientRef = globals.database.child('clients');
      client.coachId = globals.currentUser.id;
      print(client.toMap());
      await clientRef.push().set(client.toMap());
      showInSnackBar('${client.name} added as a ${client.trainingType} client');
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

  String _validateTrainingType(String value) {
    _formWasEdited = true;

    //TODO(jon): decide how to validate training types

    return null;
  }

  Future<bool> _warnUserAboutInvalidData() async {
    final FormState form = _formKey.currentState;
    if (form == null || !_formWasEdited || form.validate())
      return true;

    return await showDialog<bool>(
      context: context,
      child: new AlertDialog(
        title: const Text('This form has errors'),
        content: const Text('Really leave this form?'),
        actions: <Widget> [
          new FlatButton(
            child: const Text('YES'),
            onPressed: () { Navigator.of(context).pop(true); },
          ),
          new FlatButton(
            child: const Text('NO'),
            onPressed: () { Navigator.of(context).pop(false); },
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // return new AnimatedBuilder(
    //   animation: widget.users,
    //   builder: (BuildContext context, Widget child) {
        return new Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            title: new Text('Add New Client'),
          ),
          body: new SingleChildScrollView(
            child: new Container(
              margin: const EdgeInsets.all(20.0),
              child: new Card(
                child: new Form(
                  key: _formKey,
                  autovalidate: _autovalidate,
                  onWillPop: _warnUserAboutInvalidData,
                  child: new ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: <Widget>[
                      new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.person),
                          hintText: 'Use the clients full name',
                          labelText: 'Name *',
                        ),
                        validator: _validateName,
                        onSaved: (String value) { client.name = value;},
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.fitness_center),
                          hintText: 'ex: Powerlifting, bodybuilding, olympic lifting',
                          labelText: 'Training Type *',
                        ),
                        validator: _validateTrainingType,
                        onSaved: (String value) { client.trainingType = value;},
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.email),
                          hintText: 'Use the clients email',
                          labelText: 'Email *',
                        ),
                        validator: _validateEmail,
                        onSaved: (String value) { client.email = value;},
                      ),
                      new Container(
                        padding: const EdgeInsets.all(20.0),
                        alignment: Alignment.center,
                        child: new RaisedButton(
                          child: const Text('SUBMIT'),
                          onPressed: _handleSubmitted,
                        ),
                      ),
                      new Container(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: new Text('* indicates required field', style: Theme.of(context).textTheme.caption),
                      ),
                    ],
                  ),
                )
              ),
            )
          )
        );
    //   },
    // );
  }
}