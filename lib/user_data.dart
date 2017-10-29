import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// enum TrainingType { powerlifting, bodybuilding, weightloss, weightlifting, hybrid}

class User {
  String symbol;
  String name;
  String trainingType;
  List<double> weight;
  String liftUnit;
  String profilePicture;
  List<String> progressPictures;
  DateTime lastUserUpdate;
  DateTime lastContact;
  bool pendingUpdate;
  Map<String, List<double>> lifts;

  User.fromFields(Map<String, dynamic> fields) {
    symbol = fields['symbol'];
    name = fields['name'];
    trainingType = fields['trainingType'];
    weight = fields['weight'];
    liftUnit = fields['liftUnit'];
    // profilePicture = fields['profilePicture'];
    progressPictures = fields['progressPictures'];
    lastUserUpdate = DateTime.parse(fields['lastUserUpdate']);
    lastContact = DateTime.parse(fields['lastContact']);
    pendingUpdate = fields['pendingUpdate'];
    lifts = fields['lifts'];
  }
}

class UserData extends ChangeNotifier {
  UserData() {
    if (useLocalData) {
      _fetchLocalData();
    } else {
      _httpClient = createHttpClient();
      _fetchUserData();
    }
  }

  final List<String> _symbols = <String>[];
  final Map<String, User> _users = <String, User>{};
  http.Client _httpClient;
  static bool useLocalData = true;

  Iterable<String> get allSymbols => _symbols;
  bool get loading => _httpClient != null;

  User operator [](String symbol) => _users[symbol];

  void add(List<Map<String, dynamic>> data) {
    for (Map<String, dynamic> fields in data) {
      final User user = new User.fromFields(fields);
      _symbols.add(user.symbol);
      _users[user.symbol] = user;
    }
    _symbols.sort();
    notifyListeners();
  }

  // TODO(jon): implement once firebase has user data stored
  void _fetchUserData() {
    _end();
  }

  Future<Null> _fetchLocalData() async {
    final JsonDecoder decoder = const JsonDecoder();
    final data = await rootBundle.loadString('lib/data.json');
    add(decoder.convert(data));
  }

  void _end() {
    _httpClient?.close();
    _httpClient = null;
  }
}