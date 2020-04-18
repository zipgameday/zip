import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zip/business/drivers.dart';
import 'package:zip/business/location.dart';
import 'package:zip/business/user.dart';
import 'package:zip/models/driver.dart';
import 'package:zip/models/request.dart';
import 'package:zip/models/rides.dart';

class RideService {
  static final RideService _instance = RideService._internal();
  final Firestore _firestore = Firestore.instance;
  CollectionReference rideCollection;
  DocumentReference rideReference;
  DocumentSnapshot myRide;
  bool isSearchingForRide;
  bool goToNextDriver;
  Stream<Ride> rideStream;
  StreamSubscription rideSubscription;

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
    GeoFirePoint destination = geo.point(latitude: lat, longitude: long);
    GeoFirePoint pickup = locationService.getCurrentGeoFirePoint();
    if (!myRide.exists) {
      await rideReference.setData({
        'uid': userService.userID,
        'drid': '',
        'lastActivity': DateTime.now(),
        'pickupAddress': pickup.data,
        'destinationAddress': destination.data,
        'status': "SEARCHING"
      });
    } else {
      await rideReference.updateData({
        'uid': userService.userID,
        'drid': '',
        'lastActivity': DateTime.now(),
        'pickupAddress': pickup.data,
        'destinationAddress': destination.data,
        'status': "SEARCHING"
      });
    }

    Stream<Ride> rideStream = rideReference.snapshots().map((snapshot) => Ride.fromDocument(snapshot)).asBroadcastStream();
    rideSubscription = rideStream.listen((event) {
      if(event.status != null) {
        switch (event.status) {
          case 'CANCELED':
            isSearchingForRide = false;
            print("Ride is canceled");
            break;
          case 'IN_PROGRESS':
            isSearchingForRide = false;
            print("Ride is now IN_PROGRESS");
            break;
          case 'SEARCHING':
            goToNextDriver = true;
            print("Ride is searching");
            break;
          default:
        }
        ride = event;
        print("Updated ride status from ${ride.status} to ${event.status}");
      }
    });

    isSearchingForRide = true;
    goToNextDriver = false;
    // Find nearest Drivers and start sending requests
    int timesSearched = 0;
    double radius = 50;
    while(isSearchingForRide) {
      List<Driver> nearbyDrivers = await driverService.getNearbyDriversList(radius);
      print("There are ${nearbyDrivers.length} drivers nearby.");
      if(nearbyDrivers.length > 0 && timesSearched < 6) {
        for(int i = 0; i < nearbyDrivers.length; i++) {
          Driver driver = nearbyDrivers[i];
          rideReference.updateData({'status' : 'WAITING'});
          _firestore.collection('drivers').document(driver.uid).collection('requests').document(userService.userID).setData(Request(
            id: userService.userID,
            name: "${userService.user.firstName}",
            destinationAddress: destination,
            pickupAddress: pickup,
            price: "\$10.00",
            photoURL: userService.user.profilePictureURL,
            timeout: Timestamp.fromMillisecondsSinceEpoch(Timestamp.now().millisecondsSinceEpoch + 60000)
          ).toJson());
          print("Request sent to ${driver.uid}");
          int iterations = 0;
          while(!goToNextDriver) {
            print("Request to ${driver.uid} sent $iterations seconds ago.");
            await Future.delayed(const Duration(seconds: 1));
            iterations += 1;
            if (iterations >= 70) goToNextDriver = true;
          }
          goToNextDriver = false;
          print("Moving to next driver");
        }
        timesSearched += 1;
      } else {
        timesSearched += 1;
        radius += 10;
        print("No Drivers Found after $timesSearched tries, setting radius to $radius");
        if(timesSearched > 5) isSearchingForRide = false;
      }
    }

    await rideReference.updateData({
      'lastActivity': DateTime.now(),
      'status': "CANCELED"
    });
  }

 /**
 * This function is for cancelling a ride
 * This simply updates the database to show the status
 * of the ride to be canceled
 */
  void cancelRide() {
    if(rideSubscription != null) rideSubscription.cancel();
    if(myRide.exists) {
      rideReference.updateData({
        'lastActivity': DateTime.now(),
        'status': "CANCELED",
      });
    }
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
