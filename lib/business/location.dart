import 'dart:async';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  final Geolocator geolocator = Geolocator();
  Geoflutterfire geo = Geoflutterfire();
  GeolocationStatus geolocationStatus;
  Position position;
  bool initizalized = false;
  LocationOptions locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
  Stream<Position> positionStream;
  StreamSubscription<Position> positionSub;

  factory LocationService() {
    return _instance;
  }

  LocationService._internal() {
    print("LocationService created");
  }

  Future<bool> setupService({bool reinit = false}) async {
    try {
      if (positionSub != null) positionSub.cancel();
      PermissionStatus status = await LocationPermissions().checkPermissionStatus();
      // Get permission from user
      while (status != PermissionStatus.granted) {
        status = await LocationPermissions().requestPermissions();
      }
      // Ensure position is not null after setup
      while(position != null) {
        position = await geolocator.getCurrentPosition();
      }
      // Create position stream and subscribe to keep service's position up to date.
      positionStream = geolocator.getPositionStream(locationOptions).asBroadcastStream();
      positionSub = positionStream.listen(
      (Position position) {
        if(position != null) {
          this.position = position;
        }
      });
      print("LocationService initialized");
      return true;
    } catch(e) {
      print("Error initializing LocationService $e");
      return false;
    }
  }

  GeoFirePoint getCurrentGeoFirePoint() {
    return geo.point(latitude: position.latitude, longitude: position.longitude);
  }
}
