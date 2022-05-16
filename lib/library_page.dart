import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:epaperdisplaylauncher/loading_indicator.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/image.dart' as widgetImage;
import 'package:epubx/epubx.dart' as epub;
import 'package:image/image.dart' as image;
import 'package:path/path.dart' as path;
import 'dart:io' as io;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
// import 'package:path_provider/path_provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late bool isLoading;
  late StreamSubscription<List> _listBooksProcess;
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
    // Navigator.push(
    //   context,
    //   PageRouteBuilder(
    //     pageBuilder: (context, animation1, animation2) =>
    //         EpubViewer(filePath: filePath),
    //     transitionDuration: Duration.zero,
    //     reverseTransitionDuration: Duration.zero,
    //   ),
    // );
    AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      data: Uri.file(filePath, windows: false).toString(),
      type: 'application/pdf',
    );
    await intent.launch();
  }

  Future<List> _listBooks(List<String> subDirectories) async {
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
    for (var book in bookPaths) {
      log(book.path);
      if (book.path.contains('.epub')) {
        final epub.EpubBookRef epubBookRef = await epub.EpubReader.openBook(
          io.File(book.path).readAsBytes(),
        );
        bookRefs.add({
          'type': 'epub',
          'ref': epubBookRef,
          'path': book.path.toString(),
        });
      } else if (book.path.contains('.pdf')) {
        bookRefs.add({
          'type': 'pdf',
          'doc': '',
          'path': book.path.toString(),
        });
      }
    }
    return bookRefs;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    _listBooksProcess = _listBooks(['Books']).asStream().listen((data) {
      setState(() {
        files = data;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _listBooksProcess.cancel();
    super.dispose();
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

  Widget buildPdfWidget(cover, String path) {
    String fileName = path.split('/').last.split('.').first;
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
                    fileName,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 15.0),
                  ),
                  const Text(
                    "Author",
                  ),
                  const Text(
                    'Unknow',
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 15.0),
                  ),
                ],
              ),
            ),
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(width: 1),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Center(
                    child: Text(
                      fileName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 100,
        height: 60,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              Text('Loading'),
              LoadingIndicator(),
            ],
          ),
        ),
      );
    } else {
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
                            child: files[index]['type'] == 'epub'
                                ? buildEpubWidget(
                                    files[index]['ref'],
                                  )
                                : buildPdfWidget(
                                    files[index]['doc'],
                                    files[index]['path'],
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
}
