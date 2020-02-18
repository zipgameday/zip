import 'package:flutter/material.dart';
import 'package:zip/ui/screens/profile_screen.dart';
import 'package:zip/ui/screens/root_screen.dart';
import 'package:zip/ui/screens/sign_in_screen.dart';
import 'package:zip/ui/screens/sign_up_screen.dart';
import 'package:zip/ui/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        title: 'Zip Gameday',
        debugShowCheckedModeBanner: false,
        routes: <String, WidgetBuilder>{
          '/root': (BuildContext context) => new RootScreen(),
          '/signin': (BuildContext context) => new SignInScreen(),
          '/signup': (BuildContext context) => new SignUpScreen(),
          '/main': (BuildContext context) => new MainScreen(),
          '/profile' : (BuildContext context) => new ProfileScreen(),
        },
        theme: ThemeData(
          primaryColor: Colors.white,
          primarySwatch: Colors.grey,
        ),
        home: _handleCurrentScreen(),
      );
  }

  Widget _handleCurrentScreen() {
    return new RootScreen();
  }
}
