import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FishSwarm(title: 'Swarm theory'),
    );
  }
}

class FishSwarm extends StatefulWidget {
  FishSwarm({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _FishSwarmState createState() => _FishSwarmState();
}

class SwarmElementData {
  double x = 0.5;
  double y = 0.2;
  double rotation = pi/2;
  double oldRx = 0.0;
  double oldRy = 0.0;
}

class _FishSwarmState extends State<FishSwarm> {
  int attraction = 1;
  int repulsion = 1;
  int alignment = 1;
  double elementWidth = 0.2;
  int numElements = 20;
  double v = 0.01;
  double alignmentParameter = 0.0;

  List<SwarmElementData> elements = new List();

  @override
  void initState() {

    for(int i = 0; i < numElements; ++i){
      elements.add(SwarmElementData());
    }

    const duration = const Duration(milliseconds:10);
    new Timer.periodic(duration, (Timer t) => updateSwarm());

    super.initState();
  }

  void avoidWalls()
  {
    double B = 0.9;
    var rng = new Random();
    for(int i = 0; i < numElements; i++) {
      var X = elements[i].x;
      var Y = elements[i].y;
      var rot = elements[i].rotation;
      //print("X $X Y $Y R $rot");

      if (X < -B && (rot > pi/2 || rot < -pi/2)) {
        rot = rng.nextDouble() * pi - pi/2.0;
      }
      else if (X > B && (rot < pi/2 || rot > -pi/2)) {
        var int = rng.nextInt(2);
        rot = rng.nextDouble() * pi/2 + pi/2.0;
        if(int == 0) {
          rot *= -1;
        }
      }
      if (Y < -B && rot < 0) {
        rot = rng.nextDouble() * pi;
      }
      else if (Y > B && rot > 0) {
        var int = rng.nextInt(2);
        rot = rng.nextDouble() * pi - pi;
        if(int == 0) {
          rot *= -1;
        }
      }

      elements[i].rotation = rot;
    }
  }

  List<int> listNeighboursInRange(elementIndex, double range)
  {
    List<int> retval = List<int>();
    SwarmElementData _thisElement = elements[elementIndex];
    for(int i = 0; i < numElements; i++) {
      if (i == elementIndex)
        continue;

      SwarmElementData _otherElement = elements[i];
      if (pow(_thisElement.x - _otherElement.x, 2) +
          pow(_thisElement.y - _otherElement.y, 2) < range) {
        retval.add(i);
      }
    }

    return retval;
  }

  void alignWithNeighbours()
  {
    for(int i = 0; i < numElements; i++) {
      elements[i].oldRx = cos(elements[i].rotation);
      elements[i].oldRy = sin(elements[i].rotation);
    }

    if(alignmentParameter == 0.0)
      return;

    double sumX = 0.0;
    double sumY = 0.0;

    for(int i = 0; i < numElements; i++) {
      List<int> neighbours = listNeighboursInRange(i, 100.0);
      for(int index = 0; index < neighbours.length; index++) {
        sumX += elements[index].oldRx;
        sumY += elements[index].oldRy;
      }

      if(sumX == 0.0 && sumY == 0.0)
        continue;

      double length = sqrt(pow(sumX,2) + pow(sumY, 2));
      sumX /= length;
      sumY /= length;

      //print(elements[i].rotation)

      elements[i].rotation = atan2(elements[i].oldRy + sumY * alignmentParameter,
          elements[i].oldRx + sumX * alignmentParameter);

    }
  }

  void applyVelocity(){
    for(int i = 0; i < numElements; i++) {
      elements[i].x += v * cos(elements[i].rotation);
      elements[i].y += v * sin(elements[i].rotation);
    }
  }

  void updateSwarm()
  {
    setState(() {
      avoidWalls();
      alignWithNeighbours();
      applyVelocity();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.


    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Slider(
                value: v,
                min: 0.001,
                max: 0.02,
                onChanged: (double value) {
                  setState(() {
                    v = value;
                  });
                },
              ),
                Slider(
                  value: alignmentParameter,
                  min: 0.0,
                  max: 0.1,
                  onChanged: (double value) {
                    setState(() {
                      alignmentParameter = value;
                    });
                  },
                ),
                /*FractionallySizedBox(
                  heightFactor: 0.1,
                  child: Slider(
                    value: v,
                    min: 0.01,
                    max: 0.1,
                    onChanged: (double value) {
                      setState(() {
                        v = value;
                      });
                    },
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: 0.1,
                  child: Slider(
                    value: alignmentParameter,
                    min: 0.0,
                    max: 0.1,
                    onChanged: (double value) {
                      setState(() {
                        alignmentParameter = value;
                      });
                    },
                  ),
                ),*/
              ],
            ),
            for(int i = 0; i<numElements; i++)
              Align(
                alignment: Alignment(elements[i].x, elements[i].y),
                child: FractionallySizedBox(
                  widthFactor: 0.1,
                  heightFactor: 0.1,
                  child: Transform.rotate(
                      angle: elements[i].rotation,
                    child: Icon(
                      Icons.arrow_right,
                      color: Colors.orange,
                      size: 50.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
    );
  }
}
