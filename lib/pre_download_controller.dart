import 'dart:io' as io;
import 'dart:developer';
import 'package:path/path.dart' as path;

List resetToDefault(List<dynamic> preDownloadList) {
  const String rootDirectory = '/storage/emulated/0';
  const List<String> subDirectories = ['Books'];
  List localFileList = [];
  List<String> localFileNameList = [];
  List<String> temp = [];
  List<String> preDownloadFileNameList = [];
  List<String> fileNameToDownload = [];
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
    preDownloadFileNameList.add(book['title'] +
        '.' +
        (book['isbn'] ?? '') +
        '.' +
        book['url'].split('.').last);
  }
  log('preDownload: ' + preDownloadFileNameList.toString());

  temp = localFileNameList;
  localFileNameList
      .removeWhere((fileName) => preDownloadFileNameList.contains(fileName));
  log('files to remove: ' + localFileNameList.toString());

  for (var element in preDownloadFileNameList) {
    if (!temp.contains(element)) {
      fileNameToDownload.add(element);
    }
  }
  log('files to download: ' + fileNameToDownload.toString());

  for (var file in localFileList) {
    if (temp.any((fileName) => file.path.contains(fileName))) {
      deleteFile(io.File(file.path));
      log('removed: ' + file.path);
    }
  }

  urlToDownloadList = [];
  for (var book in preDownloadList) {
    if (fileNameToDownload.contains(book['title'])) {
      urlToDownloadList.add({
        'title': book['title'],
        'url': book['url'],
        'isbn': book['isbn'],
      });
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
