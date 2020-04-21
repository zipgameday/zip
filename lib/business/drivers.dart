import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zip/business/location.dart';
import 'package:zip/business/user.dart';
import 'package:zip/models/driver.dart';
import 'package:zip/models/request.dart';
import 'package:zip/models/rides.dart';
import 'package:zip/models/user.dart';
import 'package:zip/ui/screens/driver_main_screen.dart';

class DriverService {
  static final DriverService _instance = DriverService._internal();
  final Firestore _firestore = Firestore.instance;
  final bool showDebugPrints = true;
  Geoflutterfire geo = Geoflutterfire();
  LocationService locationService = LocationService();
  StreamSubscription<Position> locationSub;
  CollectionReference driversCollection;
  DocumentReference driverReference;
  UserService userService = UserService();
  List<Driver> nearbyDriversList;
  Stream<List<Driver>> nearbyDriversListStream;
  Stream<User> userStream;
  User user;
  GeoFirePoint myLocation;
  Driver driver;
  StreamSubscription<Driver> driverSub;
  CollectionReference requestCollection;
  StreamSubscription<Request> requestSub;
  Stream<Request> requestStream;
  Request currentRequest;
  Stream<Ride> rideStream;
  StreamSubscription<Ride> rideSub;
  Ride currentRide;
  Function uiCallbackFunction;

  factory DriverService() {
    return _instance;
  }

  // TODO: Update to use user.isDriver before initializing since only driver users will need the service.

  DriverService._internal() {
    print("DriverService Created");
    driversCollection = _firestore.collection('drivers');
    driverReference = driversCollection.document(userService.userID);
    requestCollection = driverReference.collection('requests');
  }

  Future<bool> setupService() async {
    await _updateDriverRecord();
    this.driverSub = driverReference.snapshots().map((DocumentSnapshot snapshot) {
      return Driver.fromDocument(snapshot);
    }).listen((driver) {
      this.driver = driver;
    });
    if (locationSub != null) locationSub.cancel();
    locationSub = locationService.positionStream.listen(updatePosition);
    print("DriverService setup");
    return true;
  }

  void updatePosition(Position pos) {
    if(driver != null) {
      if (driver.isWorking) {
        this.myLocation = geo.point(latitude: pos.latitude, longitude: pos.longitude);
        print("Updating geoFirePoint to: ${myLocation.toString()}");
        // TODO: Check for splitting driver and position into seperate documents in firebase as an optimization
        driverReference
          .updateData({'lastActivity': DateTime.now(), 'geoFirePoint': myLocation.data});
      }
    }
  }

