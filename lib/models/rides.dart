import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils.dart';

class Ride {
  final String rid;
  final String drid;
  final String csid;
  final String destination;
  final String start;

  Ride({
    this.rid,
    this.drid,
    this.csid,
    this.destination,
    this.start,
  });

  Map<String, Object> toJson() {
    return {
      'uid': rid,
      'drid': drid == null ? '' : drid,
      'csid': csid == null ? '' : csid,
      'destination': destination == null ? '' : destination,
      'start': start == null ? '' : start,
    };
  }

  factory Ride.fromJson(Map<String, Object> doc) {
    Ride ride = new Ride(
      rid: doc['rid'],
      drid: doc['drid'],
      csid: doc['csid'],
      destination: doc['destination'],
      start: doc['start']
    );
    return ride;
  }

  factory Ride.fromDocument(DocumentSnapshot doc) {
    return Ride.fromJson(doc.data);
  }
}
