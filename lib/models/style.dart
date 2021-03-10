import 'package:cloud_firestore/cloud_firestore.dart';

class Style {
  String id;
  final String name;
  final String url;
  bool isSelected;

  Style({
    this.id = "",
    this.name,
    this.url,
    this.isSelected = false
  });

  factory Style.fromDocument(DocumentSnapshot doc) {
    return Style(
      id: doc['id'],
      name: doc['name'],
      url: doc['url'],
    );
  }
}