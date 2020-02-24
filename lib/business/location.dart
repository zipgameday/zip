import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  GeolocationStatus geolocationStatus;
  Position position;
  bool initizalized = false;
  Geolocator geolocator = Geolocator();
  LocationOptions locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 3);
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
      geolocationStatus  = await Geolocator().checkGeolocationPermissionStatus();
      if (positionSub != null) positionSub.cancel();
      position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
      positionStream = geolocator.getPositionStream(locationOptions).asBroadcastStream();
      positionSub = positionStream.listen(
      (Position position) {
        if(position != null) {
          this.position = position;
        }
      });
      print("LocationService initialized at position: ${position.latitude}, ${position.longitude}");
      return true;
    } catch(e) {
      print("Error initializing LocationService $e");
      return false;
    }
  }
}
