import 'package:equatable/equatable.dart';

import '../domain/fish.dart';

class SwarmState extends Equatable {
  final List<Fish> fishes;
  final int attraction;
  final int repulsion;
  final int alignment;
  final double elementWidth;
  final double v;
  final double alignmentParameter;
  final double avoidanceParameter;
  final double attractionParameter;

  const SwarmState({
    required this.fishes,
    required this.attraction,
    required this.repulsion,
    required this.alignment,
    required this.elementWidth,
    required this.v,
    required this.alignmentParameter,
    required this.avoidanceParameter,
    required this.attractionParameter,
  });

  SwarmState.initial()
      : fishes = List<Fish>.generate(20, (_) => const Fish.initial(),
            growable: false),
        attraction = 1,
        repulsion = 1,
        alignment = 1,
        elementWidth = 0.2,
        v = 0.01,
        alignmentParameter = 0.0,
        avoidanceParameter = 0.1,
        attractionParameter = 0.01;

  SwarmState copyWith({
    List<Fish>? fishes,
    int? attraction,
    int? repulsion,
    int? alignment,
    double? elementWidth,
    int? numFishes,
    double? v,
    double? alignmentParameter,
    double? avoidanceParameter,
    double? attractionParameter,
  }) {
    return SwarmState(
      fishes: fishes ?? this.fishes,
      attraction: attraction ?? this.attraction,
      repulsion: repulsion ?? this.repulsion,
      alignment: alignment ?? this.alignment,
      elementWidth: elementWidth ?? this.elementWidth,
      v: v ?? this.v,
      alignmentParameter: alignmentParameter ?? this.alignmentParameter,
      avoidanceParameter: avoidanceParameter ?? this.avoidanceParameter,
      attractionParameter: attractionParameter ?? this.attractionParameter,
    );
  }

  @override
  List<Object?> get props => [
        fishes,
        attraction,
        repulsion,
        alignment,
        elementWidth,
        v,
        alignmentParameter,
        avoidanceParameter,
        attractionParameter,
      ];
}
