import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:flutter/foundation.dart';

@immutable
class BookModel {
  final String? id;
  final String uid;
  final String title;
  final List<Chapter> chapters;
  const BookModel({
    this.id,
    required this.uid,
    required this.title,
    required this.chapters,
  });

  BookModel copyWith({
    String? id,
    String? uid,
    String? title,
    List<Chapter>? chapters,
  }) {
    return BookModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      chapters: chapters ?? this.chapters,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'uid': uid,
      'chapters': chapters.map((x) => x.toMap()).toList(),
    };
  }

  factory BookModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;
    final uid = data['uid'] as String;
    final title = data['title'] as String;
    final chapterList = data['chapters'] as List<dynamic>;

    final chapters = chapterList
        .map((chapterData) =>
            Chapter.fromMap(chapterData as Map<String, dynamic>))
        .toList();

    return BookModel(id: id, uid: uid, title: title, chapters: chapters);
  }

  // {
  //   return BookModel(
  //     id: map['id'] ?? '',
  //     title: map['title'] ?? '',
  //     chapters:
  //         List<Chapter>.from(map['chapters']?.map((x) => Chapter.fromMap(x))),
  //   );
  // }

  @override
  String toString() => 'BookModel(id: $id, title: $title, chapters: $chapters)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookModel &&
        other.id == id &&
        other.title == title &&
        listEquals(other.chapters, chapters);
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ chapters.hashCode;
}

@immutable
class Chapter {
  final String chapter;
  final String data;

  const Chapter({
    required this.chapter,
    required this.data,
  });

  Chapter copyWith({
    String? chapter,
    String? data,
  }) {
    return Chapter(
      chapter: chapter ?? this.chapter,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chapter': chapter,
      'data': data,
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      chapter: map['chapter'] ?? '',
      data: map['data'] ?? '',
    );
  }

  @override
  String toString() => 'Chapter(chapter: $chapter, data: $data)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Chapter && other.chapter == chapter && other.data == data;
  }

  @override
  int get hashCode => chapter.hashCode ^ data.hashCode;
}
