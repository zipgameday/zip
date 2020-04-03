import "package:flutter/material.dart";
import 'package:zip/ui/screens/profile_screen.dart';
import 'package:zip/ui/screens/defaultTip_screen.dart';
import 'package:zip/ui/screens/legalInfo_screen.dart';
class SettingsScreen extends StatefulWidget {
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  VoidCallback onBackPress;
  @override
  void initState() {
     onBackPress = () {
      Navigator.of(context).pop();
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   return WillPopScope(
      onWillPop: onBackPress,
    child: Scaffold(
      //backgroundColor: Colors.grey[70],
      body: Padding(
        padding: const EdgeInsets.only(
          top: 23.0,
          bottom: 20.0,
          left: 0.0,
          right: 0.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TopRectangle(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                   child: IconButton(
                   icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: onBackPress,
                ),
                   
                  
                  ),
                  Text("Settings",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 36.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans"))
                ],
              ),
            ),
            SettingRec(
              child: ListTile(
                  leading:
                      Icon(Icons.account_box, size: 28.0, color: Colors.white),
                  title: const Text("Username",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans")),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  }

                  //child: Icon(Icons.account_box, size: 28.0, color: Colors.white),

                  ),
            ),
            SettingRec(
              child: ListTile(
                  leading: Icon(Icons.monetization_on,
                      size: 28.0, color: Colors.white),
                  title: const Text("Default tip",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans")),
                  onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> DefaultTipScreen()));
              }
              ),
            ),
            SettingRec(
              child: ListTile(
                  leading:
                      Icon(Icons.drive_eta, size: 28.0, color: Colors.white),
                  title: const Text("Drive with Zip",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans")),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  }),
            ),
            SettingRec(
              child: ListTile(
                  leading: Icon(Icons.lock, size: 28.0, color: Colors.white),
                  title: const Text("Privacy",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans")),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  }),
            ),
            SettingRec(
              child: ListTile(
                  leading: Icon(Icons.gavel, size: 28.0, color: Colors.white),
                  title: const Text("Legal",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans")),
                  onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> LegalInformationScreen()));
              }
              ),
            ),
            SettingRec(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: Icon(Icons.email, size: 28.0, color: Colors.white),
                  ),
                  Text("     Email",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans"))
                ],
              ),
            ),
            SettingRec(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: Icon(Icons.local_phone,
                        size: 28.0, color: Colors.white),
                  ),
                  Text("     Phone",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans"))
                ],
              ),
            ),
            SettingRec(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: Icon(Icons.home, size: 28.0, color: Colors.white),
                  ),
                  Text("     Home Address",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans"))
                ],
              ),
            ),
            SettingRec(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: Icon(Icons.not_interested,
                        size: 28.0, color: Colors.white),
                  ),
                  Text("     Sign Out",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans"))
                ],
              ),
            ),
          ],
        ),
      ),
    ),
   );
  }
}

class TopRectangle extends StatelessWidget {
  final color;
  final height;
  final width;
  final child;

  TopRectangle(
      {this.child, this.color, this.height = 100.0, this.width = 500.0});

  build(context) {
    return Container(
      width: width,
      height: height,
      color: Colors.white,
      child: child,
    );
  }
}

class SettingRec extends StatelessWidget {
  final color;
  final decoration;
  final width;
  final height;
  // final borderWidth;
  final child;
  SettingRec(
      {this.child,
      this.color,
      this.width = 500.0,
      this.decoration,
      this.height = 55.0});

  build(context) {
    return Container(
      width: width,
      height: height,
      color: Color.fromRGBO(76, 86, 96, 1.0),
      child: child,
    );
  }
}
