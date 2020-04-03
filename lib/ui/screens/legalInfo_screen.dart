import "package:flutter/material.dart";


class LegalInformationScreen extends StatefulWidget {
  _LegalInformationScreenState createState() => _LegalInformationScreenState();
}
var tipAmount = '';
class _LegalInformationScreenState extends State<LegalInformationScreen> {
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
       body: Padding(
        padding: const EdgeInsets.only(
            top: 23.0, bottom: 0.0, left: 0.0, right: 0.0,),
            child: Column(
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
                  Text("   Legal Information",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 36.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans"))
                ],
              ),
               ),
       
             Padding(
                    padding: const EdgeInsets.only(left: 20.0, right:20.0, top: 15.0 ),),
            Text("  Information heading",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 28.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans")),
             Padding(
                    padding: const EdgeInsets.only(left: 20.0, right:20.0, top: 15.0 ),), 
             Text("Information regarding any data collection and use will go here so that the users are informed of its use in accordance with various state laws.",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans")),
             
       ],
       

     ),),
     
   ),);
   }
}






class TopRectangle extends StatelessWidget {
  final color;
  final height;
  final width;
  final child;
  final posi;
  TopRectangle({this.posi, this.child, this.color, this.height = 100.0, this.width = 500.0});
    
  build(context) {
  
    return Container(
      width: width,
      height: height,
      color: Color.fromRGBO(76, 86, 96, 1.0),
      child: child,
    );
  }
}