import 'package:cloud_firestore/cloud_firestore.dart';

class Tag {
  final String name;
  final int type;

  Tag({
    this.name,
    this.type,
  });

  factory Tag.fromDocument(DocumentSnapshot doc) {
    return Tag(
      name: doc['name'],
      type: doc['type'],
    );
  }
}