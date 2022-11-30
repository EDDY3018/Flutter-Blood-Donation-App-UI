import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class WaveIndicator extends StatelessWidget {
  const WaveIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: SpinKitWave(color: Color.fromARGB(1000, 221, 46, 68), type: SpinKitWaveType.start),
    ));
  }
}