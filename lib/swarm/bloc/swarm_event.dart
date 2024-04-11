sealed class SwarmEvent {}

class SwarmStep extends SwarmEvent {}

class SwarmUpdateParameters extends SwarmEvent {
  final double? v;
  final double? alignmentParameter;
  final double? avoidanceParameter;
  final double? attractionParameter;

  SwarmUpdateParameters({
    this.v,
    this.alignmentParameter,
    this.avoidanceParameter,
    this.attractionParameter,
  });
}
