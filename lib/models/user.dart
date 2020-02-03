import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils.dart';

class User {
  final String uid;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String profilePictureURL;
  final DateTime lastActivity;

  User({
    this.uid,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.lastActivity,
    this.profilePictureURL,
  });

  Map<String, Object> toJson() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'lastActivity': lastActivity,
      'email': email == null ? '' : email,
      'profilePictureURL': profilePictureURL
    };
  }

  factory User.fromJson(Map<String, Object> doc) {
    User user = new User(
      uid: doc['uid'],
      firstName: doc['firstName'],
      lastName: doc['lastName'],
      lastActivity: convertStamp(doc['lastActivity']),
      phone: doc['phone'],
      email: doc['email'],
      profilePictureURL: doc['profilePictureURL'],
    );
    return user;
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data);
  }
}
