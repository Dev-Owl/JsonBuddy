import 'package:flutter/material.dart';
import 'package:json_buddy/helper/global.dart';
import 'package:provider/provider.dart';

import 'document.dart';
import 'highlighter.dart';
import 'package:scrollable_positioned_list/src/scrollable_positioned_list.dart';

class DocumentProvider extends ChangeNotifier {
  Document doc = Document();

  Future<bool> openFile(String path) async {
    bool res = await doc.openFile(path);
    touch();
    return res;
  }

  void touch() {
    notifyListeners();
  }
}

class ViewLine extends StatelessWidget {
  const ViewLine({this.lineNumber = 0, this.text = ''});

  final int lineNumber;
  final String text;

  @override
  Widget build(BuildContext context) {
    DocumentProvider doc = Provider.of<DocumentProvider>(context);
    Highlighter hl = Provider.of<Highlighter>(context);
    List<InlineSpan> spans = hl.run(text, lineNumber, doc.doc);

    final gutterStyle = TextStyle(
        fontFamily: defaultFontFamily,
        fontSize: gutterFontSize,
        color: comment);
    double gutterWidth =
        getTextExtents(' ${doc.doc.lines.length} ', gutterStyle).width;

    return Stack(children: [
      Padding(
        padding: EdgeInsets.only(left: gutterWidth),
        child: RichText(
          text: TextSpan(children: spans),
          softWrap: false,
        ),
      ),
      Container(
          width: gutterWidth,
          alignment: Alignment.centerRight,
          child: Text('${lineNumber + 1} ', style: gutterStyle)),
    ]);
  }
}

class View extends StatefulWidget {
  View({Key? key, this.path = ''}) : super(key: key);
  String path = '';

  @override
  _View createState() => _View();
}

class _View extends State<View> {
  late ScrollController scroller;

  @override
  void initState() {
    scroller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    scroller.dispose();
    super.dispose();
  }

  final int pageSize = 500;
  final scroll = ItemScrollController();
  //TODO review the used package, JsonBuddy doesnt need async magic
  // Check why some linese are shown incorrects

  @override
  Widget build(BuildContext context) {
    DocumentProvider doc = Provider.of<DocumentProvider>(context);

    /*return HugeListView<String>(
      pageSize: pageSize,
      startIndex: 0,
      controller: scroll,
      totalCount: doc.doc.lines.length,
      pageFuture: (int page) async {
        final from = page * pageSize;
        final to = min(doc.doc.lines.length, from + pageSize);
        return doc.doc.lines.sublist(from, to);
      },
      itemBuilder: (context, index, text) {
        return ViewLine(
          lineNumber: index,
          text: text,
        );
      },
      placeholderBuilder: (context, index) {
        return ViewLine(
          lineNumber: index,
          text: doc.doc.lines[index],
        );
      },
      thumbBuilder: DraggableScrollbarThumbs.ArrowThumb,
    );
    */
    return ListView.builder(
      controller: scroller,
      itemCount: doc.doc.lines.length,
      itemBuilder: (BuildContext context, int index) {
        return ViewLine(
          lineNumber: index,
          text: doc.doc.lines[index],
        );
      },
    );
  }
}
