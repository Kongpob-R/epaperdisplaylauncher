import 'package:epaperdisplaylauncher/epub_viewer.dart';
import 'package:epub_view/epub_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:io' as io;
// import 'package:path_provider/path_provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late String filePath;
  String rootDirectory = '/storage/emulated/0';
  List files = [];
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  void launchReader(String filePath) async {
    // final _result = await OpenFile.open('assets/books/bitcoin_standard.epub');
    // Directory? storageDir = await getExternalStorageDirectory()
    // filePath = storageDir!.path;
    // filePath = path.join(
    //   filePath!,
    //   'Books',
    //   'Cartoons on the War1248',
    // );
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            EpubViewer(filePath: filePath),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _listBooks(List<String> subDirectories) {
    for (var subDirectory in subDirectories) {
      final targetPath = io.Directory(path.join(
        rootDirectory,
        subDirectory,
      ));
      if (targetPath.existsSync()) {
        files += targetPath.listSync(
          recursive: true,
          followLinks: false,
        );
      }
    }
    setState(() {
      files = files
          .where((element) =>
              element.path.contains('.epub') || element.path.contains('.pdf'))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _listBooks(['Books', 'Books/MoonReader']);
  }

  @override
  void dispose() {
    super.dispose();
    files = [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ScrollablePositionedList.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: files.length,
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    launchReader(files[index].path);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1)),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(files[index].path),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
