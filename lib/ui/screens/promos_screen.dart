import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:zip/CustomIcons/custom_icons_icons.dart';

class PromosScreen extends StatefulWidget {
  @override
  _PromosScreenState createState() => _PromosScreenState();
}

class _PromosScreenState extends State<PromosScreen> {
  VoidCallback onBackPress;
  num _credits = 0;
  @override
  void initState() {
    super.initState();
    //Tested back button, not working.
    //Same error as Profile_Screen.
    //element.contains(element) != true
    // onBackPress = () {
    //     Navigator.of(context).pop();
    //   };
    onBackPress = () {
      Navigator.of(context).pop();
    };
  }

  void _increment() {
    setState(() {
      _credits += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(76, 86, 96, 1.0),
      body: _credits < 100
          ? buildNonMaxCreditWidget(context)
          : buildMaxCreditsWidget(context),
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

  static TextEditingController _promoController = new TextEditingController();
  final TextField _enterPromo = new TextField(
    textAlign: TextAlign.center,
    controller: _promoController,
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
        percent: _credits / 100,
        progressColor: Colors.grey,
        backgroundColor: Colors.white,
        center: Text((_credits).toString() + '/' + '100'),
      );
    } catch (e) {
      return LinearPercentIndicator(
        width: MediaQuery.of(context).size.width / 1.2,
        animation: false,
        lineHeight: 20.0,
        percent: 1.0,
        progressColor: Colors.grey,
        backgroundColor: Colors.white,
        center: Text("100/100"),
      );
    }
  }

  Widget buildNonMaxCreditWidget(BuildContext context) {
    return ListView(
      children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: SafeArea(
              child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBackPress,
          )),
        ),
        Center(
          child: Padding(padding: EdgeInsets.only(top: 10.0), child: _promos),
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
              if (_credits < 100) {
                _increment();
              }
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
          child:
              Padding(padding: EdgeInsets.only(top: 100.0), child: _creditText),
        ),
        //progress bar attempt
        Padding(
            padding: EdgeInsets.only(
                top: 10.0,
                right: MediaQuery.of(context).size.width / 12,
                left: MediaQuery.of(context).size.width / 12),
            child: buildProgressBar(context)),
      ],
    );
  }

  Widget buildMaxCreditsWidget(BuildContext context) {
    return ListView(
      children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: SafeArea(
              child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBackPress,
          )),
        ),
        Center(
          child: Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 10),
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
            padding: EdgeInsets.only(top: 55.0, left: 15.0, right: 15.0),
            child: Text(
              "Congratualtions, you have earned a free ride. Press \'Use Credits'\ to redeem!",
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 24.0,
                fontFamily: "OpenSans",
              ),
            )),
        Padding(
            padding: EdgeInsets.only(
                top: 25.0,
                bottom: 20.0,
                left: MediaQuery.of(context).size.width / 4,
                right: MediaQuery.of(context).size.width / 4),
            child: buildUseCreditsButton(context)),
      ],
    );
  }

  Widget buildUseCreditsButton(BuildContext context) {
    return FlatButton(
      onPressed: () {},
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.white,
      child: Text(
        "Use Credits",
        softWrap: true,
        style: TextStyle(
          color: Color.fromRGBO(76, 86, 96, 1.0),
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
          fontFamily: "OpenSans",
        ),
      ),
    );
  }
}