  Future<void> startDriving(Function callback) async {
    uiCallbackFunction = callback;
    uiCallbackFunction(DriverBottomSheetStatus.searching);
    requestStream = requestCollection.snapshots().map((event) => event.documents.map( (e) => Request.fromDocument(e)).toList().elementAt(0)).asBroadcastStream();
    driverReference.updateData({
      'lastActivity': DateTime.now(),
      'geoFirePoint': locationService.getCurrentGeoFirePoint().data,
      'isAvailable': true,
      'isWorking': true
    });
    requestSub = requestStream.listen((request) {
      if(request.name != null) onRequestRecieved(request); 
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  onRequestRecieved(Request req) {
    print("Request recieved from ${req.name} recieved, timeout at ${req.timeout}");
    currentRequest = req;
    var seconds = (req.timeout.seconds - Timestamp.now().seconds);
    Future.delayed(Duration(seconds : seconds)).then((value) {
      print("Request recieved from ${req.name} timed out");
      declineRequest(req.id);
    });
    uiCallbackFunction(DriverBottomSheetStatus.confirmation);
  }

  Future<void> declineRequest(String requestID) async {
    print("Declining request: $requestID");
    DocumentSnapshot requestRef = await requestCollection.document(requestID).get();
    if(requestRef.exists) {
      print("Request $requestID exists and will be deleted.");
      await _firestore.collection('rides').document(requestID).updateData({'status' : "SEARCHING"});
      await requestCollection.document(requestID).delete();
      uiCallbackFunction(DriverBottomSheetStatus.searching);
    }
    print("Request is already deleted"); // TODO: Delete
    _firestore.collection('rides').document(requestID).get().then((value) => print("Request status is ${value.data['status']}, should be 'WAITING'"));
  }

  Future<void> acceptRequest(String requestID) async {
    print("Accepting request: $requestID");
    DocumentSnapshot requestRef = await _firestore.collection('rides').document(requestID).get();
    rideStream = _firestore.collection('rides').document(requestID).snapshots().map((event) => Ride.fromDocument(event));
    rideSub = rideStream.listen(_onRideUpdate);
    if(requestRef.exists) {
      print("Request $requestID exists and will be deleted after acceptance.");
      await driverReference.updateData({
        'isAvailable' : false,
        'currentRideID' : requestID
      });
      await _firestore.collection('rides').document(requestID).updateData({
        'status' : "IN_PROGRESS",
        'drid': userService.userID,
        'driverName': userService.user.firstName,
        'driverPhotoURL': userService.user.profilePictureURL
      });
      await requestCollection.document(requestID).delete();
    }
  }

  void stopDriving() {
    driverReference.updateData({
      'lastActivity': DateTime.now(),
      'isAvailable': false,
      'isWorking': false,
      'currentRideID': ''
    });
    if(requestSub != null ) requestSub.cancel();
    if(driverSub != null) driverSub.cancel();
    if(rideSub != null) rideSub.cancel();
    if(uiCallbackFunction != null) uiCallbackFunction(DriverBottomSheetStatus.closed);
  }

  void cancelRide() async {
    if(currentRide.status != "CANCELED") {
      await _firestore.collection('rides').document(driver.currentRideID).updateData({
        'lastActivity' : DateTime.now(),
        'status' : 'CANCELED',
        'drid' : '',
        'driverName' : '',
        'driverPhotoURL': ''
      });
    }
    stopDriving();
  }

  void _onRideUpdate(Ride updatedRide) {
    if(updatedRide != null) {
        if (showDebugPrints) print("Updated ride status to ${updatedRide.status}");
        currentRide = updatedRide;
        switch (updatedRide.status) {
          case 'CANCELED':
            uiCallbackFunction(DriverBottomSheetStatus.closed);
            cancelRide();
            if (showDebugPrints) print("Ride is canceled");
            break;
          case 'IN_PROGRESS':
            uiCallbackFunction(DriverBottomSheetStatus.rideDetails);
            if (showDebugPrints) print("Ride is now IN_PROGRESS");
            break;
          case 'ENDED':
            uiCallbackFunction(DriverBottomSheetStatus.closed);
            if (showDebugPrints) print("Ride has ended.");
            break;
          default:
        }
      }
  }

  Stream<Driver> getDriverStream() {
    return driverReference.snapshots()
        .map((snapshot) {
      return Driver.fromDocument(snapshot);
    });
  }

  // TODO: Audit
  Stream<List<Driver>> getNearbyDriversStream() {
    if (nearbyDriversListStream == null) {
      nearbyDriversListStream = geo
          .collection(collectionRef: driversCollection)
          .within(center: myLocation, radius: 50, field: 'geoFirePoint')
          .map((snapshots) => snapshots.map((e) => Driver.fromDocument(e)).take(10).toList());
    }
    return nearbyDriversListStream;
  }

  Future<List<Driver>> getNearbyDriversList(double radius) async {
    GeoFirePoint centerPoint = locationService.getCurrentGeoFirePoint();
    Query collectionReference = _firestore.collection('drivers').where('isAvailable', isEqualTo: true);

    Stream<List<Driver>> stream = geo.collection(collectionRef: collectionReference)
      .within(center: centerPoint, radius: radius, field: 'geoFirePoint', strictMode: false)
      .map((event) => event.map((e) => Driver.fromDocument(e))
      .take(10).toList());

    List<Driver> nearbyDrivers = await stream.first;
    nearbyDrivers.forEach((driver) {
      print("${driver.firstName} is available and in range.");
    });
    return nearbyDrivers;
  }

  _updateDriverRecord() async {
    DocumentSnapshot myDriverRef = await driverReference.get();
    if (!myDriverRef.exists) {
      driversCollection.document(userService.userID).setData({
        'uid': userService.userID,
        'firstName' : userService.user.firstName,
        'lastName' : userService.user.lastName,
        'profilePictureURL' : userService.user.profilePictureURL,
        'geoFirePoint': locationService.getCurrentGeoFirePoint().data,
        'lastActivity': DateTime.now(),
        'isAvailable': false,
        'isWorking': false
      });
    } else { // TODO: Get rid of once server is constantly checking for abandoned drivers
      stopDriving();
    }
  }
}
