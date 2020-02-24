import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zip/models/user.dart';


class UserService {
  static final UserService _instance = UserService._internal();
  final Firestore _db = Firestore.instance;
  String userID = '';
  Stream<User> userStream;
  User user;

  factory UserService() {
    return _instance;
  }

  UserService._internal() {
    print("UserService Created with user: $userID");
  }

  void setupService(String id) {
    if(userID == '') {
      userID = id;
      userStream = _db
          .collection("users")
          .document(userID)
          .snapshots()
          .map((DocumentSnapshot snapshot) {
        return User.fromDocument(snapshot);
      });
      userStream.listen((user) {
        this.user = user;
      });
      print("UserService setup with user: $userID");
    }
  }

  Stream<User> getUserStream() {
    return _db
        .collection("users")
        .document(userID)
        .snapshots()
        .map((DocumentSnapshot snapshot) {
      return User.fromDocument(snapshot);
    });
  }
}
