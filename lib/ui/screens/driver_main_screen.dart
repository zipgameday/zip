import 'package:flutter/material.dart';
import 'package:zip/business/drivers.dart';
import 'package:zip/business/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zip/models/driver.dart';
import 'dart:io';
import 'package:zip/ui/screens/main_screen.dart';

class DriverMainScreen extends StatefulWidget {
  DriverMainScreen();
  _DriverMainScreenState createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  final UserService userService = UserService();
  final DriverService driverService = DriverService();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _blackVisible = false;
  static bool _isDriver = true;
  final double lat = 37.3230; // Audit
  final double lng = -122.0312; // Audit
  Duration _time = Duration(seconds: 5); // Audit
  static Text driverText = Text("Driver",
      softWrap: true,
      style: TextStyle(
        color: Color.fromRGBO(76, 86, 96, 1.0),
        fontSize: 16.0,
        fontFamily: "OpenSans",
        fontWeight: FontWeight.w600,
      )); // Audit
  double screenHeight, screenWidth;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder<Driver>(
      stream: driverService.getDriverStream(),
      builder: (BuildContext context, AsyncSnapshot<Driver> driverObject) {
        if(driverObject.hasData) {
          Driver driver = driverObject.data;
        return Scaffold(
            key: _scaffoldKey,
            body: Stack(
              children: <Widget>[
                TheMap(),
                Positioned(
                  top: 57,
                  left: 0,
                  child: IconButton(
                      iconSize: 44,
                      color: Colors.black,
                      icon: Icon(Icons.menu),
                      onPressed: () => _scaffoldKey.currentState.openDrawer()),
                ),
              ],
            ),
            drawer: _buildDrawer(context),
            bottomSheet: driver.isWorking && driver.isAvailable
                ? Container(
                    color: Color.fromRGBO(76, 86, 96, 1.0),
                    height: screenHeight * 0.20,
                    width: screenWidth,
                    //probably
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                        ),
                        Text("Looking for rider",
                            softWrap: true,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 22.0,
                                fontFamily: "OpenSans")),
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          onPressed: () {
                            driverService.stopDriving();
                          },
                          child: Text("Cancel"),
                        ),
                      ],
                    ))
                : null,
            floatingActionButtonLocation: driver.isWorking
                ? null
                : FloatingActionButtonLocation.centerDocked,
            floatingActionButton: driver.isWorking
                ? null
                : Container(
                    height: screenHeight * 0.25,
                    width: screenWidth * 0.25,
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          Timer(_time, () async {
                            await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return _buildAcceptOrDeclineRider(
                                    context, _changeBlackVisible);
                              },
                            );
                          });
                        });
                        driverService.startDriving();
                        // TODO: Setup listening for requests
                      },
                      child: Text(
                        "Drive",
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Color.fromRGBO(76, 86, 96, 1.0),
                    ),
                  ));
        } else {
          return Scaffold(
            body: Container(
              child: Center(
                child: CircularProgressIndicator()
              )
            ),
          );
        }
      },
    );
  }

//Build Popup
  Widget _buildAcceptOrDeclineRider(
      BuildContext context, VoidCallback onPressed) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        content: Container(
            height: screenHeight * 0.4,
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 60.0,
                    child: ClipOval(
                      child: SizedBox(
                          width: 100.0,
                          height: 100.0,
                          child: Image.asset('assets/golf_cart.png',
                              fit: BoxFit.fill)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.01),
                  child: Text("John Doe"),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("5.0"),
                      Icon(Icons.star),
                    ],
                  ),
                ),
                ListBody(
                  mainAxis: Axis.vertical,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Price: "),
                        Text("\$20.00"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Distance: "),
                        Text("10 miles"),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(
                        color: Color.fromRGBO(76, 86, 96, 1.0),
                        shape: RoundedRectangleBorder(),
                        child: Text(
                          "Accept",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          await _openRoute(lat, lng);
                          Navigator.of(context).pop();
                          driverService.answerRequest(true, "");
                        },
                      ),
                      FlatButton(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black38)),
                        child: Text(
                          "Decline",
                          style:
                              TextStyle(color: Color.fromRGBO(76, 86, 96, 1.0)),
                        ),
                        onPressed: () {
                          setState(() {
                            Navigator.of(context).pop();
                          });
                          driverService.answerRequest(false, "");
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }

  void _changeBlackVisible() {
    setState(() {
      _blackVisible = !_blackVisible;
    });
  }

  Widget _buildDrawer(BuildContext context) {
    // _buildHeader() {}
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _buildTopRowOfDriverDrawer(context),
      ],
    ));
  }

  Widget _buildTopRowOfDriverDrawer(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Switch(
            value: _isDriver,
            onChanged: (value) {
              setState(() {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MainScreen()));
              });
            },
            activeColor: Colors.green[400],
            activeTrackColor: Colors.green[100],
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: driverText,
        ),
      ],
    );
  }

  Future<void> _openRoute(double lat, double lng) async {
    try {
      if (Platform.isAndroid) {
        if (await canLaunch("google.navigation:q=$lat,$lng")) {
          launch("google.navigation:q=$lat,$lng");
        } else {
          throw "Could not";
        }
      } else {
        if (await canLaunch(
            "http://maps.apple.com/?daddr=$lat,$lng&dirflg=d")) {
          launch("http://maps.apple.com/?daddr=$lat,$lng&dirflg=d");
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

class TheMap extends StatefulWidget {
  @override
  State<TheMap> createState() => MapScreen();
}

class MapScreen extends State<TheMap> {
  static LatLng _initialPosition;
  final Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor _sourceIcon;
  BitmapDescriptor _destinationIcon;

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    _getDriverLocation();
  }

  static final CameraPosition _currentPosition = CameraPosition(
    target: LatLng(_initialPosition.latitude, _initialPosition.longitude),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: _initialPosition == null
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : Stack(children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _currentPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  zoomGesturesEnabled: true,
                  markers: _markers,
                  polylines: _polylines,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  mapToolbarEnabled: true,
                ),
              ]));
  }

  void setCustomMapPin() async {
    _sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 4.5), 'assets/golf_cart.png');
    _destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 4.5), 'assets/golf_cart.png');
  }

  void _getDriverLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void setMapPins() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('source'),
          position: _initialPosition,
          icon: _sourceIcon));
      _markers.add(Marker(
          markerId: MarkerId('destination'),
          position: LatLng(37.430119406953, -122.0874490566),
          icon: _sourceIcon));
    });
  }

  void setPolylines() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        "AIzaSyDsPh6P9PDFmOqxBiLXpzJ1sW4kx-2LN5g",
        _initialPosition.latitude,
        _initialPosition.longitude,
        37.430119406953,
        -122.0874490566);
    result.forEach((PointLatLng point) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });

    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId("p"),
          color: Colors.blue,
          points: polylineCoordinates);
      _polylines.add(polyline);
    });
  }
}
