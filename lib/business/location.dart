import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  final Geolocator geolocator = Geolocator();
  GeolocationStatus geolocationStatus;
  Position position;
  bool initizalized = false;
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
      if (positionSub != null) positionSub.cancel();
      GeolocationStatus locationPermissionStatus = await Geolocator().checkGeolocationPermissionStatus();
      if (locationPermissionStatus == GeolocationStatus.granted) {
        positionStream = geolocator.getPositionStream(locationOptions).asBroadcastStream();
        positionSub = positionStream.listen(
        (Position position) {
          if(position != null) {
            this.position = position;
          }
        });
        print("LocationService initialized");
        return true;
      } else {
        PermissionStatus permission = await LocationPermissions().requestPermissions();
        setupService();
        return true;
      }
    } catch(e) {
      print("Error initializing LocationService $e");
      return false;
    }
  }
}
