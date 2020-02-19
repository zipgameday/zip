import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zip/business/auth.dart';
import 'package:zip/business/user.dart';
import 'package:zip/business/validator.dart';
import 'package:zip/models/user.dart';
import 'dart:core';
import 'package:flutter/services.dart';
import 'package:zip/ui/widgets/custom_alert_dialog.dart';

class ProfileScreen extends StatefulWidget {
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  VoidCallback onBackPress;
  final AuthService auth = AuthService();
  final UserService userService = UserService();
  final TextEditingController _firstname = new TextEditingController();
  final TextEditingController _lastname = new TextEditingController();
  final TextEditingController _number = new TextEditingController();
  final TextEditingController _email = new TextEditingController();
  //final TextEditingController _password = new TextEditingController();
  final TextEditingController _homeAddress = new TextEditingController();
  bool _blackVisible = false;
  bool _isEditing = false;
  User user;

  @override
  void initState() {
    super.initState();

    onBackPress = () {
      Navigator.of(context).pop();
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(userService.userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User user = User.fromDocument(snapshot.data);
            if(!_isEditing) {
              _firstname.text = user.firstName;
              _lastname.text = user.lastName;
              _number.text = user.phone;
              _email.text = user.email;
              _homeAddress.text = user.homeAddress;
            }
            return Scaffold(
              body:Stack(
                children: <Widget>[
                  Stack(
                    alignment: Alignment.topLeft,
                    children: <Widget>[
                      ListView(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 3.6,
                            color: Color.fromRGBO(76, 86, 96, 1.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    _isEditing
                                        ? new Container()
                                        : getEditButton(context),
                                  ],
                                ),
                                FlatButton(
                                  splashColor: Color.fromRGBO(76, 86, 96, 1.0),
                                  onPressed: () {},
                                  child: CircleAvatar(
                                    maxRadius:
                                        MediaQuery.of(context).size.width / 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 10.0),
                              child: buildCards(
                                  context,
                                  Icon(Icons.person,
                                      color: Color.fromRGBO(76, 86, 96, 1.0)),
                                  _firstname)),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 10.0),
                              child: buildCards(
                                  context,
                                  Icon(Icons.person,
                                      color: Color.fromRGBO(76, 86, 96, 1.0)),
                                  _lastname)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10.0),
                            child: buildCards(
                                context,
                                Icon(Icons.email,
                                    color: Color.fromRGBO(76, 86, 96, 1.0)),
                                _email),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 10.0),
                            child: buildCards(
                                context,
                                Icon(Icons.phone,
                                    color: Color.fromRGBO(76, 86, 96, 1.0)),
                                _number),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 6.0, horizontal: 10.0),
                            child: buildCards(
                                context,
                                Icon(Icons.home,
                                    color: Color.fromRGBO(76, 86, 96, 1.0)),
                                _homeAddress),
                          ),
                          _isEditing
                              ? getSaveAndCancel(context)
                              : new Container(),
                          _isEditing
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.0,
                                      bottom: 10.0,
                                      right:
                                          MediaQuery.of(context).size.width / 6,
                                      left: MediaQuery.of(context).size.width /
                                          6),
                                  child: FlatButton(
                                      onPressed: () {
                                      },
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(12.0)),
                                      child: Text("Change Password",
                                          softWrap: true,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color:
                                                Color.fromRGBO(76, 86, 96, 1.0),
                                            fontSize: 24.0,
                                            fontFamily: "OpenSans",
                                            fontWeight: FontWeight.w300,
                                          ))))
                              : new Container(),
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
            );
          } else {
            return Container(
              color: Colors.white,
            );
          }
        }
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
        onPressed: () {
          setState(() {
            _isEditing = true;
          });
        });
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
            onPressed: () async {
               await _editInfo(
                  firstname: _firstname.text,
                  lastname: _lastname.text,
                  email: _email.text,
                  phone: _number.text,
                  home: _homeAddress.text);
              // bool isValid = await Validator.validateStreetAddress(_homeAddress.text);
              // print(isValid);
              setState(() {
                //reset all textEditing controllers text information.
                //_updateTextEditingControllers();
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
                //reset all textEditing Controllers.
                //_updateTextEditingControllers();
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

//TextEditingController controls what text is shown
//Right now, it will just change to whatever you edit.
//Once User provider is built, we will call that.
  Widget buildCards(
      BuildContext context, Icon prefIcon, TextEditingController controller) {
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
        controller: controller,
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

  Future<void> _editInfo(
      {String firstname,
      String lastname,
      String phone,
      String email,
      String home,
      BuildContext context}) async {
      _changeBlackVisible();
    if (Validator.validateName(firstname) &&
            Validator.validateName(lastname) &&
            Validator.validateEmail(email) &&
            Validator.validateNumber(phone)
        ) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        //Updating information from user
        await Firestore.instance
            .collection('users')
            .document(userService.userID)
            .updateData({
          'firstName': firstname,
          'lastName': lastname,
          'phone': phone,
          'email': email,
          'homeAddress': home
        }).then((blah) {
          _changeBlackVisible();
        });
      } catch (e) {
        print("Error when editing profile information: $e");
        String exception = auth.getExceptionText(e);
        _showErrorAlert(
          title: "Edit profile failed",
          content: exception,
          onPressed: _changeBlackVisible,
        );
        _changeBlackVisible();
        
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
