import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swarm_intelligence/swarm/bloc/swarm_bloc.dart';
import 'package:swarm_intelligence/swarm/bloc/swarm_event.dart';
import 'package:swarm_intelligence/swarm/bloc/swarm_state.dart';

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
      home: BlocProvider(
        create: (context) => SwarmBloc(),
        child: Builder(builder: (context) {
          return const FishSwarm(title: 'Swarm theory');
        }),
      ),
    );
  }
}

class FishSwarm extends StatelessWidget {
  final String title;

  const FishSwarm({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BlocBuilder<SwarmBloc, SwarmState>(builder: (context, state) {
        return Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Slider(
                      value: state.v,
                      min: 0.001,
                      max: 0.02,
                      onChanged: (v) => context
                          .read<SwarmBloc>()
                          .add(SwarmUpdateParameters(v: v)),
                    ),
                    Slider(
                      value: state.alignmentParameter,
                      min: 0.0,
                      max: 0.1,
                      onChanged: (alignmentParameter) => context
                          .read<SwarmBloc>()
                          .add(SwarmUpdateParameters(
                              alignmentParameter: alignmentParameter)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Slider(
                      value: state.avoidanceParameter,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (avoidanceParameter) => context
                          .read<SwarmBloc>()
                          .add(SwarmUpdateParameters(
                              avoidanceParameter: avoidanceParameter)),
                    ),
                    Slider(
                      value: state.attractionParameter,
                      min: 0.0,
                      max: 0.1,
                      onChanged: (attractionParameter) => context
                          .read<SwarmBloc>()
                          .add(SwarmUpdateParameters(
                              attractionParameter: attractionParameter)),
                    ),
                  ],
                ),
              ],
            ),
            for (int i = 0; i < state.fishes.length; i++)
              Align(
                alignment: Alignment(state.fishes[i].x, state.fishes[i].y),
                child: FractionallySizedBox(
                  widthFactor: 0.1,
                  heightFactor: 0.1,
                  child: Transform.rotate(
                    angle: state.fishes[i].rotation,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: const Image.asset('images/fish.png'),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
