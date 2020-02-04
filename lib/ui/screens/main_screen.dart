import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zip/business/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zip/models/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class MainScreen extends StatefulWidget {
  final FirebaseUser firebaseUser;

  MainScreen({this.firebaseUser});

  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print(widget.firebaseUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        elevation: 0.5,
        leading: new IconButton(
            icon: new Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState.openDrawer()),
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Where to?'
          ),
        ),
        centerTitle: true,
      ),
      drawer: buildDrawer(context),
      body: TheMap(),
    );
  }

  void _logOut() async {
    AuthService().signOut();
  }

  Widget buildDrawer(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: [
                  Text('Drawer Header'),
                  //Think it needs to display first/lastname
                  //Text('Name: ${user.displayName}'),
                  Text('Email: ${user.email}'),
                  ]),
            ),
            ListTile(
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.of(context).pushNamed('/profile');
              },
            ),
            ListTile(
              title: Text('Log Out'),
              onTap: () {
                _logOut();
                _scaffoldKey.currentState.openEndDrawer();
              },
            ),
          ],
        ),
      );
  }
}

class TheMap extends StatefulWidget {
  @override
  State<TheMap> createState() => MapScreen();
}

class MapScreen extends State<TheMap> {
  static LatLng _initialPosition;
  final Set<Marker> _markers = {};
  static LatLng _lastMapPosition = _initialPosition;
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
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
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              mapToolbarEnabled: true,
            ),
    );
  }

  void _getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }
}
