import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../swarm/domain/fish.dart';

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
  int numFishes = 20;
  double v = 0.01;
  double alignmentParameter = 0.0;
  double avoidanceParameter = 0.1;
  double attractionParameter = 0.01;

  final fishes = List<Fish>.empty(growable: true);

  @override
  void initState() {
    for (int i = 0; i < numFishes; ++i) {
      fishes.add(const Fish.initial());
    }

    const duration = Duration(milliseconds: 10);
    Timer.periodic(duration, (Timer t) => updateSwarm());

    super.initState();
  }

  void avoidWalls() {
    for (int i = 0; i < numFishes; i++) {
      fishes[i] = fishes[i].copyWith(
        oldRx: cos(fishes[i].rotation),
        oldRy: sin(fishes[i].rotation),
      );
    }

    double B = 0.8;
    for (int i = 0; i < numFishes; i++) {
      var X = fishes[i].x;
      var Y = fishes[i].y;
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

      fishes[i] = fishes[i].copyWith(
        rotation: atan2(fishes[i].oldRy - yPush, fishes[i].oldRx - xPush),
      );
    }
  }

  List<IndexAndDistance> listNeighboursInRange(elementIndex, double range) {
    List<IndexAndDistance> retval =
        List<IndexAndDistance>.empty(growable: true);
    Fish thisElement = fishes[elementIndex];
    for (int i = 0; i < numFishes; i++) {
      if (i == elementIndex) continue;

      Fish otherElement = fishes[i];
      var distance = sqrt(pow(thisElement.x - otherElement.x, 2) +
          pow(thisElement.y - otherElement.y, 2));
      if (distance < range) {
        retval.add(IndexAndDistance(i, distance < 0.001 ? 0.001 : distance));
      }
    }

    return retval;
  }

  void alignWithNeighbours() {
    for (int i = 0; i < numFishes; i++) {
      fishes[i] = fishes[i].copyWith(
        oldRx: cos(fishes[i].rotation),
        oldRy: sin(fishes[i].rotation),
      );
    }

    if (alignmentParameter == 0.0) return;

    double sumX = 0.0;
    double sumY = 0.0;

    for (int i = 0; i < numFishes; i++) {
      List<IndexAndDistance> neighbours = listNeighboursInRange(i, 30.0);
      for (int index = 0; index < neighbours.length; index++) {
        sumX += fishes[neighbours[index].index].oldRx;
        sumY += fishes[neighbours[index].index].oldRy;
      }

      if (sumX == 0.0 && sumY == 0.0) continue;

      double length = sqrt(pow(sumX, 2) + pow(sumY, 2));
      sumX /= length;
      sumY /= length;

      fishes[i] = fishes[i].copyWith(
        rotation: atan2(fishes[i].oldRy + sumY * alignmentParameter,
            fishes[i].oldRx + sumX * alignmentParameter),
      );
    }
  }

  void avoidNeighbours() {
    for (int i = 0; i < numFishes; i++) {
      fishes[i] = fishes[i].copyWith(
        oldRx: cos(fishes[i].rotation),
        oldRy: sin(fishes[i].rotation),
      );
    }

    double sumX = 0.0;
    double sumY = 0.0;

    for (int i = 0; i < numFishes; i++) {
      List<IndexAndDistance> neighbours = listNeighboursInRange(i, 100.0);
      for (int index = 0; index < neighbours.length; index++) {
        double force = avoidanceParameter / pow(neighbours[index].distance, 2);

        sumX += force * (fishes[i].x - fishes[neighbours[index].index].x);
        sumY += force * (fishes[i].y - fishes[neighbours[index].index].y);
      }

      if (sumX == 0.0 && sumY == 0.0) continue;

      fishes[i] = fishes[i].copyWith(
        rotation: atan2(fishes[i].oldRy + sumY, fishes[i].oldRx + sumX),
      );
    }
  }

  void turnTowardNeighbours() {
    for (int i = 0; i < numFishes; i++) {
      fishes[i] = fishes[i].copyWith(
        oldRx: cos(fishes[i].rotation),
        oldRy: sin(fishes[i].rotation),
      );
    }

    double sumX = 0.0;
    double sumY = 0.0;

    for (int i = 0; i < numFishes; i++) {
      List<IndexAndDistance> neighbours = listNeighboursInRange(i, 400.0);
      for (int index = 0; index < neighbours.length; index++) {
        sumX += fishes[neighbours[index].index].x;
        sumY += fishes[neighbours[index].index].y;
      }

      double avgX = sumX / neighbours.length;
      double avgY = sumY / neighbours.length;

      double directionX = avgX - fishes[i].x;
      double directionY = avgY - fishes[i].y;

      double length = sqrt(pow(directionX, 2) + pow(directionY, 2));
      if (directionY == 0 && directionX == 0) length = 10.0;

      fishes[i] = fishes[i].copyWith(
        rotation: atan2(
            fishes[i].oldRy + directionY * attractionParameter / length,
            fishes[i].oldRx + directionX * attractionParameter / length),
      );
    }
  }

  void applyVelocity() {
    for (int i = 0; i < numFishes; i++) {
      fishes[i] = fishes[i].copyWith(
        x: fishes[i].x + v * cos(fishes[i].rotation),
        y: fishes[i].y + v * sin(fishes[i].rotation),
      );
    }
  }

  void updateSwarm() {
    avoidWalls();
    avoidNeighbours();
    alignWithNeighbours();
    turnTowardNeighbours();
    applyVelocity();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          for (int i = 0; i < numFishes; i++)
            Align(
              alignment: Alignment(fishes[i].x, fishes[i].y),
              child: FractionallySizedBox(
                widthFactor: 0.1,
                heightFactor: 0.1,
                child: Transform.rotate(
                  angle: fishes[i].rotation,
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
