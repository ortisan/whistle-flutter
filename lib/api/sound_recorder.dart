import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whistle/api/utils.dart';

class SoundRecorder {

  FlutterSoundRecorder? _audioRecorder;

  bool get isRecording => _audioRecorder!.isRecording;

  Future init() async {
    _audioRecorder = FlutterSoundRecorder();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Microphone permission required");
    }
    await _audioRecorder!.openAudioSession();
  }

  Future dispose() async {
    await _audioRecorder!.closeAudioSession();
    _audioRecorder = null;
  }

  Future _record() async {
    final audioFile = await getAudioFile();
    await _audioRecorder!.startRecorder(toFile: audioFile);
  }

  Future _stop() async {
    await _audioRecorder!.stopRecorder();
  }

  Future toggleRecording() async {
    if (_audioRecorder!.isStopped) {
      await _record();
    } else {
      await _stop();
    }
  }
}
