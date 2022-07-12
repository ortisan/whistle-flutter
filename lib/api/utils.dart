import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> getAudioFile() async {
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
  String appDocumentsPath = appDocumentsDirectory.path;
  String filePath = '$appDocumentsPath/whistle.aac';
  return filePath;
}
