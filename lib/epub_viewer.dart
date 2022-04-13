import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'dart:io';

class EpubViewer extends StatefulWidget {
  final String filePath;
  const EpubViewer({Key? key, required this.filePath}) : super(key: key);

  @override
  State<EpubViewer> createState() => _EpubViewerState();
}

class _EpubViewerState extends State<EpubViewer> {
  late EpubController _epubReaderController;

  @override
  void initState() {
    _epubReaderController = EpubController(
      document: EpubDocument.openFile(
        File(widget.filePath),
      ),
      // epubCfi: '',
    );
    super.initState();
  }

  @override
  void dispose() {
    _epubReaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: EpubViewActualChapter(
          controller: _epubReaderController,
          builder: (chapterValue) => Text(
            chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
            textAlign: TextAlign.start,
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.turn_left),
              color: Colors.white,
              onPressed: () {
                _epubReaderController.jumpToPreviousPage();
                log('jump to previous page');
              }),
          IconButton(
              icon: const Icon(Icons.turn_right),
              color: Colors.white,
              onPressed: () {
                _epubReaderController.jumpToNextPage();
                log('jump to next page');
              }),
          IconButton(
            icon: const Icon(Icons.save_alt),
            color: Colors.white,
            onPressed: () => _showCurrentEpubCfi(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: EpubViewTableOfContents(controller: _epubReaderController),
      ),
      body: EpubView(
        controller: _epubReaderController,
        onDocumentError: (error) {
          log(error.toString());
        },
        onDocumentLoaded: (document) {
          log("ready");
        },
      ),
    );
  }

  void _showCurrentEpubCfi(context) {
    final cfi = _epubReaderController.generateEpubCfi();

    if (cfi != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cfi),
          action: SnackBarAction(
            label: 'GO',
            onPressed: () {
              _epubReaderController.gotoEpubCfi(cfi);
            },
          ),
        ),
      );
    }
  }
}
