import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:zip/CustomIcons/custom_icons_icons.dart';

class PromosScreen extends StatefulWidget {
  @override
  _PromosScreenState createState() => _PromosScreenState();
}

class _PromosScreenState extends State<PromosScreen> {
  VoidCallback onBackPress;
  double _credits = 0.0;

  @override
  void initState() {
    super.initState();
    //Tested back button, not working.
    //Same error as Profile_Screen.
    //element.contains(element) != true
    // onBackPress = () {
    //     Navigator.of(context).pop();
    //   };
  }

  void _increment() {
    setState(() {
      _credits += 0.1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(76, 86, 96, 1.0),
        body: ListView(
          children: <Widget>[
            Center(
              child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 10),
                  child: _promos),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 6,
                  right: MediaQuery.of(context).size.width / 4,
                  left: MediaQuery.of(context).size.width / 4),
              child: _fireIcon,
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: 45.0,
                  right: MediaQuery.of(context).size.width / 6,
                  left: MediaQuery.of(context).size.width / 6),
              child: Container(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(color: Colors.white)),
                ),
                height: MediaQuery.of(context).size.height / 17,
                child: _enterPromo,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: 10.0,
                  right: MediaQuery.of(context).size.width / 4,
                  left: MediaQuery.of(context).size.width / 4),
              child: FlatButton(
                onPressed: () {
                  _increment();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                color: Colors.white,
                child: Text(
                  "Apply",
                  softWrap: true,
                  style: TextStyle(
                    color: Color.fromRGBO(76, 86, 96, 1.0),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                    fontFamily: "OpenSans",
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                  padding: EdgeInsets.only(top: 100.0), child: _creditText),
            ),
            //progress bar attempt
            Padding(
                padding: EdgeInsets.only(
                    top: 10.0,
                    right: MediaQuery.of(context).size.width / 12,
                    left: MediaQuery.of(context).size.width / 12),
                child: buildProgressBar(context)),
          ],
        ),
      ),
    );
  }

  final Text _promos = Text(
    "Promos",
    softWrap: true,
    style: TextStyle(
      color: Colors.white,
      fontSize: 42.0,
      fontWeight: FontWeight.w600,
      fontFamily: "OpenSans",
    ),
  );

  final Icon _fireIcon =
      Icon(CustomIcons.fire, size: 110.0, color: Colors.white);

  final TextEditingController _promoController = new TextEditingController();
  final TextField _enterPromo = TextField(
    textAlign: TextAlign.center,
    style: TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontFamily: "OpenSans",
      fontWeight: FontWeight.w300,
      decoration: TextDecoration.none,
    ),
    decoration: InputDecoration(
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 20.0,
        fontFamily: "OpenSans",
        fontWeight: FontWeight.w300,
        decoration: TextDecoration.none,
      ),
      hintText: "Promo Code",
      border: InputBorder.none,
    ),
  );

  final Text _creditText = Text(
    "Credits",
    softWrap: true,
    style: TextStyle(
      color: Colors.white,
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      fontFamily: "OpenSans",
    ),
  );

  //Call to database to check credits.

  Widget buildProgressBar(BuildContext context) {
    try {
      return LinearPercentIndicator(
        width: MediaQuery.of(context).size.width / 1.2,
        animation: false,
        lineHeight: 20.0,
        percent: _credits,
        progressColor: Colors.grey,
        backgroundColor: Colors.white,
        center: Text((_credits * 100).round().toInt().toString() + '/' + '100'),
      );
    } catch (e) {
      return LinearPercentIndicator(
        width: MediaQuery.of(context).size.width / 1.2,
        animation: false,
        lineHeight: 20.0,
        percent: 1.0,
        progressColor: Colors.grey,
        backgroundColor: Colors.white,
        center: Text((1.0 * 100).round().toInt().toString() + '/' + '100'),
      );
    }
  }
}
