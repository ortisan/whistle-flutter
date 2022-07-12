import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:fftea/stft.dart';
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

Future<String> getSpectrogram() async {
  final audioFile = await getAudioFile();
  final exists = await File(audioFile).exists();
  if (!exists) {
    return "Audio não encontrado...";
  }

  final wav = await Wav.readFile(audioFile);
  final audio = _normalizeRmsVolume(wav.toMono(), 0.3);
  const chunkSize = 2048;
  const buckets = 120;
  final stft = STFT(chunkSize, Window.hanning(chunkSize));
  Uint64List? logItr;
  final StringBuffer sb = StringBuffer();
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
        sb.write(_gradient(power));
        i0 = i1;
      }
      sb.write('\n');
    },
    chunkSize ~/ 2,
  );

  // final spectrogram = <Float64List>[];
  // stft.run(audio, (Float64x2List freq) {
  //   spectrogram.add(freq.discardConjugates().magnitudes());
  // });

  return sb.toString();
}
