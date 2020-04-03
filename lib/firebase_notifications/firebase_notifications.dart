import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zip/business/drivers.dart';
import 'package:zip/business/user.dart';

class FirebaseNotifications {
  FirebaseMessaging _firebaseMessaging;
  UserService userService = UserService();

  void setUpFirebase() {
    _firebaseMessaging = FirebaseMessaging();
    firebaseCloudMessaging_Listeners();
  }

  void firebaseCloudMessaging_Listeners() async {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token) async {
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
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }
}
