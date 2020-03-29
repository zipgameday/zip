import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:zip/business/user.dart';

class MessageHandler extends StatefulWidget {
  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  UserService userService = UserService();
  
  StreamSubscription iosSubscription;

  @override
  void initState() {
      super.initState();
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

              Scaffold.of(context).showSnackBar(snackbar); 
            }

            showDialog(
                context: context,
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
    // Old method for reference
    /* _fcm.getToken().then((token) async {
          if (FirebaseAuth.instance.currentUser() != null) {
            if (token != null) {
              await Firestore.instance
                  .collection('users')
                  .document(userService.userID)
                  .updateData({'fcm_token': token});
              if (userService.user.isDriver == true) {
                await Firestore.instance.collection('drivers').document(userService.userID).updateData({
                  'fcm_token': token
                });
              }
            }
          }
        }); */
  }

  @override
  Widget build(BuildContext context) {
    return null;
  }
}