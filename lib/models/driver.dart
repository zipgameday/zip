import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils.dart';

class Driver {
  final String uid;
  final String firstName;
  final String lastName;
  final String profilePictureURL;
  final DateTime lastActivity;
  final LatLng position;
  final String fcm_token;

  Driver({
    this.uid,
    this.firstName,
    this.lastName,
    this.lastActivity,
    this.profilePictureURL,
    this.position,
    this.fcm_token
  });

  Map<String, Object> toJson() {
    return {
      'uid': uid,
      'firstName': firstName == null ? '' : firstName,
      'lastName': lastName == null ? '' : lastName,
      'lastActivity': lastActivity,
      'profilePictureURL': profilePictureURL == null ? '' : profilePictureURL,
      'position': position == null ? '' : position,
      'fcm_token': fcm_token == null ? '' : fcm_token,
    };
  }

  factory Driver.fromJson(Map<String, Object> doc) {
    Driver driver = new Driver(
      uid: doc['uid'],
      firstName: doc['firstName'],
      lastName: doc['lastName'],
      lastActivity: convertStamp(doc['lastActivity']),
      profilePictureURL: doc['profilePictureURL'],
      position: doc['position'],
      fcm_token: doc['fcm_token']
    );
    return driver;
  }

  factory Driver.fromDocument(DocumentSnapshot doc) {
    return Driver.fromJson(doc.data);
  }
}
