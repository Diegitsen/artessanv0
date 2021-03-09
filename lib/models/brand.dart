import 'package:cloud_firestore/cloud_firestore.dart';

class Brand {
  final int id;
  final String name;

  Brand({
    this.id,
    this.name,
  });

  factory Brand.fromDocument(DocumentSnapshot doc) {
    return Brand(
      id: doc['id'],
      name: doc['name'],
    );
  }
}