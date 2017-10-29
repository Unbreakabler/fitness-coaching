import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

final googleSignIn = new GoogleSignIn();
final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;
GoogleSignInAccount currentUser;