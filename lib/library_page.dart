import 'dart:developer';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:epaperdisplaylauncher/epub_viewer.dart';
import 'package:epub_view/epub_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/image.dart' as widgetImage;
import 'package:epubx/epubx.dart' as epub;
import 'package:image/image.dart' as image;
import 'package:path/path.dart' as path;
import 'dart:io' as io;
// import 'package:path_provider/path_provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late bool isLoading;
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

  Future _listBooks(List<String> subDirectories) async {
    setState(() {
      isLoading = true;
    });
    List bookPaths = [];
    List bookRefs = [];
    for (var subDirectory in subDirectories) {
      final targetPath = io.Directory(path.join(
        rootDirectory,
        subDirectory,
      ));
      if (targetPath.existsSync()) {
        bookPaths += targetPath.listSync(
          recursive: false,
          followLinks: false,
        );
      }
    }
    bookPaths = bookPaths
        .where((element) =>
            element.path.contains('.epub') || element.path.contains('.pdf'))
        .toList();
    for (var e in bookPaths) {
      final EpubBookRef epubBookRef = await EpubReader.openBook(
        io.File(e.path).readAsBytes(),
      );
      bookRefs.add({
        'ref': epubBookRef,
        'path': e.path.toString(),
      });
    }
    setState(() {
      files = bookRefs;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _listBooks(['Books']);
  }

  @override
  void dispose() {
    super.dispose();
    files = [];
  }

  Widget buildEpubWidget(epub.EpubBookRef book) {
    var cover = book.readCover();
    return Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Title",
                  ),
                  Text(
                    book.Title!,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 15.0),
                  ),
                  const Text(
                    "Author",
                  ),
                  Text(
                    book.Author!,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 15.0),
                  ),
                ],
              ),
            ),
            FutureBuilder<epub.Image?>(
              future: cover,
              builder: (context, AsyncSnapshot<epub.Image?> snapshot) {
                if (snapshot.hasData) {
                  return widgetImage.Image.memory(
                    Uint8List.fromList(
                      image.encodePng(
                        snapshot.data!,
                      ),
                    ),
                    width: 120,
                    height: 120,
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return Container(
                  width: 100,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Center(
                        child: Text(
                          book.Title!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                );
              },
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
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
                    launchReader(files[index]['path']);
                  },
                  child: isLoading
                      ? Container()
                      : Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(width: 1)),
                          ),
                          child: buildEpubWidget(
                            files[index]['ref'],
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
