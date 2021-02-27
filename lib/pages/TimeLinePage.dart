import 'package:artessan_v0/models/post.dart';
import 'package:artessan_v0/models/user.dart';
import 'package:artessan_v0/widgets/HeaderWidget.dart';
import 'package:artessan_v0/widgets/HomeHeaderWidget.dart';
import 'package:artessan_v0/widgets/PostWidget.dart';
import 'package:artessan_v0/widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'HomePage.dart';

class TimeLinePage extends StatefulWidget {

  final User gCurrentUser;
  TimeLinePage({this.gCurrentUser});

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {


  List<Post> posts;
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    retrieveTimeLine();
    retrieveFollowing();
  }

  /*
  TODO:: check if this is the correct way
  retrieveTimeLine() async{
    QuerySnapshot querySnapshot = await timelineReference.document(widget.gCurrentUser.id)
        .collection("timelinePosts").orderBy("timestamp", descending: true).getDocuments();

    List<Post> allPosts = querySnapshot.documents.map((document) =>Post.fromDocument(document)).toList();

    setState(() {
      this.posts = allPosts;
    });
  } */

  retrieveTimeLine() async{
   // QuerySnapshot querySnapshot = await timelineReference.document(widget.gCurrentUser.id)
  //      .collection("timelinePosts").orderBy("timestamp", descending: true).getDocuments();
    //TODO:: improve this
    print("current user");
    print("id: ${widget.gCurrentUser.id}");
    print("username name: ${widget.gCurrentUser.username}");

    QuerySnapshot querySnapshot = await postsReference.document(widget.gCurrentUser.id).
    collection("usersPosts").orderBy("timestamp", descending: true).getDocuments();

    QuerySnapshot querySnapshotUsersFollowing = await followingReference.document(widget.gCurrentUser.id).
    collection("userFollowing").getDocuments();

    List<Post> allPosts = querySnapshot.documents.map((document) =>Post.fromDocument(document)).toList();
    List<String> allFollowing =  querySnapshotUsersFollowing.documents.map((document) => document.documentID).toList();

    querySnapshot.documents.map((document) => print("dsa"));

    allFollowing.map((uid) => {
      print("dsa")
    });

    querySnapshotUsersFollowing.documents.forEach((document) async {
      QuerySnapshot querySnapshotFolowingPosts = await postsReference.document(document.documentID).
      collection("usersPosts").orderBy("timestamp", descending: true).getDocuments();
      List<Post> followingPosts = querySnapshotFolowingPosts.documents.map((document) =>Post.fromDocument(document)).toList();
      followingPosts.forEach((post) {
        allPosts.add(post);
      });
    });

    setState(() {
      this.posts = allPosts;
    });
  }

  retrieveFollowing() async{
    QuerySnapshot querySnapshot = await followingReference.document(currentUser.id).collection("userFollowing").getDocuments();

    setState(() {
      followingsList = querySnapshot.documents.map((document) => document.documentID).toList();
    });
  }

  createUserTimeline(){
    if(posts == null){
      return circularProgress();
    }else{
      return ListView(children: posts,);
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: homeHeader(context),
      body: RefreshIndicator(child: createUserTimeline(),onRefresh: ()=>retrieveFollowing()),//onRefresh: ()=>retrieveTimeLine()
    );
  }
}
