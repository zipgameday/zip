import "package:flutter/material.dart";
import "package:zip/ui/widgets/custom_text_field.dart";
import 'package:zip/business/auth.dart';
import 'package:zip/business/validator.dart';
import 'package:flutter/services.dart';
import 'package:zip/ui/widgets/custom_flat_button.dart';
import 'package:zip/ui/widgets/custom_alert_dialog.dart';
import 'package:zip/models/user.dart';

class SettingsScreen extends StatefulWidget {
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[70],
      body: Padding(
        padding: const EdgeInsets.only(
            top: 23.0, bottom: 20.0, left: 0.0, right: 0.0,),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TopRectangle(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(Icons.arrow_back, size: 28.0, color: Colors.black),
                  ),
                  Text("             Settings",
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
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(Icons.account_box, size: 28.0, color: Colors.white),
                  ),
                  Text("  Username",
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
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(Icons.monetization_on, size: 28.0, color: Colors.white),
                  ),
                  Text("  Default tip",
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
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(Icons.drive_eta, size: 28.0, color: Colors.white),
                  ),
                  Text("  Drive with Zip",
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
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(Icons.lock, size: 28.0, color: Colors.white),
                  ),
                  Text("  Privacy",
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
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(Icons.gavel, size: 28.0, color: Colors.white),
                  ),
                  Text("  Legal",
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
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(Icons.email, size: 28.0, color: Colors.white),
                  ),
                  Text("  Email",
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
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(Icons.local_phone, size: 28.0, color: Colors.white),
                  ),
                  Text("  Phone",
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
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(Icons.home, size: 28.0, color:Colors.white),
                  ),
                  Text("  Home Address",
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
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(Icons.not_interested, size: 28.0, color: Colors.white),
                  ),
                  Text("  Sign Out",
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
    );
  }
}

class TopRectangle extends StatelessWidget {
  final color;
  final height;
  final width;
  final child;
  
  TopRectangle({this.child, this.color, this.height = 100.0, this.width = 500.0});
    
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
