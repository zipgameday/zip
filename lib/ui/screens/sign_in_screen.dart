import "package:flutter/material.dart";
import "package:zip/ui/widgets/custom_text_field.dart";
import 'package:zip/business/auth.dart';
import 'package:zip/business/validator.dart';
import 'package:flutter/services.dart';
import 'package:zip/ui/widgets/custom_flat_button.dart';
import 'package:zip/ui/widgets/custom_alert_dialog.dart';
import 'package:zip/models/user.dart';
import 'package:zip/ui/widgets/custom_gplus_fb_btn.dart';
import 'package:zip/CustomIcons/custom_icons_icons.dart';

class SignInScreen extends StatefulWidget {
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  CustomTextField _emailField;
  CustomTextField _passwordField;
  bool _blackVisible = false;
  VoidCallback onBackPress;
  final auth = AuthService();

  @override
  void initState() {
    super.initState();

    onBackPress = () {
      Navigator.of(context).pop();
    };

    _emailField = new CustomTextField(
      baseColor: Colors.grey[400],
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _email,
      hint: "E-mail Address",
      inputType: TextInputType.emailAddress,
      validator: Validator.validateEmail,
      customTextIcon: Icon(Icons.mail, color: Colors.grey[400])
    );
    _passwordField = CustomTextField(
      baseColor: Colors.grey[400],
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _password,
      obscureText: true,
      hint: "Password",
      validator: Validator.validatePassword,
      customTextIcon: Icon(CustomIcons.lock, color: Colors.grey[400]),
    );

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 70.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: Text(
                        "Sign In",
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(76, 86, 96, 1.0),
                          decoration: TextDecoration.none,
                          fontSize: 32.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: "OpenSans",
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 20.0, bottom: 10.0, left: 15.0, right: 15.0),
                      child: _emailField
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 20.0, left: 15.0, right: 15.0),
                      child: _passwordField,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 40.0),
                      child: CustomFlatButton(
                        title: "Log In",
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        textColor: Colors.white,
                        onPressed: () {
                          _emailLogin(
                              email: _email.text,
                              password: _password.text,
                              context: context);
                        },
                        splashColor: Colors.black12,
                        borderColor: Color.fromRGBO(212, 20, 15, 1.0),
                        borderWidth: 0,
                        color: Color.fromRGBO(76, 86, 96, 1.0),
                      ),
                    ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10.0, bottom: 20.0, left: 10.0, right: 0.0),
                        child: CustomFlatButton(
                          title: "Forgot Password?",
                          textColor: Color.fromRGBO(76, 86, 96, 1.0),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                          onPressed: () {},
                          color: Colors.white,
                          splashColor: Colors.grey[100],
                          borderColor: Colors.white,
                          borderWidth: 0.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 50.0, bottom: 20.0, left: 10.0, right: 0.0),
                        child: Text(
                          "Dont have an account?",
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle (
                            color: Color.fromRGBO(76, 86, 96, 1.0),
                            decoration: TextDecoration.none,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                            fontFamily: "OpenSans",
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 0.0, bottom: 60.0, left: 10.0, right: 0.0),
                        child: CustomFlatButtonWithUnderline(
                          title: "Click here",
                          textColor: Color(0xFF0300F2),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                          //I would push the sign up page, 
                          //but the user could hit the back
                          //button and go to the sign in.
                          onPressed: () {},
                          color: Colors.white,
                          splashColor: Colors.grey[100],
                          borderColor: Colors.white,
                          borderWidth: 0.0,
                        ),
                      ),
                  ],
                ),
                SafeArea(
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: onBackPress,
                  ),
                ),
              ],
            ),
            Offstage(
              offstage: !_blackVisible,
              child: GestureDetector(
                onTap: () {},
                child: AnimatedOpacity(
                  opacity: _blackVisible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.ease,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeBlackVisible() {
    setState(() {
      _blackVisible = !_blackVisible;
    });
  }

  void _emailLogin(
      {String email, String password, BuildContext context}) async {
    if (Validator.validateEmail(email) &&
        Validator.validatePassword(password)) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        _changeBlackVisible();
        await auth.signIn(email, password)
            .then((uid) => Navigator.of(context).pop());
      } catch (e) {
        print("Error in email sign in: $e");
        String exception = auth.getExceptionText(e);
        _showErrorAlert(
          title: "Login failed",
          content: exception,
          onPressed: _changeBlackVisible,
        );
      }
    }
  }

  void _showErrorAlert({String title, String content, VoidCallback onPressed}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          content: content,
          title: title,
          onPressed: onPressed,
        );
      },
    );
  }
}
