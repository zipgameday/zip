import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class Ride {
  final String uid;
  final String drid;
  final GeoFirePoint destinationAddress;
  final GeoFirePoint pickupAddress;
  final String status;

  Ride({
    this.uid,
    this.drid,
    this.destinationAddress,
    this.pickupAddress,
    this.status
  });

  Map<String, Object> toJson() {
    return {
      'uid': uid,
      'drid': drid == null ? '' : drid,
      'destinationAddress': destinationAddress,
      'pickupAddress': pickupAddress,
      'status' : status,
    };
  }

  factory Ride.fromJson(Map<String, Object> doc) {
    Ride ride = new Ride(
      uid: doc['uid'],
      drid: doc['drid'],
      destinationAddress: extractGeoFirePoint(doc['destinationAddress']),
      pickupAddress: extractGeoFirePoint(doc['pickupAddress'])
    );
    return ride;
  }

  factory Ride.fromDocument(DocumentSnapshot doc) {
    return Ride.fromJson(doc.data);
  }

  static GeoFirePoint extractGeoFirePoint(Map<String, dynamic> pointMap) {
    GeoPoint point = pointMap['geopoint'];
    return GeoFirePoint(point.latitude, point.longitude);
  }
}
