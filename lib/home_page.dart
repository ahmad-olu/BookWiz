import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_book_publishing_app/book_form_page.dart';
import 'package:flutter_book_publishing_app/book_model.dart';
import 'package:flutter_book_publishing_app/snackbar_util.dart';
import 'package:flutter_book_publishing_app/view_book_page.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMounted = useIsMounted();

    Stream<List<BookModel>> getBooksStream() {
      return FirebaseFirestore.instance
          .collection('books')
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs
            .map((doc) => BookModel.fromDocumentSnapshot(doc))
            .toList();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Books'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  snackBar(context, 'Authentication', 'You just signed out',
                      contentType: ContentType.warning);
                } catch (e) {
                  return;
                }
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: StreamBuilder<List<BookModel>>(
        stream: getBooksStream(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text(
              'Something went wrong',
              textScaleFactor: 4,
            ));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text("Loading", textScaleFactor: 4));
          }

          final doc = snapshot.data! as List<BookModel>;

          if (doc.isEmpty) {
            return const Center(
              child: Text('No books yet', textScaleFactor: 4),
            );
          }

          return Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: doc.length,
                itemBuilder: (context, index) {
                  final book = doc[index];
                  return ListTile(
                    leading: const Text('📓', textScaleFactor: 4),
                    title: Text(
                      book.title,
                      textScaleFactor: 2,
                    ),
                    subtitle: Text('${book.chapters.length} chapters in total'),
                    onTap: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              ViewBookPage(book: book),
                        ),
                      );
                    },
                  );
                },
              ));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const BookFormPage(),
              ),
            );
          },
          label: const Text('Add book 📓')),
    );
  }
}
