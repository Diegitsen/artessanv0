import 'package:artessan_v0/pages/PostScreenPage.dart';
import 'package:artessan_v0/widgets/PostWidget.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {

  final Post post;

  const PostTile(this.post);

  displayFullPost(context){
    Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreenPage(
        postId: post.postId, userId: post.ownerId
    )));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>displayFullPost(context),
      child: Image.network(post.pics[0]),
      /*Carousel(
        images: [
          NetworkImage(post.pics[0])
        ],
      ),*/
      //Image.network(post.url),
    );
  }
}
