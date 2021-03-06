import 'package:audioplayers/audioplayers.dart';
import 'package:whistle/api/utils.dart';

class PlayRecorder {
  final _player = AudioPlayer();
  bool isPlaying = false;

  Future _play() async {
    final audioFile = await getAudioFile();
    await _player.play(DeviceFileSource(audioFile));
    isPlaying = true;
  }

  Future _pause() async {
    await _player.pause();
    isPlaying = false;
  }

  Future _stop() async {
    await _player.stop();
    isPlaying = false;
  }

  Future togglePlaying() async {
    if (!isPlaying) {
      await _play();
    } else {
      await _pause();
    }
  }
}
