import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book_publishing_app/snackbar_util.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_book_publishing_app/book_model.dart';

@immutable
class BookFormModel {
  final String id;
  final String chapter;
  final String data;

  const BookFormModel(
      {required this.id, required this.chapter, required this.data});

  BookFormModel copyWith({
    String? id,
    String? chapter,
    String? data,
  }) {
    return BookFormModel(
      id: id ?? this.id,
      chapter: chapter ?? this.chapter,
      data: data ?? this.data,
    );
  }
}

class BookFormPage extends HookWidget {
  const BookFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = useTextEditingController(text: '');
    final chapters = useState<List<BookFormModel>>([]);
    final isLoading = useState<bool>(false);

    void upload() async {
      isLoading.value = true;

      CollectionReference books =
          FirebaseFirestore.instance.collection('books');
      final currentUser = FirebaseAuth.instance.currentUser;

      try {
        if (titleController.text.length < 5) {
          log('How can your title be less than 5');
        } else if (chapters.value.isEmpty) {
          log('No chapter in this book, seriously');
        } else {
          final chapterList = chapters.value.map((e) {
            return Chapter(chapter: e.chapter, data: e.data);
          }).toList();
          final book = BookModel(
            uid: currentUser!.uid,
            title: titleController.text,
            chapters: chapterList,
          );
          books.add(book.toMap());
        }

        isLoading.value = false;
        snackBar(context, 'Uploaded', '', contentType: ContentType.success);
        Navigator.pop(context);
      } catch (e) {
        isLoading.value = false;
        snackBar(context, 'Authentication', 'You just signed out',
            contentType: ContentType.failure);
      }
    }

    void addChapters() {
      chapters.value = [
        ...chapters.value,
        BookFormModel(id: const Uuid().v1(), chapter: '', data: ''),
      ];
    }

    void updateChapters(int index, String value, {bool isData = true}) {
      if (isData == true) {
        final chapter = chapters.value[index];
        chapters.value = chapters.value.map((e) {
          if (e.id == chapter.id) {
            return e.copyWith(data: value);
          }
          return e;
        }).toList();
      }
      final chapter = chapters.value[index];
      chapters.value = chapters.value.map((e) {
        if (e.id == chapter.id) {
          return e.copyWith(chapter: value);
        }
        return e;
      }).toList();
    }

    void deleteChapters(int index) {
      final chapter = chapters.value[index];
      chapters.value = chapters.value.where((e) => e.id != chapter.id).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('form'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child:
                ElevatedButton(onPressed: upload, child: const Text('Upload')),
          )
        ],
      ),
      body: isLoading.value == true
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    BookTextInput(
                      controller: titleController,
                      helperText: 'Book Title',
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < chapters.value.length; i++)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        key: ValueKey(chapters.value[i].id),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: BookTextInput(
                                  helperText: 'Chapter Number',
                                  hintText: 'Chapter 1 / Book 1/ Episode 1',
                                  onChanged: (value) =>
                                      updateChapters(i, value, isData: false),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: ElevatedButton(
                                  onPressed: () => deleteChapters(i),
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(20, 50)),
                                  child: const Text('➖',
                                      textAlign: TextAlign.center),
                                ),
                              ),
                            ],
                          ),
                          MarkdownTextInput(
                            (String value) => updateChapters(i, value),
                            "Cancel this and start...",
                            label: 'Story',
                            maxLines: 10,
                            actions: const [
                              MarkdownType.bold,
                              MarkdownType.italic,
                              MarkdownType.title,
                              MarkdownType.list,
                              MarkdownType.strikethrough,
                              MarkdownType.separator,
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(
                            thickness: 2,
                            color: Colors.black,
                          )
                        ],
                      )
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: addChapters, label: const Text('Add Chapters ➕')),
    );
  }
}

class BookTextInput extends StatelessWidget {
  const BookTextInput({
    super.key,
    this.onChanged,
    this.controller,
    this.helperText,
    this.hintText,
    this.enabled = true,
  });
  final void Function(String)? onChanged;
  final TextEditingController? controller;

  final String? helperText;
  final String? hintText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(
                color: Colors.black,
                width: 10,
                strokeAlign: BorderSide.strokeAlignOutside,
              )),
          helperText: helperText,
          hintText: hintText,
          enabled: enabled),
      onChanged: onChanged,
      controller: controller,
    );
  }
}
