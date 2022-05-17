import 'dart:io' as io;
import 'dart:developer';
import 'package:path/path.dart' as path;

List resetToDefault(List<dynamic> preDownloadList) {
  const String rootDirectory = '/storage/emulated/0';
  const List<String> subDirectories = ['Books'];
  List localFileList = [];
  List<String> localFileNameList = [];
  List<String> preDownloadFileNameList = [];
  late List urlToDownloadList;
  for (var subDirectory in subDirectories) {
    final targetPath = io.Directory(path.join(
      rootDirectory,
      subDirectory,
    ));
    if (targetPath.existsSync()) {
      localFileList += targetPath.listSync(
        recursive: false,
        followLinks: false,
      );
    }
  }
  for (var file in localFileList) {
    if (file.path.contains('.pdf') ||
        file.path.contains('.epub') ||
        file.path.contains('.php')) {
      localFileNameList.add(file.path.split('/').last);
    }
  }
  log('local: ' + localFileNameList.toString());

  for (var book in preDownloadList) {
    preDownloadFileNameList.add(book['content'].toString().split('/').last);
  }
  log('preDownload: ' + preDownloadFileNameList.toString());

  localFileNameList
      .removeWhere((fileName) => preDownloadFileNameList.contains(fileName));
  log('files to remove: ' + localFileNameList.toString());

  preDownloadFileNameList
      .removeWhere((fileName) => localFileNameList.contains(fileName));
  log('files to download: ' + preDownloadFileNameList.toString());

  for (var file in localFileList) {
    if (localFileNameList.any((fileName) => file.path.contains(fileName))) {
      deleteFile(io.File(file.path));
      log('removed: ' + file.path);
    }
  }

  urlToDownloadList = [];
  for (var book in preDownloadList) {
    if (preDownloadFileNameList
        .any((fileName) => book['content'].toString().contains(fileName))) {
      urlToDownloadList.add(book['content'].toString());
    }
  }
  return urlToDownloadList;
}

Future<void> deleteFile(io.File file) async {
  try {
    if (await file.exists()) {
      await file.delete();
    }
  } catch (e) {
    log('removing error: ' + e.toString());
    // Error in getting access to the file.
  }
}
