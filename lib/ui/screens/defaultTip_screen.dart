import "package:flutter/material.dart";


class DefaultTipScreen extends StatefulWidget {
  _DefaultTipScreenState createState() => _DefaultTipScreenState();
}
var tipAmount = '';
var tip15 = '15';
var tip20 = '20';
var tip25 = '25';
class _DefaultTipScreenState extends State<DefaultTipScreen> {
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
            child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.max,
            
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
                  Text("       Default Tip",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 36.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans"))
                ],
              ),
               ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
             child:Text("Choose Default:",
                  textAlign: TextAlign.center ,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w400,
                          fontFamily: "OpenSans"))
            ),
          Padding(padding: const EdgeInsets.only(top: 30.0, right: 15.0, left: 15.0),),
            Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
             children: <Widget>[
             FlatButton(
               onPressed: (){setState(() {tipAmount = tip15;});} ,
               child: CircularButton(
               child: Center(child:Text('15%', 
                             style: TextStyle(color: Colors.white,
                                              fontSize: 24.0)),)
              ), ),

FlatButton(
               onPressed: (){setState(() {tipAmount = tip20;});} ,
              
              child: CircularButton(
              child:Center(child: Text('20%', 
                            style: TextStyle(color: Colors.white,
                                             fontSize: 24.0)),),
             ),),
            FlatButton(
               onPressed: (){setState(() {tipAmount = tip25;});} ,   
              child: CircularButton(
               child: Center(child: Text('25%', 
                             style: TextStyle(color: Colors.white,
                                              fontSize: 24.0)),),
             ),
             ),
            
             
             ]
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
             child:Text("Create Custom Default:",
                  textAlign: TextAlign.center ,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w400,
                          fontFamily: "OpenSans")),
                          ),
            Padding(padding: const EdgeInsets.only(top: 30.0,left: 100.0, right:100.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              onChanged: (v) => setState((){tipAmount=v;}),
               validator:(value){
                 if (value.isEmpty){
                   return 'Please enter a numerical percentage';
                 }
                
                 return null;
               },
             ),
            ),
           DisplayTip(tipAmount),
                          
             ],
            
            
            ),
                ),
                         ),
     ),
   );

  }
}

class DisplayTip extends StatelessWidget{
  DisplayTip(tipAmount);
  build(context){
    return Container(
     child: Padding(
              padding: const EdgeInsets.only(top: 30.0),
             child:Text("Default Tip: " + tipAmount + '%',
                  textAlign: TextAlign.center ,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w400,
                          fontFamily: "OpenSans"))
      )
    );
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

class CircularButton extends StatelessWidget {
  final child;
  CircularButton({this.child});
  @override
  Widget build(BuildContext context) {
    
      
      
    return Container(
        child: ClipOval(
          child: Container(
            color: Color.fromRGBO(76, 86, 96, 1.0),
            height: 105.0, // height of the button
            width: 105.0, // width of the button
            child: child,
          ),
        ),
    );
     
  }
}
