import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zip/business/drivers.dart';
import 'package:zip/business/location.dart';
import 'package:zip/business/user.dart';
import 'package:zip/models/driver.dart';
import 'package:zip/models/rides.dart';

class RideService {
  static final RideService _instance = RideService._internal();
  final Firestore _firestore = Firestore.instance;
  CollectionReference rideCollection;
  DocumentReference rideReference;
  DocumentSnapshot myRide;

  // Services
  Geoflutterfire geo = Geoflutterfire();
  LocationService locationService = LocationService();
  DriverService driverService = DriverService();
  UserService userService = UserService();

  // Subscriptions
  StreamSubscription<Position> locationSub;
  Stream<List<DocumentSnapshot>> nearbyDrivers;

  Ride ride;
  StreamSubscription<Ride> rideSub;

  factory RideService() {
    return _instance;
  }

  RideService._internal() {
    print("RideService Created");
    rideCollection = _firestore.collection('rides');
    rideReference = _firestore.collection('rides').document(userService.userID);
  }

  Future<bool> setupService() async {
    myRide = await rideReference.get();
  }

  /// This function will start the ride process between a customer
  /// and a driver. It gets the current location of the user and
  /// passes it into the pickupAddress field of the ride document
  /// it also gets the destination address and passes it into the
  /// destinationAddress field.
  void startRide(double lat, double long) async {
    GeoFirePoint destination = GeoFirePoint(lat, long);
    GeoFirePoint pickup = locationService.getCurrentGeoFirePoint();

    if (!myRide.exists) {
      rideReference.setData({
        'uid': userService.userID,
        'drid': '',
        'lastActivity': DateTime.now(),
        'pickupAddress': pickup.data,
        'destinationAddress': destination.data,
        'status': "SEARCHING"
      });
    } else {
      rideReference.updateData({
        'uid': userService.userID,
        'drid': '',
        'lastActivity': DateTime.now(),
        'pickupAddress': pickup.data,
        'destinationAddress': destination.data,
        'status': "SEARCHING"
      });
    }
  }

/**
 * This function is for cancelling a ride
 * This simply updates the database to show the status
 * of the ride to be canceled
 */
  void cancelRide() {
    rideReference.updateData({
      'lastActivity': DateTime.now(),
      'status': "CANCELED",
    });
  }

  /**
   * This function returns a stream of ride objects from the database.
   */
  Stream<Ride> getRideStream() {
    return rideReference.snapshots()
        .map((snapshot) {
      return Ride.fromDocument(snapshot);
    });
  }
}