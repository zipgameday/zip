import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zip/business/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zip/business/validator.dart';
import 'package:zip/models/user.dart';
import 'package:zip/ui/widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  //final User user;
   _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>{
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
      customTextIcon: Icon(Icons.person, color: Color.fromRGBO(76, 86, 96, 1.0)),
    );
    _lastnameField = new CustomTextField2(
      baseColor: Colors.grey,
      borderColor: Colors.black,
      errorColor: Colors.red,
      controller: _lastname,
      hint: "Last Name",
      validator: Validator.validateName,
      customTextIcon: Icon(Icons.person, color: Color.fromRGBO(76, 86, 96, 1.0))
    );
    _phoneField = new CustomTextField2(
      baseColor: Colors.grey[400],
      borderColor: Colors.black,
      errorColor: Colors.red,
      controller: _number,
      hint: "Phone Number",
      validator: Validator.validateNumber,
      inputType: TextInputType.number,
      customTextIcon: Icon(Icons.phone, color: Color.fromRGBO(76, 86, 96, 1.0))
    );
    _emailField = new CustomTextField2(
      baseColor: Colors.grey[400],
      borderColor: Colors.black,
      errorColor: Colors.red,
      controller: _email,
      hint: "E-mail Address",
      inputType: TextInputType.emailAddress,
      validator: Validator.validateEmail,
      customTextIcon: Icon(Icons.mail, color: Color.fromRGBO(76, 86, 96, 1.0))
    );
    _passwordField = new CustomTextField2(
      baseColor: Colors.grey[400],
      borderColor: Colors.black,
      errorColor: Colors.red,
      controller: _password,
      obscureText: true,
      hint: "Password",
      validator: Validator.validatePassword,
      customTextIcon: Icon(Icons.lock, color: Color.fromRGBO(76, 86, 96, 1.0))
    );
    _homeAddressField = new CustomTextField2(
      baseColor: Colors.grey[400],
      borderColor: Colors.black,
      errorColor: Colors.red,
      controller: _password,
      obscureText: true,
      hint: "Password",
      validator: Validator.validatePassword,
      customTextIcon: Icon(Icons.home, color: Color.fromRGBO(76, 86, 96, 1.0))
    );

  }

  

  

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        body: Stack (
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
                            FlatButton(
                              splashColor: Color.fromRGBO(76, 86, 96, 1.0),
                              onPressed: (){},
                              child: CircleAvatar(
                                maxRadius: MediaQuery.of(context).size.width / 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          child: _firstnameField,
                      ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                          child: _lastnameField,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                          child: _emailField,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                          child: _phoneField,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                          child: _passwordField
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          child: _homeAddressField,
                        ),
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
}