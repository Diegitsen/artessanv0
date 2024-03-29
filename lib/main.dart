import 'package:artessan_v0/pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'BuddiesGram',
        debugShowCheckedModeBanner: false,
        theme: ThemeData
          (
          scaffoldBackgroundColor: Colors.white,
          dialogBackgroundColor: Colors.black,
          primarySwatch: Colors.grey,
          cardColor: Colors.white70,
          accentColor: Colors.white,
        ),
        home: HomePage()
    );
  }
}

