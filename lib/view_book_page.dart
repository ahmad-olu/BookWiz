import 'package:flutter/material.dart';
import 'package:flutter_book_publishing_app/book_model.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:markdown_widget/markdown_widget.dart';

class ViewBookPage extends HookWidget {
  const ViewBookPage({super.key, required this.book});
  final BookModel book;

  @override
  Widget build(BuildContext context) {
    final pageCont = usePageController();
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: PageView.builder(
          controller: pageCont,
          itemCount: book.chapters.length,
          itemBuilder: (context, index) {
            final b = book.chapters[index];
            return MarkdownWidget(data: b.data);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => pageCont.nextPage(
          duration: const Duration(seconds: 1),
          curve: Curves.bounceInOut,
        ),
        child: const Text('⏭️'),
      ),
    );
  }
}
