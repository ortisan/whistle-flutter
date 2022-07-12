import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:fftea/fftea.dart';
import 'package:fftea/stft.dart';
import 'package:flutter/material.dart';
import 'package:wav/wav.dart';
import 'package:whistle/api/utils.dart';

Float64List _normalizeRmsVolume(List<double> a, double target) {
  final b = Float64List.fromList(a);
  double squareSum = 0;
  for (final x in b) {
    squareSum += x * x;
  }
  double factor = target * math.sqrt(b.length / squareSum);
  for (int i = 0; i < b.length; ++i) {
    b[i] *= factor;
  }
  return b;
}

Uint64List _linSpace(int end, int steps) {
  final a = Uint64List(steps);
  for (int i = 1; i < steps; ++i) {
    a[i - 1] = (end * i) ~/ steps;
  }
  a[steps - 1] = end;
  return a;
}

String _gradient(double power) {
  const scale = 2;
  const levels = [' ', '░', '▒', '▓', '█'];
  int index = math.log((power * levels.length) * scale).floor();
  if (index < 0) index = 0;
  if (index >= levels.length) index = levels.length - 1;
  return levels[index];
}

Future<List<SpectrogramData>> getSpectrogram() async {
  final audioFile = await getAudioFile();
  final exists = await File(audioFile).exists();
  if (!exists) {
    return <SpectrogramData>[];
  }

  final wav = await Wav.readFile(audioFile);
  final audio = _normalizeRmsVolume(wav.toMono(), 0.3);
  const chunkSize = 2048;
  const buckets = 120;
  final stft = STFT(chunkSize, Window.hanning(chunkSize));
  Uint64List? logItr;
  final spec = <SpectrogramData>[];
  var x= 0;
  stft.run(
    audio,
    (Float64x2List chunk) {

      final amp = chunk.discardConjugates().magnitudes();
      logItr ??= _linSpace(amp.length, buckets);
      int i0 = 0;
      for (final i1 in logItr!) {
        double power = 0;
        if (i1 != i0) {
          for (int i = i0; i < i1; ++i) {
            power += amp[i];
          }
          power /= i1 - i0;
        }

        final spectrogramData = SpectrogramData(
            freq: i1,
            magnitude: power,
            barColor: charts.ColorUtil.fromDartColor(Colors.lightBlue));

        x++;
        if (x <= 10) {
          spec.add(spectrogramData);
        }


        i0 = i1;
      }

    },
    chunkSize ~/ 2,
  );

  return spec;
}

class SpectrogramData {
  int freq;
  double magnitude;
  charts.Color barColor;

  SpectrogramData(
      {required this.freq, required this.magnitude, required this.barColor});
}
