import 'package:flutter/material.dart';

void main()=>runApp(MaterialApp(
  home: MyTest(),
));

class MyTest extends StatefulWidget {
  const MyTest({Key? key}) : super(key: key);

  @override
  _MyTestState createState() => _MyTestState();
}

class _MyTestState extends State<MyTest> {
  var default_player_logo = 'assets/images/img2.png';
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 20,
      child: SizedBox(height:20,width:20,child: Container(child: Image.asset(default_player_logo))),
    );
  }
}
