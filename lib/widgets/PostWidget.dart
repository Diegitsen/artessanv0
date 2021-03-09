import 'dart:async';

import 'package:artessan_v0/models/post.dart';
import 'package:artessan_v0/models/user.dart';
import 'package:artessan_v0/pages/CommentsPage.dart';
import 'package:artessan_v0/pages/HomePage.dart';
import 'package:artessan_v0/pages/ProfilePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'ProgressWidget.dart';

class Post extends StatefulWidget {

  final String postId;
  final String ownerId;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  //final String url;
  final List<String> pics;


  const Post({this.postId, this.ownerId,
    this.likes, this.username, this.description,
    this.location, this.pics});

  factory Post.fromDocument(DocumentSnapshot documentSnapshot){
    return Post(
      postId: documentSnapshot["postId"],
      ownerId: documentSnapshot["ownerId"],
      likes: documentSnapshot["likes"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      pics:  List.from(documentSnapshot['pics']),//documentSnapshot["pics"] as List, // List.from(snapshot['players']),
    );
  }

  int getTotalNumberOfLikes(likes){
    if(likes == null){
      return 0;
    }
    int counter = 0;
    likes.values.forEach((eachValue){
      if(eachValue==true)
        counter = counter + 1;
    }
    );
    return counter;
  }


  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      likes: this.likes,
      username: this.username,
      description: this.description,
      location: this.location,
      pics: this.pics,
      likeCount: getTotalNumberOfLikes(this.likes)
  );
}

class _PostState extends State<Post> {

  final String postId;
  final String ownerId;
  Map likes;
  final String username;
  final String description;
  final String location;
  final List<String> pics;
  int likeCount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = currentUser?.id;

  _PostState({this.postId, this.ownerId,
    this.likes, this.username, this.description,
    this.location, this.pics, this.likeCount});

