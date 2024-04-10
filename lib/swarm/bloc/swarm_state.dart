import '../domain/fish.dart';

class SwarmState {
  final List<Fish> fishes;
  final int attraction;
  final int repulsion;
  final int alignment;
  final double elementWidth;
  final int numFishes;
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
    required this.numFishes,
    required this.v,
    required this.alignmentParameter,
    required this.avoidanceParameter,
    required this.attractionParameter,
  });

  SwarmState.initial()
      : fishes = List<Fish>.empty(growable: true),
        attraction = 1,
        repulsion = 1,
        alignment = 1,
        elementWidth = 0.2,
        numFishes = 20,
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
      numFishes: numFishes ?? this.numFishes,
      v: v ?? this.v,
      alignmentParameter: alignmentParameter ?? this.alignmentParameter,
      avoidanceParameter: avoidanceParameter ?? this.avoidanceParameter,
      attractionParameter: attractionParameter ?? this.attractionParameter,
    );
  }
}
