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
import 'package:zip/ui/widgets/ride_bottom_sheet.dart';

enum BottomSheetStatus { closed, confirmation, searching, rideDetails }

class MainScreen extends StatefulWidget {
  MainScreen();
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //this is the global key used for the scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  double screenHeight, screenWidth;

  ///these are the services that this screen uses.
  ///you can call these services anywhere in this class.
  final UserService userService = UserService();
  final LocationService locationService = LocationService();
  final RideService rideService = RideService();
  final NotificationService notificationService = NotificationService();

  ///these are used to manipulate the textfield
  ///so that you can make sure the text is in sync
  ///with the prediction.
  final search_controller = TextEditingController();
  final FocusNode search_node = FocusNode();
  String address = '';

  ///maps api key used for the prediction
  final String map_key = "AIzaSyDsPh6P9PDFmOqxBiLXpzJ1sW4kx-2LN5g";

  ///these are for translating place details into coordinates
  ///used for creating a ride in the database
  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyDsPh6P9PDFmOqxBiLXpzJ1sW4kx-2LN5g');
  PlacesDetailsResponse details;

  ///these are used for controlling the bottomsheet
  ///and other things to do with creating a ride.
  BottomSheetStatus bottomSheetStatus;

  ///these are for the toggle in the top left part of the
  ///screen.
  static bool _isCustomer = true;
  static Text customerText = Text("Customer",
      softWrap: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontFamily: "OpenSans",
        fontWeight: FontWeight.w600,
      ));

  ///this is text for the sidebar
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
    bottomSheetStatus = BottomSheetStatus.closed;
  }

  ///this returns a scaffold that contains the entire mainscreen.
  ///here you'll find that we call the map (bottom of this file),
  ///drawer(see buildDrawer function), and create the bottomsheet
  ///and the button for moving to your location. The textfield with
  ///the autocomplete functionality is also here.
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
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
              left: screenWidth * 0.15,
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
                  height: screenHeight * 0.07,
                  width: screenWidth * 0.8,
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
                                components: [
                                  Component(Component.country, "us")
                                ],
                                mode: Mode.overlay)
                            .then((v) async {
                          if (v != null) {
                            this.address = v.description;
                            search_controller.text = this.address;
                            this.details =
                                await _places.getDetailsByPlaceId(v.placeId);
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
        bottomSheet: _buildBottomSheet());
  }

  Widget _buildBottomSheet() {
    switch (bottomSheetStatus) {
      case BottomSheetStatus.closed:
        return Container(
          height: 0,
          width: 0,
        );
        break;
      case BottomSheetStatus.confirmation:
        return Container(
          width: screenWidth,
          height: screenHeight * 0.25,
          padding: EdgeInsets.only(
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            top: screenHeight * 0.01,
            bottom: screenHeight * 0.01,
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
                        onPressed: () {
                          _lookForRide();
                        },
                        label: Text('Confirm'),
                        icon: Icon(Icons.check),
                      ),
                      FloatingActionButton.extended(
                        backgroundColor: Colors.red,
                        onPressed: () {
                          _cancelRide();
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
        );
        break;
      case BottomSheetStatus.searching:
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
                Text("Looking for driver",
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
                    _cancelRide();
                  },
                  child: Text("Cancel"),
                ),
              ],
            ));
        break;
      case BottomSheetStatus.rideDetails:
        return RideDetails(
          driver: false,
          ride: rideService.ride,
        );
        break;
      default:
    }
  }

  ///this will logout the user.
  void _logOut() async {
    AuthService().signOut();
  }

  ///this will pull up the bottomsheet and ask if the user wants
  ///to move forward with the ride process
  void _checkPrice() async {
    if (search_controller.text == this.address &&
        search_controller.text.length > 0) {
      setState(() {
        bottomSheetStatus = BottomSheetStatus.confirmation;
      });
    }
  }

  ///once the rider clicks confirm it will create a ride and look
  ///for a driver
  void _lookForRide() async {
    if (this.details != null) {
      rideService.startRide(this.details.result.geometry.location.lat,
          this.details.result.geometry.location.lng, this.onRideChange);
    }
  }

  ///if the rider clicks the cancel button, it will dismiss
  ///the bottomsheet and cancel the ride.
  void _cancelRide() {
    setState(() {
      bottomSheetStatus = BottomSheetStatus.closed;
    });
    rideService.cancelRide();
  }

  void onRideChange(BottomSheetStatus status) {
    setState(() {
      bottomSheetStatus = status;
    });
  }

  ///this builds the sidebar also known as the drawer.
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
                  height: screenHeight * 0.36,
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

  ///this displays user information above the drawer
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

///this is the map class for displaying the google map
class TheMap extends StatefulWidget {
  @override
  State<TheMap> createState() => MapScreen();
}

class MapScreen extends State<TheMap> {
  ///variables and services needed to  initialize the map
  ///and location of the user.
  final DriverService driverService = DriverService();
  LocationService location = LocationService();
  static LatLng _initialPosition;

  ///these three objects are used for the markers
  ///that display nearby drivers.
  final Set<Marker> _markers = {};
  BitmapDescriptor pinLocationIcon;
  Set<LatLng> driverPositions = {
    LatLng(32.62532, -85.46849),
    LatLng(32.62932, -85.46249)
  };
  List<Driver> driversList;

  ///this controller helps you manipulate the map
  ///from different places.
  Completer<GoogleMapController> _controller = Completer();

  ///this initalizes the map, user location, and drivers nearby.
  @override
  void initState() {
    super.initState();
    _setCustomMapPin();
    _getUserLocation();
    _getNearbyDrivers();
  }

  ///this initializes the cameraposition of the map.
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
        floatingActionButton: FloatingActionButton(
            onPressed: () => _goToMe(),
            child: Icon(Icons.my_location),
            backgroundColor: Colors.blue));
  }

  ///this sets the icon for the markers
  void _setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 4), 'assets/golf_cart.png');
  }

  ///this gets the current users location
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

  Future<void> _goToMe() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(location.position.latitude, location.position.longitude), zoom: 14.47)));
  }

  void _getNearbyDrivers() {}
}
