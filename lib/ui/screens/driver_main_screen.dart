import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zip/business/drivers.dart';
import 'package:zip/business/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zip/models/driver.dart';
import 'package:zip/models/request.dart';
import 'dart:io';
import 'package:zip/ui/screens/main_screen.dart';
import '../../models/user.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'main_screen.dart';

enum DriverBottomSheetStatus { closed, confirmation, searching, ride }

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
  double screenHeight, screenWidth;
  static Text driverText = Text("Driver",
      softWrap: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontFamily: "OpenSans",
        fontWeight: FontWeight.w600,
      )); // Audit
  DriverBottomSheetStatus driverBottomSheetStatus;

  @override
  void initState() {
    super.initState();
    driverBottomSheetStatus = DriverBottomSheetStatus.closed;
  }

/*
  Main build function for Driver Page.
*/
  @override
  Widget build(BuildContext context) {
    //MediaQuery used for constant UI on different sized screens.
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    //Subscribed to Driver with certain ID
    //This is how we get constant updates from the database.
    //Needed to change UI based off events happening on Client Side
    return StreamBuilder<Driver>(
      stream: driverService.getDriverStream(),
      builder: (BuildContext context, AsyncSnapshot<Driver> driverObject) {
        if (driverObject.hasData) {
          Driver driver = driverObject.data;
          print(driver.isWorking);
          print(driver.uid);
          return Scaffold(
              key: _scaffoldKey,
              body: Stack(
                children: <Widget>[
                  //Uses Enum to determine which view to build.
                  driverBottomSheetStatus == DriverBottomSheetStatus.confirmation
                      ? _buildMapView()
                      : TheMap(),
                  Positioned(
                    top: 57,
                    left: 0,
                    child: IconButton(
                        iconSize: 44,
                        color: Colors.black,
                        icon: Icon(Icons.menu),
                        onPressed: () =>
                            _scaffoldKey.currentState.openDrawer()),
                  ),
                ],
              ),
              drawer: _buildDrawer(context),
              bottomSheet: _buildBottomSheet(),
              //If bottomsheet is closed -> display Drive button
              floatingActionButtonLocation: driverBottomSheetStatus != DriverBottomSheetStatus.closed
                  ? null
                  : FloatingActionButtonLocation.centerDocked, 
              floatingActionButton: driverBottomSheetStatus != DriverBottomSheetStatus.closed
                  ? null
                  : Container(
                      height: screenHeight * 0.25,
                      width: screenWidth * 0.25,
                      child: FloatingActionButton(
                        onPressed: () async {
                          await driverService.startDriving(onRequestChange);
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
            body: Container(child: Center(child: CircularProgressIndicator())),
          );
        }
      },
    );
  }

  /*
    Updated based on bottomSheet enum.
    Builds basic bottomSheet to alert Driver that system is looking for rider.
  */
  Widget _buildLookingForRider(BuildContext context) {
    return Container(
        color: Color.fromRGBO(76, 86, 96, 1.0),
        height: screenHeight * 0.20,
        width: screenWidth,
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
        ));
  }


/*
  If bottomSheet has found a ride -> show preview of route inside application. 
*/ 
  Widget _buildMapView() {
    return Container(
      height: screenHeight * 0.75,
      width: screenWidth,
      child: WebView(
        initialUrl: "https://www.google.com/maps/dir/?api=1&destination=${driverService.currentRequest.pickupAddress.latitude},${driverService.currentRequest.pickupAddress.longitude}&",
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }

/*
  Controls the state of the bottomSheet.
  Constantly listens to a request stream to check for changes.
*/ 
  Widget _buildBottomSheet() {
    return StreamBuilder<Request>(
      stream: driverService.requestStream,
      builder: (BuildContext context, AsyncSnapshot<Request> requestObject) {
        switch (driverBottomSheetStatus) {
          case DriverBottomSheetStatus.closed:
            return Container(width: 0, height: 0);
            break;
          case DriverBottomSheetStatus.searching:
            return _buildLookingForRider(context);
            break;
          case DriverBottomSheetStatus.confirmation:
            return _buildAcceptOrDeclineRider(context, _changeBlackVisible);
            break;  
          case DriverBottomSheetStatus.ride:
            return Container();
            break;
          default:
        }
      });
  }

/*
  Build bottomSheet that shows if a rider should be Accepted or Declined.
*/
  Widget _buildAcceptOrDeclineRider(
      BuildContext context, VoidCallback onPressed) {
      Request currentRequest = driverService.currentRequest;
    return Container(
        color: Colors.white,
        height: screenHeight * 0.25,
        width: screenWidth,
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 30.0,
                child: ClipOval(
                  child: SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: Image.asset('assets/golf_cart.png',
                          fit: BoxFit.fill)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.001),
              child: Text("${currentRequest.name}", style: TextStyle(fontSize: 16.0)),
            ),
            ListBody(
              mainAxis: Axis.vertical,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Price: ", style: TextStyle(fontSize: 16.0)),
                    Text("${currentRequest.price}", style: TextStyle(fontSize: 16.0)),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.001),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton.icon(
                    icon: Icon(Icons.check, color: Colors.white),
                    elevation: 1.0,
                    color: Color.fromRGBO(76, 86, 96, 1.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    label: Text(
                      "Accept",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    onPressed: () async {
                      await driverService.acceptRequest(currentRequest.id);
                      await _openRoute(currentRequest.pickupAddress.latitude, currentRequest.pickupAddress.longitude);
                    },
                  ),
                  RaisedButton.icon(
                    icon: Icon(Icons.cancel),
                    elevation: 1.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black38),
                        borderRadius: BorderRadius.circular(12.0)),
                    label: Text(
                      "Decline",
                      style: TextStyle(
                          color: Color.fromRGBO(76, 86, 96, 1.0),
                          fontSize: 16.0),
                    ),
                    onPressed: () async {
                      await driverService.declineRequest(currentRequest.id);
                    },
                  ),
                ],
              ),
            ),
          ],
        ));
  }


