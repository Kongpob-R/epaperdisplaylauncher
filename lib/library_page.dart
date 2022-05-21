import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:epaperdisplaylauncher/loading_indicator.dart';
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
  final String newBook;
  const LibraryPage({Key? key, required this.newBook}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late bool isLoading;
  late StreamSubscription<List> _listBooksProcess;
  late String filePath;
  String rootDirectory = '/storage/emulated/0';
  List files = [];
  final ScrollController scrollController = ScrollController();
  List pageFiles = [];

  void launchReader(String filePath) async {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
                    height: 160,
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return PlaceHolderCover(book.Title!);
              },
            ),
            Text(
              book.Title!,
              textScaleFactor: 1,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ],
        ));
  }

  Widget buildPdfWidget(cover, String path) {
    String fileName = path.split('/').last.split('.').first;
    String isbn = path.split('/').last.split('.')[1];
    return Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            isbn.isNotEmpty
                ? Image.network(
                    'http://syndetics.com/index.aspx/?isbn=$isbn/LC.gif&client=iiit&type=hw7',
                    height: 160,
                    loadingBuilder: (context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      return PlaceHolderCover(fileName);
                    },
                    errorBuilder: (context, error, StackTrace? stackTrace) {
                      return PlaceHolderCover(fileName);
                    },
                  )
                : PlaceHolderCover(fileName),
            Text(
              fileName,
              textScaleFactor: 1,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: GridView.count(
              controller: scrollController,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 100 / 170,
              children: List.generate(files.length, (index) {
                return GestureDetector(
                  onTap: () {
                    launchReader(files[index]['path']);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
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
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Total book(s) ' + files.length.toString()),
          )
        ],
      );
    }
  }

  Widget PlaceHolderCover(String displayText) {
    return Container(
      width: 100,
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Center(
          child: Text(
            displayText,
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
          ),
        ),
      ),
    );
  }
}
