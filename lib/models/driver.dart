import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import '../utils.dart';

class Driver {
  final String uid;
  final String firstName;
  final String lastName;
  final String profilePictureURL;
  final DateTime lastActivity;
  final String fcm_token;
  final bool isWorking;
  final bool isAvailable;
  final GeoFirePoint geoFirePoint;

  Driver({
    this.uid,
    this.firstName,
    this.lastName,
    this.lastActivity,
    this.profilePictureURL,
    this.geoFirePoint,
    this.fcm_token,
    this.isWorking,
    this.isAvailable
  });

  Map<String, Object> toJson() {
    return {
      'uid': uid,
      'firstName': firstName == null ? '' : firstName,
      'lastName': lastName == null ? '' : lastName,
      'lastActivity': lastActivity,
      'profilePictureURL': profilePictureURL == null ? '' : profilePictureURL,
      'geoFirePoint': geoFirePoint,
      'fcm_token': fcm_token == null ? '' : fcm_token,
      'isWorking': isWorking == null ? false : isWorking,
      'isAvailable': isAvailable == null ? false : isAvailable
    };
  }

  factory Driver.fromJson(Map<String, Object> doc) {
    Map<String, dynamic> geoMap = doc['geoFirePoint'];
    GeoPoint point = geoMap['geopoint'];
    Driver driver = new Driver(
      uid: doc['uid'],
      firstName: doc['firstName'],
      lastName: doc['lastName'],
      lastActivity: convertStamp(doc['lastActivity']),
      profilePictureURL: doc['profilePictureURL'],
      geoFirePoint: GeoFirePoint(point.latitude, point.longitude),
      fcm_token: doc['fcm_token'],
      isWorking: doc['isWorking'],
      isAvailable: doc['isAvailable'],
    );
    return driver;
  }

  factory Driver.fromDocument(DocumentSnapshot doc) {
    return Driver.fromJson(doc.data);
  }
}
