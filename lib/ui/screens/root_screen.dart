import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zip/models/user.dart';
import 'package:zip/ui/screens/welcome_screen.dart';
import 'package:zip/ui/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RootScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return new Container(
            color: Colors.white,
          );
        } else {
          if (snapshot.hasData) {
            return MultiProvider(
              providers: [
                StreamProvider<User>.value(value: Firestore.instance.collection('users')
                  .document(snapshot.data.uid).snapshots().map((snap) => User.fromDocument(snap))),
              ],
              child: MainScreen(),
              );
          } else {
            return WelcomeScreen();
          }
        }
      },
    );
  }
}
