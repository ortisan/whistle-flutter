import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:whistle/api/fft_processor.dart';
import 'package:whistle/api/play_recorder.dart';
import 'package:whistle/api/sound_recorder.dart';

void main() => runApp(MainPage());

class MainPage extends StatefulWidget {
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final recorder = SoundRecorder();
  final player = PlayRecorder();

  // Defining the data

  _getSeriesData(final List<SpectrogramData> data) {
    List<charts.Series<SpectrogramData, String>> series = [
      charts.Series(
          id: "Population",
          data: data,
          domainFn: (SpectrogramData series, _) => series.freq.toString(),
          measureFn: (SpectrogramData series, _) => series.magnitude,
          colorFn: (SpectrogramData series, _) => series.barColor)
    ];
    return series;
  }

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
            body: Center(
                child: Column(
              children: [
                buildStart(),
                buildPlay(),
                buildSpectrogram()
              ],
            ))));
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

  Widget buildPlay() {
    final isPlaying = player.isPlaying;
    final icon = isPlaying ? Icons.pause : Icons.play_arrow;
    final text = isPlaying ? "Pause" : "Play";
    final primary = isPlaying ? Colors.red : Colors.white;
    final onPrimary = isPlaying ? Colors.white : Colors.black;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          minimumSize: Size(175, 50), primary: primary, onPrimary: onPrimary),
      icon: Icon(icon),
      label: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        await player.togglePlaying();
        setState(() {});
      },
    );
  }

  Widget buildSpectrogram() {
    return FutureBuilder<List<SpectrogramData>>(
        future: getSpectrogram(),
        builder: (context, AsyncSnapshot<List<SpectrogramData>> snapshot) {
          if (snapshot.hasData) {
            return Container(
                height: 400,
                padding: EdgeInsets.all(20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        const Text(
                          "Spectrogram",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Expanded(
                          child: charts.BarChart(
                            _getSeriesData(snapshot.requireData),
                            animate: true,
                            domainAxis: const charts.OrdinalAxisSpec(
                                renderSpec: charts.SmallTickRendererSpec(
                                    labelRotation: 90)),
                          ),
                        )
                      ],
                    ),
                  ),
                ));
          } else {
            return Text("Processando...");
          }
        });
  }
}
