import 'package:cloud_firestore/cloud_firestore.dart';

class Brand {
  String id;
  final String name;
  bool isSelected;

  Brand({
    this.id = "",
    this.name,
    this.isSelected = false
  });

  factory Brand.fromDocument(DocumentSnapshot doc) {
    return Brand(
      id: doc['id'],
      name: doc['name'],
    );
  }
}