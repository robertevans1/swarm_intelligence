import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swarm_intelligence/swarm/bloc/swarm_event.dart';
import 'package:swarm_intelligence/swarm/bloc/swarm_state.dart';

import '../domain/fish.dart';

class SwarmBloc extends Bloc<SwarmEvent, SwarmState> {
  SwarmBloc() : super(SwarmState.initial()) {
    on<SwarmStep>(_onStep);
    on<SwarmUpdateParameters>(_onUpdateParameters);

    // Start the swarm
    Timer.periodic(const Duration(milliseconds: 10), (_) => add(SwarmStep()));
  }

  _onStep(_, emit) {
    final stopwatch = Stopwatch()..start();
    // Do logic to update fish positions
    final fishes = List<Fish>.from(state.fishes);

    _alignWithNeighbours(fishes);
    _avoidNeighbours(fishes);
    _turnTowardNeighbours(fishes);
    _avoidWalls(fishes);
    _applyVelocity(fishes);

    emit(state.copyWith(fishes: fishes));
  }

  _onUpdateParameters(event, emit) {
    emit(state.copyWith(
      v: event.v ?? state.v,
      alignmentParameter: event.alignmentParameter ?? state.alignmentParameter,
      avoidanceParameter: event.avoidanceParameter ?? state.avoidanceParameter,
      attractionParameter:
          event.attractionParameter ?? state.attractionParameter,
    ));
  }

  get numFishes => state.fishes.length;
  get v => state.v;
  get alignmentParameter => state.alignmentParameter;
  get avoidanceParameter => state.avoidanceParameter;
  get attractionParameter => state.attractionParameter;

  void _avoidWalls(List<Fish> fishes) {
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

  List<_IndexAndDistance> _listNeighboursInRange(
      elementIndex, double range, List<Fish> fishes) {
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

  void _alignWithNeighbours(List<Fish> fishes) {
    if (alignmentParameter == 0.0) return;

    for (int i = 0; i < numFishes; i++) {
      fishes[i] = fishes[i].copyWith(
        oldRx: cos(fishes[i].rotation),
        oldRy: sin(fishes[i].rotation),
      );
    }

    double sumX = 0.0;
    double sumY = 0.0;

    for (int i = 0; i < numFishes; i++) {
      List<_IndexAndDistance> neighbours =
          _listNeighboursInRange(i, 30.0, fishes);
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

  void _avoidNeighbours(List<Fish> fishes) {
    for (int i = 0; i < numFishes; i++) {
      fishes[i] = fishes[i].copyWith(
        oldRx: cos(fishes[i].rotation),
        oldRy: sin(fishes[i].rotation),
      );
    }

    double sumX = 0.0;
    double sumY = 0.0;

    for (int i = 0; i < numFishes; i++) {
      List<_IndexAndDistance> neighbours =
          _listNeighboursInRange(i, 100.0, fishes);
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

  void _turnTowardNeighbours(List<Fish> fishes) {
    for (int i = 0; i < numFishes; i++) {
      fishes[i] = fishes[i].copyWith(
        oldRx: cos(fishes[i].rotation),
        oldRy: sin(fishes[i].rotation),
      );
    }

    double sumX = 0.0;
    double sumY = 0.0;

    for (int i = 0; i < numFishes; i++) {
      List<_IndexAndDistance> neighbours =
          _listNeighboursInRange(i, 400.0, fishes);
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

  void _applyVelocity(List<Fish> fishes) {
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
