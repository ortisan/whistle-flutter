import 'package:flutter/material.dart';
import 'package:whistle/api/sound_recorder.dart';

void main() => runApp(MainPage());

class MainPage extends StatefulWidget {
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final recorder = SoundRecorder();

  @override
  void initState() {
    super.initState();
    recorder.init();
  }

  @override
  void dispose() {
    recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: Text("Whistle App")),
            body: Center(child: buildStart())));
  }

  Widget buildStart() {
    final isRecording = recorder.isRecording;
    final icon = isRecording ? Icons.stop : Icons.mic;
    final text = isRecording ? "Stop" : "Start";
    final primary = isRecording ? Colors.red : Colors.white;
    final onPrimary = isRecording ? Colors.white : Colors.black;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          minimumSize: Size(175, 50), primary: primary, onPrimary: onPrimary),
      icon: Icon(icon),
      label: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        await recorder.toggleRecording();
        setState(() {});
      },
    );
  }
}
