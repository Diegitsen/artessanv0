
import 'package:cloud_firestore/cloud_firestore.dart';

/*class Post {
  final String postId;
  final String ownerId;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;

  const Post({this.postId, this.ownerId,
    this.likes, this.username, this.description,
    this.location, this.url});

  factory Post.fromDocument(DocumentSnapshot documentSnapshot){
    return Post(
      postId: documentSnapshot["postId"],
      ownerId: documentSnapshot["ownerId"],
      likes: documentSnapshot["likes"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      url: documentSnapshot["url"],
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

}*/