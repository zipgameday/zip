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
  DocumentReference driverReference;
  UserService userService = UserService();
  Stream<List<DocumentSnapshot>> nearbyDrivers;
  Stream<User> userStream;
  User user;
  GeoFirePoint myLocation;
  Driver driver;
  StreamSubscription<Driver> driverSub;

  factory DriverService() {
    return _instance;
  }

  DriverService._internal() {
    print("DriverService Created");
    driversCollection = _firestore.collection('drivers');
  }

  Future<bool> setupService() async {
    // Create Driver object in database if doesnt exist
    driverReference = driversCollection.document(userService.userID);
    DocumentSnapshot myDriverRef = await driverReference.get();
    if (!myDriverRef.exists) {
      driversCollection.document(userService.userID).setData({
        'uid': userService.userID,
        'lastActivity': DateTime.now(),
        'isAvailable': false,
        'isWorking': false
      });
    }
    // Subscribe to the DriverReference and update Driver object: driver
    this.driverSub =
        driverReference.snapshots().map((DocumentSnapshot snapshot) {
      return Driver.fromDocument(snapshot);
    }).listen((driver) {
      this.driver = driver;
    });

    // Subscribe to locationService to update Driver object's position on change.
    if (locationSub != null) locationSub.cancel();
    locationSub = locationService.positionStream.listen(updatePosition);
    print("DriverService setup");
    return true;
  }

  void updatePosition(Position pos) {
    this.myLocation = geo.point(latitude: pos.latitude, longitude: pos.longitude);
    if(driver != null) {
      if (driver.isWorking) {
        // TODO: Check for splitting driver and position into seperate documents in firebase as an optimization
        driverReference
          .updateData({'lastActivity': DateTime.now(), 'geoFirePoint': myLocation.data});
      }
    }
  }

  bool answerRequest(bool answer, String requestID) {
    return false;
  }

  void startDriving() {
    driverReference.updateData({
      'lastActivity': DateTime.now(),
      'isAvailable': true,
      'isWorking': true
    });
  }

  void stopDriving() {
    driverReference.updateData({
      'lastActivity': DateTime.now(),
      'isAvailable': false,
      'isWorking': false
    });
  }

  Stream<Driver> getDriverStream() {
    return _firestore
        .collection('drivers')
        .document(userService.userID)
        .snapshots()
        .map((snapshot) {
      return Driver.fromDocument(snapshot);
    });
  }

  // TODO: Fix with Dillon
  Stream<List<Driver>> getNearbyDrivers() {
    if (nearbyDrivers == null) {
      nearbyDrivers = geo
          .collection(collectionRef: driversCollection)
          .within(center: myLocation, radius: 50, field: 'geoFirePoint');
    }
    List<Driver> drivers = List<Driver>();
  }
}
