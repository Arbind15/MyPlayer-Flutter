import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'main.dart';

// void main()=>runApp(MaterialApp(
//   home: MyVisualizer(),
// ));

class MyVisualizer extends StatefulWidget {
  var Status;
  MyVisualizer(this.Status);


  @override
  _MyVisualizerState createState() => _MyVisualizerState();
}
class _MyVisualizerState extends State<MyVisualizer> with SingleTickerProviderStateMixin {
  var height=40;
  var width=5.0;
  var color=Colors.black.withOpacity(0.5);
  var h1,h2,h3,h4;
  var animControl;
  var rnd=Random();
  var scaleAnimation;

  @override
  void initState(){
    animControl=AnimationController(vsync: this,duration: Duration(seconds: 20),lowerBound: 0.5,animationBehavior: AnimationBehavior.preserve,);
    animControl.addListener((){
      setState(() {
          h1=rnd.nextInt(height).toDouble();
          h2=rnd.nextInt(height).toDouble();
          h3=rnd.nextInt(height).toDouble();
          h4=rnd.nextInt(height).toDouble();
      });
    });

    scaleAnimation = new Tween(
      begin: 0.5,
      end: 1.0,
    ).animate(new CurvedAnimation(
        parent: animControl,
        curve: Curves.linearToEaseOut
    ));

    animControl.repeat();



    super.initState();

  }

  @override
  void dispose(){
    animControl.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnimatedBuilder(
            animation: animControl,
            builder: (context,child){
              return SizeTransition(sizeFactor: animControl,child: child,);
            },
            child: Container(
              height: h1,
              width: width,
              color: color,
            ),
            // curve: Curve.bounceOut;
          ),
          AnimatedBuilder(
            animation: animControl,
            builder: (context,child){
              return SizeTransition(sizeFactor: animControl,child: child,);
            },
            child: Container(
              height: h2,
              width: width,
              color: color,
            ),
            // curve: Curve.bounceOut;
          ),
          AnimatedBuilder(
            animation: animControl,
            builder: (context,child){
              return SizeTransition(sizeFactor: animControl,child: child,);
            },
            child: Container(
              height: h3,
              width: width,
              color: color,
            ),
            // curve: Curve.bounceOut;
          ),
          AnimatedBuilder(
            animation: animControl,
            builder: (context,child){
              return SizeTransition(sizeFactor: animControl,child: child,);
            },
            child: Container(
              height: h4,
              width: width,
              color: color,
            ),
            // curve: Curve.bounceOut;
          ),



          // Container(
          //   height: 100,
          //   width: 5,
          //   color: Colors.green,
          // ),
          // Container(
          //   height: 100,
          //   width: 5,
          //   color: Colors.green,
          // ),
          // Text(widget.Status.toString()),
        ],
      ),
    );
  }
}












// class MyVisualizer extends StatelessWidget {
//   List<Color> colors=[Colors.blueAccent,Colors.greenAccent,Colors.redAccent,Colors.yellowAccent];
//   List<int> duration=[900,700,600,800,500];
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: new List<Widget>.generate(10, (index) => Visualizer(colors[index%4],duration[index%5]))
//     );
//   }
// }
//
// class Visualizer extends StatefulWidget {
//   final int duration;
//   final Color color;
//
//   Visualizer(this.color,this.duration);
//
//
//   @override
//   _VisualizerState createState() => _VisualizerState();
// }
//
// class _VisualizerState extends State<Visualizer> with SingleTickerProviderStateMixin {
//   var animation;
//   var animController;
//
//   @override
//   void initState(){
//     super.initState();
//     animController=AnimationController(duration: Duration(milliseconds: widget.duration),vsync: this);
//     final curvedAnimation=CurvedAnimation(parent: animController, curve: Curves.easeInCubic);
//     // animation=Tween(begin: 0,end: 10).animate(curvedAnimation)..addListener(() {
//     //   setState(() {
//     //
//     //   });
//     // });
//     animController.repeat(reverse:true);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 10,
//       decoration: BoxDecoration(
//         color: widget.color,
//         borderRadius: BorderRadius.circular(5)
//       ),
//       height: animController.value,
//     );
//   }
// }








