import 'dart:io' show Platform;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:zip/business/auth.dart';
import 'package:zip/business/drivers.dart';
import 'package:zip/business/ride.dart';
import 'package:zip/business/location.dart';
import 'package:zip/business/notifications.dart';
import 'package:zip/business/user.dart';
import 'package:zip/models/user.dart';
import 'package:zip/models/driver.dart';
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
  final String map_key = "AIzaSyDsPh6P9PDFmOqxBiLXpzJ1sW4kx-2LN5g";
  final search_controller = TextEditingController();
  final RideService rideService = RideService();
  final FocusNode search_node = FocusNode();
  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyDsPh6P9PDFmOqxBiLXpzJ1sW4kx-2LN5g');
  PlacesDetailsResponse details;
  bool checkPrice = false;
  bool lookingForRide = false;
  String address = '';
  NotificationService notificationService = NotificationService();

  static bool _isCustomer = true;
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
    notificationService.registerContext(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(children: <Widget>[
        TheMap(),
        Positioned(
          top: 57,
          left: 0,
          child: Card(
              color: Colors.transparent,
              elevation: 100,
              child: IconButton(
                  iconSize: 44,
                  color: Colors.black,
                  icon: Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState.openDrawer())),
        ),
        Positioned(
            top: 60,
            left: MediaQuery.of(context).size.width * 0.15,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        offset: Offset(1.0, 5.0),
                        blurRadius: 10,
                        spreadRadius: 3)
                  ],
                ),
                height: MediaQuery.of(context).size.height * 0.07,
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                    onTap: () async {
                      Prediction p = await PlacesAutocomplete.show(
                              context: context,
                              hint: 'Where to?',
                              startText: search_controller.text == ''
                                  ? ''
                                  : search_controller.text,
                              apiKey: this.map_key,
                              language: "en",
                              components: [Component(Component.country, "us")],
                              mode: Mode.overlay)
                          .then((v) async {
                        if (v != null) {
                          this.address = v.description;
                          search_controller.text = this.address;
                          this.details = await _places.getDetailsByPlaceId(v.placeId);
                        }
                        search_node.unfocus();
                        _checkPrice();
                        return null;
                      });
                    },
                    controller: search_controller,
                    focusNode: search_node,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (s) {
                      _checkPrice();
                    },
                    decoration: InputDecoration(
                      icon: Container(
                        margin: EdgeInsets.only(left: 20, top: 5),
                        width: 10,
                        height: 10,
                        child: Icon(
                          Icons.local_taxi,
                          color: Colors.black,
                        ),
                      ),
                      hintText: "Where to?",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                    )))),
      ]),
      drawer: buildDrawer(context),
      floatingActionButton: checkPrice == true
          ? null
          : FloatingActionButton(
              onPressed: () => MapScreen()._mylocation(locationService),
              child: Icon(Icons.my_location),
              backgroundColor: Colors.blue),
      bottomSheet: checkPrice == false
          ? null
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.25,
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
                top: MediaQuery.of(context).size.height * 0.01,
                bottom: MediaQuery.of(context).size.height * 0.01,
              ),
              child: Stack(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Center(
                        child: Text(
                          this.address,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "OpenSans",
                            fontWeight: FontWeight.w600,
                          ),
                          softWrap: true,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('assets/golf_cart.png'),
                          Text(
                            'Price: \$10.00',
                            style: TextStyle(
                              fontSize: 19.0,
                              fontFamily: "OpenSans",
                              fontWeight: FontWeight.w600,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          FloatingActionButton.extended(
                            backgroundColor: Colors.blue,
                            onPressed: () async {
                              setState(() {
                                lookingForRide = true;
                              });
                            },
                            label: Text('Confirm'),
                            icon: Icon(Icons.check),
                          ),
                          FloatingActionButton.extended(
                            backgroundColor: Colors.red,
                            onPressed: () {
                              setState(() {
                                checkPrice = false;
                              });
                              _lookForRide();
                            },
                            label: Text('Cancel'),
                            icon: Icon(Icons.cancel),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void _logOut() async {
    AuthService().signOut();
  }

  void _checkPrice() {
    if (search_controller.text == this.address &&
        search_controller.text.length > 0) {
      setState(() {
        checkPrice = true;
      });
    }
  }

  void _lookForRide() async {
    if (lookingForRide && this.details != null) {
      rideService.startRide(this.details.result.geometry.location.lat, this.details.result.geometry.location.lng);
    }
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
            value: _isCustomer,
            onChanged: (value) {
              setState(() {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DriverMainScreen()));
              });
            },
            activeColor: Colors.blue[400],
            activeTrackColor: Colors.blue[100],
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: customerText,
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
  LocationService location = LocationService();
  BitmapDescriptor pinLocationIcon;
  Set<LatLng> driverPositions = {
    LatLng(32.62532, -85.46849),
    LatLng(32.62932, -85.46249)
  };
  List<Driver> driversList;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _setCustomMapPin();
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
      body: _initialPosition == null
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

  void _setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 4), 'assets/golf_cart.png');
  }

  void _getUserLocation() async {
    setState(() {
      _initialPosition =
          LatLng(location.position.latitude, location.position.longitude);
    });
    driverPositions.forEach((dr) => _markers.add(Marker(
          markerId: MarkerId('testing'),
          position: dr,
          icon: pinLocationIcon,
        )));
  }

  void _mylocation(LocationService location) {
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(location.position.latitude, location.position.longitude),
      ),
    ));
  }

  void _getNearbyDrivers() {}
}
