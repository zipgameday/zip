
import 'package:flutter/material.dart';
import 'package:zip/ui/widgets/custom_flat_button.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:zip/business/auth.dart';
import 'package:zip/ui/widgets/custom_gplus_fb_btn.dart';

class WelcomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 35.0, right: 15.0, left: 15.0),
            child: Text(
              "Zip",
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(76, 86, 96, 1.0),
                decoration: TextDecoration.none,
                fontSize: 42.0,
                fontWeight: FontWeight.w900,
                fontFamily: "OpenSans",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 35.0, right: 15.0, left: 15.0),
            child: Icon(Icons.local_taxi, size: 75.0, color: Color.fromRGBO(76, 86, 96, 1.0))
          ),
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 10, 
                                left: MediaQuery.of(context).size.width / 10,
                                right: MediaQuery.of(context).size.width / 10),
            child: CustomFlatButton(
              title: "Log In",
              fontSize: 22,
              fontWeight: FontWeight.w700,
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed("/signin");
              },
              splashColor: Colors.black12,
              borderColor: Color.fromRGBO(76, 86, 96, 1.0),
              borderWidth: 0,
              color: Color.fromRGBO(76, 86, 96, 1.0),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
            child: CustomFlatButton(
              title: "Sign Up",
              fontSize: 22,
              fontWeight: FontWeight.w700,
              textColor: Color.fromRGBO(76, 86, 96, 1.0),
              onPressed: () {
                Navigator.of(context).pushNamed("/signup");
              },
              splashColor: Colors.black12,
              borderColor: Colors.black12,
              borderWidth: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 35.0, right: 15.0, left: 15.0),
            child: Text(
              "Or",
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(76, 86, 96, 1.0),
                decoration: TextDecoration.none,
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                fontFamily: "OpenSans",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 25.0, right: 5.0),
            child: Center(
              child: GoogleButton(
                onPressed: () { AuthService().googleSignIn(); },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 5.0),
            child: Center(
              child: FacebookSignInButton(onPressed: () { AuthService().facebookSignIn(); },
              borderRadius: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
}
