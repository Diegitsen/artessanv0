import 'package:artessan_v0/pages/HomePage.dart';
import 'package:artessan_v0/widgets/HeaderWidget.dart';
import 'package:artessan_v0/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as tAgo;

class CommentsPage extends StatefulWidget{

  final String postId;
  final String postOwnerId;
  final List<String> pics;

  CommentsPage({this.postId, this.postOwnerId, this.pics});

  @override
  CommentsPageState createState() => CommentsPageState(postId: postId, postOwnerId: postOwnerId, pics: pics);

}

class CommentsPageState extends State<CommentsPage>{

  final String postId;
  final String postOwnerId;
  final List<String> pics;
  TextEditingController commentTextEditingController = TextEditingController();

  CommentsPageState({this.postId, this.postOwnerId, this.pics});

  retrieveComments(){
    return StreamBuilder(
        stream: commentsReference.document(postId).collection("comments").orderBy("timestamp", descending: false).snapshots(),
        builder: (context, dataSnapshot){
          if(!dataSnapshot.hasData){
            return circularProgress();
          }
          List<Comment> comments = [];
          dataSnapshot.data.documents.forEach((document){
            comments.add(Comment.fromDocument(document));
          });
          return ListView(
            children: comments,
          );
        },
    );
  }

  saveComment(){
    commentsReference.document(postId).collection("comments").add({
      "username": currentUser.username,
      "comment": commentTextEditingController.text,
      "timestamp": DateTime.now(),
      "url": currentUser.url,
      "userId": currentUser.id,
    });

    bool isNotPostOwner = postOwnerId != currentUser.id;

    if(isNotPostOwner){
      activityFeedReference.document(postOwnerId).collection("feedItems").add({
          "type": "comment",
          "commentData": commentTextEditingController.text,
          "postId": postId,
          "userId": currentUser.id,
          "username": currentUser.username,
          "userProfileImg": currentUser.url,
          "pics": pics,
          "timestamp": timestamp,
        }
      );
    }
    commentTextEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(child: retrieveComments()),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentTextEditingController,
              decoration: InputDecoration(
                labelText: "Escribe un comentario...",
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
              ),
              style: TextStyle(color: Colors.black),
            ),
            trailing: OutlineButton(
              onPressed: saveComment,
              borderSide: BorderSide.none,
              child: Text("Publicar", style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold),),
            ),
          ),
        ],
      ),
    );
  }

}

class Comment extends StatelessWidget{

  final String userName;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;

  Comment({this.userName, this.userId, this.url, this.comment, this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot){
    return Comment(
      userName: documentSnapshot["username"],
      userId: documentSnapshot["userId"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 6),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(userName + ": " + comment, style: TextStyle(fontSize: 18, color: Colors.black),),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(url),
              ),
              subtitle: Text(tAgo.format(timestamp.toDate()), style: TextStyle(color: Colors.black),),
            ),
          ],
        ),
      ),
    );
  }

}