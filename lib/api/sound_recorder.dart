import 'package:flutter_sound_lite/flutter_sound.dart';

final pathToSaveFile = "whistle.aac"

class SoundRecorder {
  FlutterSoundRecorder? _audioRecorder;

  Future _record() async {
    await _audioRecorder!.startRecorder(toFile: pathToSaveFile );
  }

  Future _stop() async {
    await _audioRecorder!.stopRecorder();
  }

}
