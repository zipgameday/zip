import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils.dart';

class User {
  final String uid;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String profilePictureURL;
  final num credits;
  final String homeAddress;
  final DateTime lastActivity;

  User({
    this.uid,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.credits,
    this.homeAddress,
    this.lastActivity,
    this.profilePictureURL,
  });

  Map<String, Object> toJson() {
    return {
      'uid': uid,
      'firstName': firstName == null ? '' : firstName,
      'lastName': lastName == null ? '' : lastName,
      'phone': phone == null ? '' : phone,
      'lastActivity': lastActivity,
      'email': email == null ? '' : email,
      'credits': credits == null ? 0 : credits,
      'homeAddress': homeAddress == null ? '' : homeAddress,
      'profilePictureURL': profilePictureURL == null ? '' : profilePictureURL
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
      credits: doc['credits'],
      homeAddress: doc['homeAddress'],
      profilePictureURL: doc['profilePictureURL'],
    );
    return user;
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data);
  }
}
