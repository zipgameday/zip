import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils.dart';

class Rides {
  final String rid;
  final String drid;
  final String csid;
  final String destination;
  final String start;

  Rides({
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

  factory Rides.fromJson(Map<String, Object> doc) {
    Rides rides = new Rides(
      rid: doc['rid'],
      drid: doc['drid'],
      csid: doc['csid'],
      destination: doc['destination'],
      start: doc['start']
    );
    return rides;
  }

  factory Rides.fromDocument(DocumentSnapshot doc) {
    return Rides.fromJson(doc.data);
  }
}
