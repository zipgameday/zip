import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:zip/business/auth.dart';
import 'package:zip/business/user.dart';
import 'package:zip/models/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class DriverMainScreen extends StatefulWidget {
  DriverMainScreen();
  _DriverMainScreenState createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  final UserService userService = UserService();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isClockedIn = false;
  bool _isAvailable = false;
  bool _foundCustomer = false;
  bool _blackVisible = false;
  Duration _time = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //StreamBuilder
    //If rideshare document hasData, display Accept or Decline
    //Within Streambuilder -> change UI based off if Available or not
    //Else Return the UI we have now.
    return Scaffold(
        key: _scaffoldKey,
        body: TheMap(),
        appBar: AppBar(
            leading: FlatButton.icon(
                onPressed: () {
                  setState(() {});
                },
                icon: Icon(Icons.ac_unit),
                label: Text("hey"))),
        bottomSheet: _isClockedIn && _isAvailable
            ? Container(
                color: Color.fromRGBO(76, 86, 96, 1.0),
                height: MediaQuery.of(context).size.height / 5.0,
                width: MediaQuery.of(context).size.width,
                //probably
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    ),
                    Text("Looking for rider",
                        softWrap: true,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 22.0,
                            fontFamily: "OpenSans")),
                  ],
                ))
            : null,
        floatingActionButtonLocation:
            _isClockedIn ? null : FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _isClockedIn
            ? null
            : Container(
                height: MediaQuery.of(context).size.height / 4,
                width: MediaQuery.of(context).size.width / 4,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isClockedIn = true;
                      _isAvailable = true;
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
                      //Call function to look for customer
                      //findRider(Driver driver)
                    });
                  },
                  child: Text(
                    "Drive",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: Color.fromRGBO(76, 86, 96, 1.0),
                ),
              ));
  }

//Build Popup
  Widget _buildAcceptOrDeclineRider(
      BuildContext context, VoidCallback onPressed) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        content: Container(
            height: MediaQuery.of(context).size.height / 2.6,
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
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text("John Doe"),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
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
                  padding: EdgeInsets.only(top: 10.0),
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
                        onPressed: () {
                          setState(() {
                            _isAvailable = false;
                            Navigator.of(context).pop();
                          });
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
