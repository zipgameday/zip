import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:zip/business/auth.dart';
import 'package:zip/business/drivers.dart';
import 'package:zip/business/location.dart';
import 'package:zip/business/user.dart';
import 'package:zip/models/user.dart';
import 'package:zip/models/driver.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:zip/ui/screens/settings_screen.dart';
import 'package:zip/ui/screens/promos_screen.dart';
import 'package:zip/ui/screens/driver_main_screen.dart';

class MainScreen extends StatefulWidget {
  MainScreen();
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final UserService userService = UserService();
  final LocationService locationService = LocationService();
  final String ios_map_key = "AIzaSyC-qi8dEKCFP1q3FKu9Faxkabd-lj8ysJw";
  final String android_map_key = "AIzaSyDsPh6P9PDFmOqxBiLXpzJ1sW4kx-2LN5g";

  static bool _isSwitched = true;
  static Text driverText = Text("Driver",
      softWrap: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontFamily: "OpenSans",
        fontWeight: FontWeight.w600,
      ));
  static Text customerText = Text("Customer",
      softWrap: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontFamily: "OpenSans",
        fontWeight: FontWeight.w600,
      ));

  static Text viewProfileText = Text("View Profile",
      softWrap: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontFamily: "OpenSans",
        fontWeight: FontWeight.w600,
      ));
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(children: <Widget>[
        TheMap(),
        Positioned(
          top: 100,
          left: MediaQuery.of(context).size.width * 0.05,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.09,
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextField(decoration: InputDecoration(hintText: "Where To?"))
          ),
        ),
        Positioned(
          top: 60,
          left: MediaQuery.of(context).size.width * 0.01,
          child: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState.openDrawer()),
        ),
      ]),
      drawer: buildDrawer(context),
    );
  }

  void _logOut() async {
    AuthService().signOut();
  }

  Widget buildDrawer(BuildContext context) {
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
                      buildTopRowOfDrawerHeader(context),
                      CircleAvatar(
                        radius: 60.0,
                        child: ClipOval(
                          child: SizedBox(
                            width: 130.0,
                            height: 130.0,
                            child: user.profilePictureURL == ''
                                ? Image.network(
                                    "gs://zipgameday-6ef28.appspot.com/FCMImages/profile_default.png")
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
          ListTile(
            title: Text('Edit Profile'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            title: Text('Promos'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PromosScreen()));
            },
          ),
          ListTile(
            title: Text('Log Out'),
            onTap: () {
              _logOut();
              _scaffoldKey.currentState.openEndDrawer();
            },
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget buildTopRowOfDrawerHeader(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Switch(
            value: _isSwitched,
            onChanged: (value) {
              setState(() {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DriverMainScreen()));
                _isSwitched = !_isSwitched;
              });
            },
            activeColor: Colors.blue[400],
            activeTrackColor: Colors.blue[100],
            inactiveThumbColor: Colors.green,
            inactiveTrackColor: Colors.green[100],
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: _isSwitched ? customerText : driverText,
        ),
      ],
    );
  }
}

class TheMap extends StatefulWidget {
  @override
  State<TheMap> createState() => MapScreen();
}

class MapScreen extends State<TheMap> {
  final DriverService driverService = DriverService();
  static LatLng _initialPosition;
  final Set<Marker> _markers = {};
  BitmapDescriptor pinLocationIcon;
  Set<LatLng> driverPositions = {
    LatLng(32.62532, -85.46849),
    LatLng(32.62932, -85.46249)
  };
  List<Driver> driversList;
  static LatLng _lastMapPosition = _initialPosition;
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    _getUserLocation();
    _getNearbyDrivers();
  }

  static final CameraPosition _currentPosition = CameraPosition(
    target: LatLng(_initialPosition.latitude, _initialPosition.longitude),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _initialPosition == null || pinLocationIcon == null
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _currentPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _markers,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              mapToolbarEnabled: true,
            ),
    );
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 4.5), 'assets/golf_cart.png');
  }

  void _getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
    driverPositions.forEach((dr) => _markers.add(Marker(
          markerId: MarkerId('testing'),
          position: dr,
          icon: pinLocationIcon,
        )));
  }

  void _getNearbyDrivers() {}
}