/*
  Changes the background of the screen.
*/
  void _changeBlackVisible() {
    setState(() {
      _blackVisible = !_blackVisible;
    });
  }

/*
  Set the status of the bottomSheet.
*/
  void onRequestChange(DriverBottomSheetStatus status) {
    setState(() {
      driverBottomSheetStatus = status;
    });
  }

/*
  Builds a drawer that is subscribed to user stream.
  Drivers and Customers have the same UID.
  We can use information from Customer snapshot instead of 
  duplicating data.
*/
  Widget _buildDrawer(BuildContext context) {
    _buildHeader() {
      return StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .collection('users')
              .document(userService.userID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              User user = User.fromDocument(snapshot.data);
              return Container(
                  height: MediaQuery.of(context).size.height / 2.8,
                  child: DrawerHeader(
                    padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
                    decoration:
                        BoxDecoration(color: Color.fromRGBO(76, 86, 96, 1.0)),
                    child: Column(children: [
                      _buildTopRowOfDriverDrawer(context),
                      CircleAvatar(
                        radius: 60.0,
                        child: ClipOval(
                          child: SizedBox(
                            width: 130.0,
                            height: 130.0,
                            child: user.profilePictureURL == ''
                                ? Image.asset('assets/profile_default.png')
                                : Image.network(
                                    user.profilePictureURL,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Text(
                                '${user.firstName} ${user.lastName}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontFamily: "OpenSans",
                                  fontWeight: FontWeight.w400,
                                ),
                              )),
                        ],
                      )
                    ]),
                  ));
            } else {
              return DrawerHeader(child: Column());
            }
          });
    }

    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _buildHeader(),
      ],
    ));
  }

/*
  Builds Switch to change pages.
*/
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

/*
  Open directions to address on either Apple/Google Maps.
*/ 
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


/*
  Builds a Google Map centered on users location.
*/ 
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
