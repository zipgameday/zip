import 'package:flutter/material.dart';
import "package:zip/ui/screens/walk_screen.dart";
import 'package:zip/ui/screens/root_screen.dart';
import 'package:zip/ui/screens/sign_in_screen.dart';
import 'package:zip/ui/screens/sign_up_screen.dart';
import 'package:zip/ui/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true);
  SharedPreferences.getInstance().then((prefs) {
    runApp(MyApp(prefs: prefs));
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  MyApp({this.prefs});
  // PermissionStatus permission;
  // Future<PermissionStatus> _getPermission() async => permission = await LocationPermissions().requestPermissions();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/walkthrough': (BuildContext context) => new WalkthroughScreen(),
        '/root': (BuildContext context) => new RootScreen(),
        '/signin': (BuildContext context) => new SignInScreen(),
        '/signup': (BuildContext context) => new SignUpScreen(),
        '/main': (BuildContext context) => new MainScreen(),
      },
      theme: ThemeData(
        primaryColor: Colors.white,
        primarySwatch: Colors.grey,
      ),
      home: _handleCurrentScreen(),
    );
  }

  Widget _handleCurrentScreen() {
    // _getPermission();
    bool seen = (prefs.getBool('seen') ?? false);
    if (seen) {
      return new RootScreen();
    } else {
      return new WalkthroughScreen(prefs: prefs);
    }
  }
}
