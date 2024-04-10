import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swarm_intelligence_2/swarm/bloc/swarm_event.dart';
import 'package:swarm_intelligence_2/swarm/bloc/swarm_state.dart';

import '../domain/fish.dart';

class SwarmBloc extends Bloc<SwarmEvent, SwarmState> {
  SwarmBloc() : super(SwarmState.initial()) {
    on<SwarmStep>(onStep);
  }

  onStep(_, emit) {
    // Do logic to update fish positions
    _alignWithNeighbours();
    _avoidNeighbours();
    _turnTowardNeighbours();
    _avoidWalls();
    _applyVelocity();

    emit(state);
  }

  get numFishes => state.numFishes;
  get fishes => state.fishes;
  get v => state.v;
  get alignmentParameter => state.alignmentParameter;
  get avoidanceParameter => state.avoidanceParameter;
  get attractionParameter => state.attractionParameter;

  void _avoidWalls() {
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

  List<_IndexAndDistance> _listNeighboursInRange(elementIndex, double range) {
    List<_IndexAndDistance> retval =
        List<_IndexAndDistance>.empty(growable: true);
    Fish thisElement = fishes[elementIndex];
    for (int i = 0; i < numFishes; i++) {
      if (i == elementIndex) continue;

      Fish otherElement = fishes[i];
      var distance = sqrt(pow(thisElement.x - otherElement.x, 2) +
          pow(thisElement.y - otherElement.y, 2));
      if (distance < range) {
        retval.add(_IndexAndDistance(i, distance < 0.001 ? 0.001 : distance));
      }
    }

    return retval;
  }

  void _alignWithNeighbours() {
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
      List<_IndexAndDistance> neighbours = _listNeighboursInRange(i, 30.0);
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

  void _avoidNeighbours() {
    for (int i = 0; i < numFishes; i++) {
      fishes[i] = fishes[i].copyWith(
        oldRx: cos(fishes[i].rotation),
        oldRy: sin(fishes[i].rotation),
      );
    }

    double sumX = 0.0;
    double sumY = 0.0;

    for (int i = 0; i < numFishes; i++) {
      List<_IndexAndDistance> neighbours = _listNeighboursInRange(i, 100.0);
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

  void _turnTowardNeighbours() {
    for (int i = 0; i < numFishes; i++) {
      fishes[i] = fishes[i].copyWith(
        oldRx: cos(fishes[i].rotation),
        oldRy: sin(fishes[i].rotation),
      );
    }

    double sumX = 0.0;
    double sumY = 0.0;

    for (int i = 0; i < numFishes; i++) {
      List<_IndexAndDistance> neighbours = _listNeighboursInRange(i, 400.0);
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

  void _applyVelocity() {
    for (int i = 0; i < numFishes; i++) {
      fishes[i] = fishes[i].copyWith(
        x: fishes[i].x + v * cos(fishes[i].rotation),
        y: fishes[i].y + v * sin(fishes[i].rotation),
      );
    }
  }
}

class _IndexAndDistance {
  _IndexAndDistance(this.index, this.distance);
  int index;
  double distance;
}