  @override
  Widget build(BuildContext context) {

    isLiked = (likes[currentOnlineUserId] == true);
    List<NetworkImage> listOfImages = <NetworkImage>[];

    for(var pic in pics){
      listOfImages.add(NetworkImage(pic));
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          createPostHead(),
          createPostPicture(listOfImages),
          createPostFooter()
        ],
      ),
    );
  }

  createPostHead(){
    return FutureBuilder(
      future: usersReference.document(ownerId).get(),
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData){
          return circularProgress();
        }
        User user = User.fromDocument(dataSnapshot.data);
        bool isPostOwner = currentOnlineUserId == ownerId;

        return ListTile(
          leading: CircleAvatar(backgroundImage: (user.url == null) ? CachedNetworkImageProvider("") : CachedNetworkImageProvider(user.url) , backgroundColor: Colors.grey,),
          title: GestureDetector(
            onTap: () => displayUserProfile(context, userProfileId: user.id),
            child: Text(
              user.username,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(location, style: TextStyle(color: Colors.black),),
          trailing: isPostOwner ? IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => controlPostDelete(context)
          ) : Text(""),
        );
      },
    );
  }

  controlPostDelete(BuildContext mContext){
    return showDialog(
        context: mContext,
        builder: (context){
          return SimpleDialog(
            title: Text("What do you want?", style: TextStyle(color: Colors.white),),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Delete this post", style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                  ),
                ),
                onPressed: (){
                  Navigator.pop(context);
                  removeUserPost();
                },
              ),
              SimpleDialogOption(
                child: Text("Cancel", style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
                onPressed: (){
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }

  removeUserPost() async{
    postsReference.document(ownerId).collection("usersPosts").document(postId).get()
        .then((document){
          if(document.exists){
            document.reference.delete();
          }
    });

    storageReference.child("post_$postId.jpg").delete();

    QuerySnapshot querySnapshot = await activityFeedReference.document(ownerId)
      .collection("feedItems").where("postId", isEqualTo: postId).getDocuments();

    querySnapshot.documents.forEach((document) {
      if(document.exists){
        document.reference.delete();
      }
    });

    QuerySnapshot commentsQuerySnapshot = await commentsReference.document(postId).collection("comments").getDocuments();

    commentsQuerySnapshot.documents.forEach((document) {
      if(document.exists){
        document.reference.delete();
      }
    });

  }

  displayUserProfile(BuildContext context, {String userProfileId}){
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userProfileId: userProfileId)));
  }

  removeLike(){
    bool isNotPostOwner = currentOnlineUserId != ownerId;

    if(isNotPostOwner){
      activityFeedReference.document(ownerId).collection("feedItems").document(postId).get()
          .then((document){
         if(document.exists){
           document.reference.delete();
         }
      });
    }
  }

  addLike(){
    bool isNotPostOwner = currentOnlineUserId != ownerId;

    if(isNotPostOwner){
      activityFeedReference.document(ownerId).collection("feedItems").document(postId).setData({
        "type":"like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "timestamp": DateTime.now(),
        "pics": pics,
        "postId": postId,
        "userProfileImg": currentUser.url
      });
    }
  }

  controlUserLikePost(){
    bool _liked = likes[currentOnlineUserId] == true;

    if(_liked){
      postsReference.document(ownerId).collection("usersPosts").document(postId).updateData({"likes.$currentOnlineUserId":false});
      removeLike();
      setState(() {
        likeCount = likeCount - 1;
        isLiked = false;
        likes[currentOnlineUserId] = false;
      });
    }else if(!_liked){
      postsReference.document(ownerId).collection("usersPosts").document(postId).updateData({"likes.$currentOnlineUserId":true});
      //postsReference.document(ownerId).collection("usersPost").document(postId).setData({
      //  'price': 120,
      //});
      addLike();

      setState(() {
        likeCount = likeCount + 1;
        isLiked = true;
        likes[currentOnlineUserId] = true;
        showHeart = true;
      });

      Timer(Duration(milliseconds: 800), (){
        setState(() {
          showHeart = false;
        });
      });
    }
  }


  createPostPicture(List<NetworkImage> images){
    return GestureDetector(
      onDoubleTap: ()=>controlUserLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          //Image.network("https://firebasestorage.googleapis.com/v0/b/artessan-54268.appspot.com/o/Posts%20Pictures%2Fpost_623e7d67-c763-4700-b717-c6796861aac81.jpg?alt=media&token=c0618255-8f7c-4da6-b3dc-ac421ddef6d1"),
          /*Carousel(
            images: [
              NetworkImage("https://firebasestorage.googleapis.com/v0/b/artessan-54268.appspot.com/o/Posts%20Pictures%2Fpost_623e7d67-c763-4700-b717-c6796861aac81.jpg?alt=media&token=c0618255-8f7c-4da6-b3dc-ac421ddef6d1"),
              NetworkImage("https://firebasestorage.googleapis.com/v0/b/artessan-54268.appspot.com/o/Posts%20Pictures%2Fpost_623e7d67-c763-4700-b717-c6796861aac82.jpg?alt=media&token=ca575ea5-f26d-41a4-90c0-5598a8253de6"),
            ],
          ),*/
          SizedBox(
              height: 400.0,
              width:  double.infinity,
              child: Carousel(
                images: images,
                dotSize: 4.0,
                dotSpacing: 15.0,
                dotColor: Colors.white,
                indicatorBgPadding: 5.0,
                dotBgColor: Colors.transparent,
                borderRadius: false,
                moveIndicatorFromBottom: 0,
                noRadiusForIndicator: true,
                overlayShadow: false,
                autoplay: false,
              )
          ),
          showHeart ? Icon(Icons.favorite, size: 120, color: Colors.pink,) : Text("")
        ],
      ),
    );
  }

  createPostFooter(){
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40, left: 10)),
            GestureDetector(
              onTap: ()=> controlUserLikePost(),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 40, left: 10)),
            GestureDetector(
              onTap: ()=>displayComments(context, postId: postId, ownerId: ownerId, pics: pics),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 28,
                color: Colors.black,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 40, left: 10)),
            GestureDetector(
              onTap: ()=>print("saved!"),
              child: Icon(
                Icons.bookmark_border,
                size: 28,
                color: Colors.black,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 40, left: 10)),
            GestureDetector(
              onTap: ()=>print("chat!"),
              child: Icon(
                Icons.mail_outline,
                size: 28,
                color: Colors.black,
              ),
            ),
            Spacer(),
            FlatButton(
              onPressed: ()=>print("chat!"),
              child: Container(
                height: 35,
                child: Text("Comprar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),),
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6)
                ),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(
                "A $likeCount personas le gusta esta publicación",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Text("$username ",
                style: TextStyle(color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(description, style: TextStyle(color: Colors.black),),
            ),
          ],
        )
      ],
    );
  }

  displayComments(BuildContext context, {String postId, String ownerId, List<String> pics}){
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return CommentsPage(postId: postId, postOwnerId: ownerId, pics: pics);
    }));
  }

}
