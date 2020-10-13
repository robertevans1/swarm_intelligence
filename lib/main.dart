import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

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
  double v = 0.05;
}

class _FishSwarmState extends State<FishSwarm> {
  int attraction = 1;
  int repulsion = 1;
  int alignment = 1;
  double elementWidth = 0.2;

  List<SwarmElementData> elements = new List();

  @override
  void initState() {

    for(int i = 0; i < 10; ++i){
      elements.add(SwarmElementData());
    }

    const duration = const Duration(milliseconds:10);
    new Timer.periodic(duration, (Timer t) => updateSwarm());

    super.initState();
  }

  void updateSwarm()
  {
    setState(() {
      double B = 0.9;
    var X = elements[0].x;
      var Y = elements[0].y;
      var V = elements[0].v;
      var rot = elements[0].rotation;
      print("X $X Y $Y R $rot");
      var rng = new Random();
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

      elements[0].rotation = rot;
      elements[0].x += V * cos(rot);
      elements[0].y += V * sin(rot);

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
      body: Center(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment(elements[0].x, elements[0].y),
              child: FractionallySizedBox(
                widthFactor: 0.05,
                heightFactor: 0.05,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
