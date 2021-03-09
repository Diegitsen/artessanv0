import 'package:cloud_firestore/cloud_firestore.dart';

class Style {
  final String name;
  final String url;

  Style({
    this.name,
    this.url,
  });

  factory Style.fromDocument(DocumentSnapshot doc) {
    return Style(
      name: doc['name'],
      url: doc['url'],
    );
  }
}