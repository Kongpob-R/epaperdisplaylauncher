import 'package:epaperdisplaylauncher/epub_viewer.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late String? filePath;

  void launchReader() async {
    // final _result = await OpenFile.open('assets/books/bitcoin_standard.epub');
    // Directory? storageDir = await getExternalStorageDirectory()
    // filePath = storageDir!.path;
    // filePath = path.join(
    //   filePath!,
    //   'Books',
    //   'Cartoons on the War1248',
    // );
    filePath = path.join(
      '/storage/emulated/0',
      'Books',
      'Cartoons on the War1248.epub',
    );
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            EpubViewer(filePath: filePath!),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(50),
      child: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: launchReader,
            child: const Text('launchReader'),
          ),
        ],
      ),
    );
  }
}
