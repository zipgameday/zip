import 'dart:core';
import "package:flutter/material.dart";
import 'package:zip/CustomIcons/custom_icons_icons.dart';
import 'package:zip/business/auth.dart';
import "package:zip/ui/widgets/custom_text_field.dart";
import 'package:zip/business/validator.dart';
import 'package:flutter/services.dart';
import 'package:zip/models/user.dart';
import 'package:zip/ui/widgets/custom_flat_button.dart';
import 'package:zip/ui/widgets/custom_alert_dialog.dart';
import 'package:zip/ui/widgets/custom_gplus_fb_btn.dart';


class SignUpScreen extends StatefulWidget {
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullname = new TextEditingController();
  final TextEditingController _number = new TextEditingController();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  CustomTextField _nameField;
  CustomTextField _phoneField;
  CustomTextField _emailField;
  CustomTextField _passwordField;
  bool _blackVisible = false;
  VoidCallback onBackPress;

  @override
  void initState() {
    super.initState();

    onBackPress = () {
      Navigator.of(context).pop();
    };

    _nameField = new CustomTextField(
      baseColor: Colors.grey[400],
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _fullname,
      hint: "Full Name",
      validator: Validator.validateName,
      customTextIcon: Icon(Icons.person, color: Colors.grey[400])
    );
    _phoneField = new CustomTextField(
      baseColor: Colors.grey[400],
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _number,
      hint: "Phone Number",
      validator: Validator.validateNumber,
      inputType: TextInputType.number,
      customTextIcon: Icon(Icons.phone, color: Colors.grey[400])
    );
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
      customTextIcon: Icon(Icons.lock, color: Colors.grey[400])
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
                        "Create new account",
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
                      padding:
                          EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                      child: _nameField,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
                      child: _phoneField,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
                      child: _emailField,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
                      child: _passwordField,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 25.0, horizontal: 40.0),
                      child: CustomFlatButton(
                        title: "Sign Up",
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        textColor: Colors.white,
                        onPressed: () {
                          _signUp(
                              fullname: _fullname.text,
                              email: _email.text,
                              number: _number.text,
                              password: _password.text);
                        },
                        splashColor: Colors.black12,
                        borderColor: Color.fromRGBO(59, 89, 152, 1.0),
                        borderWidth: 0,
                        color: Color.fromRGBO(76, 86, 96, 1.0),
                      ),
                    ),
                    Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, bottom: 20.0, left: 110.0, right: 0.0),
                          child: Row(
                            children: <Widget>[
                              CustomCircleButton(
                                color: Color(0xFF3B5998),
                                splashColor: Colors.black12,
                                borderColor: Color.fromRGBO(188, 224, 253, 0.0),
                                onPressed: () { },
                                borderWidth: 2.0,
                                customIcon: Icon(CustomIcons.facebook, size: 35, 
                                                    color: Colors.white),
                              ),
                              CustomCircleButton(
                              color: Color(0xFFD93F21),
                              splashColor: Colors.black12,
                              borderColor: Color.fromRGBO(188, 224, 253, 0.0),
                              onPressed: () { },
                              borderWidth: 2.0,
                              customIcon: Icon(CustomIcons.google, size: 35, 
                                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 20.0, bottom: 60.0, left: 10.0, right: 0.0),
                        child: CustomFlatButtonWithUnderline(
                          title: "Already have an account?",
                          textColor: Color.fromRGBO(76, 86, 96, 1.0),
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

  void _signUp(
      {String fullname,
      String number,
      String email,
      String password,
      BuildContext context}) async {
    if (Validator.validateName(fullname) &&
        Validator.validateEmail(email) &&
        Validator.validateNumber(number) &&
        Validator.validatePassword(password)) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        _changeBlackVisible();
        await Auth.signUp(email, password).then((uID) {
          Auth.addUser(new User(
              userID: uID,
              email: email,
              firstName: fullname,
              profilePictureURL: ''));
          onBackPress();
        });
      } catch (e) {
        print("Error in sign up: $e");
        String exception = Auth.getExceptionText(e);
        _showErrorAlert(
          title: "Signup failed",
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
