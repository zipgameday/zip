import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zip/business/location.dart';
import 'package:zip/business/user.dart';
import 'package:zip/models/driver.dart';
import 'package:zip/models/user.dart';

class DriverService {
  static final DriverService _instance = DriverService._internal();
  final Firestore _firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  LocationService locationService = LocationService();
  StreamSubscription<Position> locationSub;
  CollectionReference driversCollection;
  UserService userService = UserService();
  Stream<List<DocumentSnapshot>> nearbyDrivers;
  Stream<User> userStream;
  User user;
  GeoFirePoint myLocation;



  factory DriverService() {
    return _instance;
  }

  DriverService._internal() {
    print("DriverService Created");
    driversCollection = _firestore.collection('drivers');
    setupService();
  }

  void setupService() {
    if(locationSub != null) locationSub.cancel();
    locationSub = locationService.positionStream.listen(updatePosition);
    print("DriverService setup");
  }

  void updatePosition(Position pos) {
    this.myLocation = geo.point(latitude: pos.latitude, longitude: pos.longitude);
  }

  void startDriving() async {
    DocumentSnapshot myDriverRef = await _firestore.collection('drivers').document(userService.userID).get();
    if(myDriverRef.exists) {
      _firestore
        .collection('drivers').document(userService.userID).updateData(
          {
            'lastActivity': DateTime.now(),
            'position': myLocation.data,
            'available': true,
            'working': true
          });
    } else {
      _firestore.collection('drivers').add({
        'uid': userService.userID,
        'lastActivity': DateTime.now(),
        'position': myLocation.data,
        'available': true,
        'working': true
      });
    }
  }

  Stream<List<Driver>> getNearbyDrivers() {
    if(nearbyDrivers == null) {
      nearbyDrivers = geo.collection(collectionRef: driversCollection)
        .within(center: myLocation, radius: 50, field: 'position');
    }
    List<Driver> drivers = new List<Driver>();
  }
}
