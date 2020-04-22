import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:zip/business/user.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  BuildContext currentContext;
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  UserService userService = UserService();
  StreamSubscription iosSubscription;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    print("NotificationService Created");
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
          _saveDeviceToken();
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else { // Android
      _saveDeviceToken();
    }

    _fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");

          // Configure this if block to allow showing notifications as snackbar
          if(false) {
            final snackbar = SnackBar(
              content: Text(message['notification']['title']),
              action: SnackBarAction(
                label: 'Go',
                onPressed: () {
                  // Go to new page here or do something in a service etc
                }
              )
            );
            Scaffold.of(currentContext).showSnackBar(snackbar); 
          }

          showDialog(
            context: currentContext,
            builder: (context) => AlertDialog(
              content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
      },
      onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
      },
    );
  }

  void registerContext(BuildContext context) {
    this.currentContext = context;
  }

    /// Get the token, save it to the database for current user
  _saveDeviceToken() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String fcmToken = await _fcm.getToken();
    if (fcmToken != null) {
      var tokens = _db
          .collection('users')
          .document(user.uid)
          .collection('tokens')
          .document(fcmToken);
      await tokens.setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
        'platform': Platform.operatingSystem // optional
      });
    }
  }

}