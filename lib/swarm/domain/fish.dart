import 'dart:math';

import 'package:equatable/equatable.dart';

class Fish extends Equatable {
  final double x;
  final double y;
  final double rotation;
  final double oldRx;
  final double oldRy;

  const Fish({
    required this.x,
    required this.y,
    required this.rotation,
    required this.oldRx,
    required this.oldRy,
  });

  const Fish.initial()
      : this(x: 0.5, y: 0.2, rotation: pi / 2, oldRx: 0.0, oldRy: 0.0);

  Fish copyWith({
    double? x,
    double? y,
    double? rotation,
    double? oldRx,
    double? oldRy,
  }) {
    return Fish(
      x: x ?? this.x,
      y: y ?? this.y,
      rotation: rotation ?? this.rotation,
      oldRx: oldRx ?? this.oldRx,
      oldRy: oldRy ?? this.oldRy,
    );
  }

  @override
  List<Object?> get props => [x, y, rotation, oldRx, oldRy];
}
