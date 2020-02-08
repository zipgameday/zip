import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zip/business/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zip/business/validator.dart';
import 'package:zip/models/user.dart';
import 'package:zip/ui/screens/main_screen.dart';
import 'package:zip/ui/widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  //final User user;
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  VoidCallback onBackPress;
  final TextEditingController _firstname = new TextEditingController();
  final TextEditingController _lastname = new TextEditingController();
  final TextEditingController _number = new TextEditingController();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  final TextEditingController _homeAddress = new TextEditingController();
  CustomTextField2 _firstnameField;
  CustomTextField2 _lastnameField;
  CustomTextField2 _phoneField;
  CustomTextField2 _emailField;
  CustomTextField2 _passwordField;
  CustomTextField2 _homeAddressField;
  bool _blackVisible = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    onBackPress = () {
      Navigator.of(context).pop();
    };

    _firstnameField = new CustomTextField2(
        baseColor: Colors.grey,
        borderColor: Colors.black,
        errorColor: Colors.red,
        controller: _firstname,
        hint: "First Name",
        validator: Validator.validateName,
        customTextIcon:
            Icon(Icons.person, color: Color.fromRGBO(76, 86, 96, 1.0)),
        isEditable: _isEditing);
    _lastnameField = new CustomTextField2(
        baseColor: Colors.grey,
        borderColor: Colors.black,
        errorColor: Colors.red,
        controller: _lastname,
        hint: "Last Name",
        validator: Validator.validateName,
        customTextIcon:
            Icon(Icons.person, color: Color.fromRGBO(76, 86, 96, 1.0)),
        isEditable: _isEditing);
    _phoneField = new CustomTextField2(
        baseColor: Colors.grey[400],
        borderColor: Colors.black,
        errorColor: Colors.red,
        controller: _number,
        hint: "Phone Number",
        validator: Validator.validateNumber,
        inputType: TextInputType.number,
        customTextIcon:
            Icon(Icons.phone, color: Color.fromRGBO(76, 86, 96, 1.0)),
        isEditable: _isEditing);
    _emailField = new CustomTextField2(
        baseColor: Colors.grey[400],
        borderColor: Colors.black,
        errorColor: Colors.red,
        controller: _email,
        hint: "E-mail Address",
        inputType: TextInputType.emailAddress,
        validator: Validator.validateEmail,
        customTextIcon:
            Icon(Icons.mail, color: Color.fromRGBO(76, 86, 96, 1.0)),
        isEditable: _isEditing);
    _passwordField = new CustomTextField2(
        baseColor: Colors.grey[400],
        borderColor: Colors.black,
        errorColor: Colors.red,
        controller: _password,
        obscureText: true,
        hint: "Password",
        validator: Validator.validatePassword,
        customTextIcon:
            Icon(Icons.lock, color: Color.fromRGBO(76, 86, 96, 1.0)),
        isEditable: _isEditing);
    _homeAddressField = new CustomTextField2(
        baseColor: Colors.grey[400],
        borderColor: Colors.black,
        errorColor: Colors.red,
        controller: _password,
        obscureText: true,
        hint: "Password",
        validator: Validator.validatePassword,
        customTextIcon:
            Icon(Icons.home, color: Color.fromRGBO(76, 86, 96, 1.0)),
        isEditable: _isEditing);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 4,
                      color: Color.fromRGBO(76, 86, 96, 1.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              _isEditing ? new Container() : getEditButton(context),
                            ],
                          ),
                          FlatButton(
                            splashColor: Color.fromRGBO(76, 86, 96, 1.0),
                            onPressed: () {},
                            child: CircleAvatar(
                              maxRadius: MediaQuery.of(context).size.width / 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                        child: buildCards(
                            context,
                            Icon(Icons.person,
                                color: Color.fromRGBO(76, 86, 96, 1.0)))),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 10.0),
                        child: buildCards(
                            context,
                            Icon(Icons.person,
                                color: Color.fromRGBO(76, 86, 96, 1.0)))),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                      child: buildCards(
                          context,
                          Icon(Icons.email,
                              color: Color.fromRGBO(76, 86, 96, 1.0))),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                      child: buildCards(
                          context,
                          Icon(Icons.phone,
                              color: Color.fromRGBO(76, 86, 96, 1.0))),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 10.0),
                        child: buildCards(
                            context,
                            Icon(Icons.lock,
                                color: Color.fromRGBO(76, 86, 96, 1.0)))),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      child: buildCards(
                          context,
                          Icon(Icons.home,
                              color: Color.fromRGBO(76, 86, 96, 1.0))),
                    ),
                    _isEditing ? getSaveAndCancel(context) : new Container(),
                  ],
                ),
                SafeArea(
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
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

  Widget getEditButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit, color: Colors.white),
      onPressed: (){
        setState(() {
          _isEditing = true;
        });
      }
    );
  }

//if isEditing = true
//Need some way of enabling text fields
  Widget getSaveAndCancel(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: RaisedButton(
            onPressed: () {
              setState(() {
                _isEditing = false;
              });
            },
            color: Color.fromRGBO(76, 86, 96, 1.0),
            child: Text(
              "Save",
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "OpenSans",
                  fontWeight: FontWeight.w300,
                  fontSize: 24.0,
                  decoration: TextDecoration.none),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: RaisedButton(
            onPressed: () {
              setState(() {
                _isEditing = false;
              });
            },
            color: Color.fromRGBO(76, 86, 96, 1.0),
            child: Text(
              "Cancel",
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "OpenSans",
                  fontWeight: FontWeight.w300,
                  fontSize: 24.0,
                  decoration: TextDecoration.none),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCards(BuildContext context, final Icon prefIcon) {
    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.black,
          width: 0.5,
        ),
      ),
      color: Colors.white,
      child: TextField(
        enabled: _isEditing,
        onChanged: (text) {},
        style: TextStyle(
            color: Color.fromRGBO(76, 86, 96, 1.0),
            fontFamily: "OpenSans",
            fontWeight: FontWeight.w300,
            decoration: TextDecoration.none),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(),
            child: prefIcon,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
