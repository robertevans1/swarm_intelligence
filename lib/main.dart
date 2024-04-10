import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(SwarmIntelligence());
}

class SwarmIntelligence extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const FishSwarm(title: 'Swarm theory'),
    );
  }
}

class FishSwarm extends StatefulWidget {
  const FishSwarm({required this.title});
  final String title;

  @override
  FishSwarmState createState() => FishSwarmState();
}

class SwarmElementData {
  double x = 0.5;
  double y = 0.2;
  double rotation = pi / 2;
  double oldRx = 0.0;
  double oldRy = 0.0;
}

class IndexAndDistance {
  IndexAndDistance(this.index, this.distance);
  int index;
  double distance;
}

class FishSwarmState extends State<FishSwarm> {
  int attraction = 1;
  int repulsion = 1;
  int alignment = 1;
  double elementWidth = 0.2;
  int numElements = 20;
  double v = 0.01;
  double alignmentParameter = 0.0;
  double avoidanceParameter = 0.1;
  double attractionParameter = 0.01;

  final elements = List<SwarmElementData>.empty(growable: true);

  @override
  void initState() {
    for (int i = 0; i < numElements; ++i) {
      elements.add(SwarmElementData());
    }

    const duration = Duration(milliseconds: 10);
    Timer.periodic(duration, (Timer t) => updateSwarm());

    super.initState();
  }

  void avoidWalls() {
    for (int i = 0; i < numElements; i++) {
      elements[i].oldRx = cos(elements[i].rotation);
      elements[i].oldRy = sin(elements[i].rotation);
    }

    double B = 0.8;
    for (int i = 0; i < numElements; i++) {
      var X = elements[i].x;
      var Y = elements[i].y;
      //print("X $X Y $Y R $rot");
      double xPush = 0.0;
      double yPush = 0.0;
      if (X < -B) {
        xPush = X + B;
      } else if (X > B) {
        xPush = X - B;
      }
      if (Y < -B) {
        yPush = Y + B;
      } else if (Y > B) {
        yPush = Y - B;
      }

      elements[i].rotation =
          atan2(elements[i].oldRy - yPush, elements[i].oldRx - xPush);
    }
  }

  List<IndexAndDistance> listNeighboursInRange(elementIndex, double range) {
    List<IndexAndDistance> retval =
        List<IndexAndDistance>.empty(growable: true);
    SwarmElementData thisElement = elements[elementIndex];
    for (int i = 0; i < numElements; i++) {
      if (i == elementIndex) continue;

      SwarmElementData otherElement = elements[i];
      var distance = sqrt(pow(thisElement.x - otherElement.x, 2) +
          pow(thisElement.y - otherElement.y, 2));
      if (distance < range) {
        retval.add(IndexAndDistance(i, distance < 0.001 ? 0.001 : distance));
      }
    }

    return retval;
  }

  void alignWithNeighbours() {
    for (int i = 0; i < numElements; i++) {
      elements[i].oldRx = cos(elements[i].rotation);
      elements[i].oldRy = sin(elements[i].rotation);
    }

    if (alignmentParameter == 0.0) return;

    double sumX = 0.0;
    double sumY = 0.0;

    for (int i = 0; i < numElements; i++) {
      List<IndexAndDistance> neighbours = listNeighboursInRange(i, 30.0);
      for (int index = 0; index < neighbours.length; index++) {
        sumX += elements[neighbours[index].index].oldRx;
        sumY += elements[neighbours[index].index].oldRy;
      }

      if (sumX == 0.0 && sumY == 0.0) continue;

      double length = sqrt(pow(sumX, 2) + pow(sumY, 2));
      sumX /= length;
      sumY /= length;

      elements[i].rotation = atan2(
          elements[i].oldRy + sumY * alignmentParameter,
          elements[i].oldRx + sumX * alignmentParameter);
    }
  }

  void avoidNeighbours() {
    for (int i = 0; i < numElements; i++) {
      elements[i].oldRx = cos(elements[i].rotation);
      elements[i].oldRy = sin(elements[i].rotation);
    }

    double sumX = 0.0;
    double sumY = 0.0;

    for (int i = 0; i < numElements; i++) {
      List<IndexAndDistance> neighbours = listNeighboursInRange(i, 100.0);
      for (int index = 0; index < neighbours.length; index++) {
        double force = avoidanceParameter / pow(neighbours[index].distance, 2);

        sumX += force * (elements[i].x - elements[neighbours[index].index].x);
        sumY += force * (elements[i].y - elements[neighbours[index].index].y);
      }

      if (sumX == 0.0 && sumY == 0.0) continue;

      elements[i].rotation = atan2(
          elements[i].oldRy + sumY * alignmentParameter,
          elements[i].oldRx + sumX * alignmentParameter);
    }
  }

  void turnTowardNeighbours() {
    for (int i = 0; i < numElements; i++) {
      elements[i].oldRx = cos(elements[i].rotation);
      elements[i].oldRy = sin(elements[i].rotation);
    }

    double sumX = 0.0;
    double sumY = 0.0;

    for (int i = 0; i < numElements; i++) {
      List<IndexAndDistance> neighbours = listNeighboursInRange(i, 400.0);
      for (int index = 0; index < neighbours.length; index++) {
        sumX += elements[neighbours[index].index].x;
        sumY += elements[neighbours[index].index].y;
      }

      double avgX = sumX / neighbours.length;
      double avgY = sumY / neighbours.length;

      double directionX = avgX - elements[i].x;
      double directionY = avgY - elements[i].y;

      double length = sqrt(pow(directionX, 2) + pow(directionY, 2));
      if (directionY == 0 && directionX == 0) length = 10.0;

      elements[i].rotation = atan2(
          elements[i].oldRy + directionY * attractionParameter / length,
          elements[i].oldRx + directionX * attractionParameter / length);
    }
  }

  void applyVelocity() {
    for (int i = 0; i < numElements; i++) {
      elements[i].x += v * cos(elements[i].rotation);
      elements[i].y += v * sin(elements[i].rotation);
    }
  }

  void updateSwarm() {
    setState(() {
      alignWithNeighbours();
      avoidNeighbours();
      turnTowardNeighbours();
      avoidWalls();
      applyVelocity();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
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
                ],
              ),
              Row(
                children: [
                  Slider(
                    value: avoidanceParameter,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (double value) {
                      setState(() {
                        avoidanceParameter = value;
                      });
                    },
                  ),
                  Slider(
                    value: attractionParameter,
                    min: 0.0,
                    max: 0.1,
                    onChanged: (double value) {
                      setState(() {
                        attractionParameter = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          for (int i = 0; i < numElements; i++)
            Align(
              alignment: Alignment(elements[i].x, elements[i].y),
              child: FractionallySizedBox(
                widthFactor: 0.1,
                heightFactor: 0.1,
                child: Transform.rotate(
                  angle: elements[i].rotation,
                  child: const Icon(
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
