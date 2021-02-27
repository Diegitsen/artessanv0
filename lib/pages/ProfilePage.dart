import 'package:artessan_v0/models/user.dart';
import 'package:artessan_v0/pages/HomePage.dart';
import 'package:artessan_v0/pages/NotificationsPage.dart';
import 'package:artessan_v0/pages/SettingsPage.dart';
import 'package:artessan_v0/widgets/HeaderWidget.dart';
import 'package:artessan_v0/widgets/PostTile.dart';
import 'package:artessan_v0/widgets/PostWidget.dart';
import 'package:artessan_v0/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'HomePage.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;
  ProfilePage({this.userProfileId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final String currentOnlineUserId = currentUser?.id;
  bool loading = false;
  int countPost = 0;
  List<Post> postsList = [];
  String postOrientation = "selling";
  int countTotalFollowers = 0;
  int countTotalFollowings = 0;
  bool following = false;

  void initState(){
    getAllProfilePosts();
    getAllFollowers();
    getAllFollowings();
    checkIfAlreadyFollowing();
  }

  getAllFollowings() async{
    QuerySnapshot querySnapshot = await followingReference.document(widget.userProfileId)
        .collection("userFollowing").getDocuments();
    setState(() {
      countTotalFollowings = querySnapshot.documents.length;
    });
  }

  checkIfAlreadyFollowing() async{
    DocumentSnapshot documentSnapshot = await followersReference
        .document(widget.userProfileId).collection("userFollowers")
        .document(currentOnlineUserId).get();

    setState(() {
      following = documentSnapshot.exists;
    });
  }

  getAllFollowers() async{
    QuerySnapshot querySnapshot = await followersReference.document(widget.userProfileId)
        .collection("userFollowers").getDocuments();

    setState(() {
      countTotalFollowers = querySnapshot.documents.length;
    });
  }

  createProfileTopView(){
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData){
          return circularProgress();
        }
        User user = User.fromDocument(dataSnapshot.data);
        return Padding(
          padding: EdgeInsets.all(17),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey,
                    //(widget.gCurrentUser.url == null) ? CachedNetworkImageProvider("https://lh3.googleusercontent.com/a-/AOh14GgA5UD6H1AthKJQkRA82gCAJFqNRScSyxACAB3rgA=s96-c") : CachedNetworkImageProvider(widget.gCurrentUser.url),),
                    backgroundImage: user.url == null ? CachedNetworkImageProvider("") : CachedNetworkImageProvider(user.url),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(left: 20.0, right: 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                user.profileName ?? "",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Divider(color: Colors.white, height: 2,),
                              Text(
                                "@${user.username ?? ""}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                        showReviewStarts("0"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            createButton(),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Divider(color: Colors.white, height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  showFollowers("followers", countTotalFollowers),
                  VerticalDivider(),
                  showFollowers("following", countTotalFollowings),
                ],
              ),
              Divider(color: Colors.white,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.bio ?? ""
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  createButton(){
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if(ownProfile){
      return createButtonTitleAndFunction(title: "Encontrar amigos", performFunction: editUserProfile);
    }else if(following){
      return createButtonTitleAndFunction(title: "Dejar de seguir", performFunction: controlUnfollowUser);
    }else if(!following){
      return createButtonTitleAndFunction(title: "Seguir", performFunction: controlFollowUser);
    }
  }

  controlUnfollowUser(){
    setState(() {
      following = false;
    });

    followersReference.document(widget.userProfileId)
          .collection("userFollowers")
          .document(currentOnlineUserId)
          .get()
          .then((document){
            if(document.exists){
              document.reference.delete();
            }
          });

    followingReference.document(currentOnlineUserId)
        .collection("userFollowing")
        .document(widget.userProfileId)
        .get()
        .then((document){
          if(document.exists){
              document.reference.delete();
            }
          });

    activityFeedReference.document(widget.userProfileId).collection("feedItem")
      .document(currentOnlineUserId).get().then((document){
        if(document.exists){
          document.reference.delete();
        }
      });
  }

  controlFollowUser(){
    setState(() {
      following = true;
    });

    followersReference.document(widget.userProfileId).collection("userFollowers")
      .document(currentOnlineUserId)
      .setData({});

    followingReference.document(currentOnlineUserId).collection("userFollowing")
      .document(widget.userProfileId)
      .setData({});

    activityFeedReference.document(widget.userProfileId)
      .collection("feedItems").document(currentOnlineUserId)
      .setData({
        "type": "follow",
        "ownerId": widget.userProfileId,
        "username": currentUser.username,
        "timestamp": DateTime.now(),
        "userProfileImg": currentUser.url,
        "userId": currentOnlineUserId
      });
  }

  editUserProfile(){
   // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }

  Container createButtonTitleAndFunction({String title, Function performFunction}){
    return Container(
      padding: EdgeInsets.only(top: 3),
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: 245,
          height: 35,
          child: Text(title, style: TextStyle(color: following ? Colors.white : Colors.black, fontWeight: FontWeight.bold),),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: following ? Colors.grey :  Colors.white,
              border: Border.all(color: following ? Colors.grey : Colors.black),
              borderRadius: BorderRadius.circular(6)
          ),
        ),
      ),
    );
  }

  Container showReviewStarts(String numberOfReviews ,{Function performFunction}){
    return Container(
      margin: const EdgeInsets.only(left: 5.0, right: 0.0),
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          height: 26,
          child: Row(
            children: <Widget>[
              Icon(Icons.star),
              Icon(Icons.star),
              Icon(Icons.star),
              Icon(Icons.star),
              Icon(Icons.star),
              Text(
                "$numberOfReviews Reviews",
              )
            ],
          ),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  //Text("Reviews", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),)

  Column createColumns(String title, int count){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),

        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          child: Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Row showFollowers(String title, int count){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        VerticalDivider(width: 5,),
        Text(
          title,
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        //title: Text("Perfil"),
        leading: BackButton(
          color: Colors.black,
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.receipt_long,
                color: Colors.black,
              ),
              onPressed: null),
          IconButton(
              icon: Icon(
                Icons.notifications,
                color: Colors.black,
              ),
              onPressed: ()=>goToNotifications(context)),
          IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.black,
              ),
              onPressed: ()=>goToSettings(context)),
        ],
      ),//header(context, strTitle: "Profile"),
      body: ListView(
        children: <Widget>[
          createProfileTopView(),
          Divider(),
          createListAndGridPostOrientation(),
          Divider(height: 0.0,),
          displayProfilePost(),
        ],
      ),
    );
  }

  goToNotifications(BuildContext context) async {

    await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation1, animation2){
          return FadeTransition(
            opacity: animation1,
            child: NotificationsPage(),);
        }));
  }

  goToSettings(BuildContext context) async {

    await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation1, animation2){
          return FadeTransition(
            opacity: animation1,
            child: SettingsPage(),);
        }));
  }

  displayProfilePost(){
    if(loading){
      return circularProgress();
    }else if(postsList.isEmpty){
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30),
              child: Icon(Icons.photo_library, color: Colors.grey, size: 200,),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("No posts",
                style: TextStyle(color: Colors.redAccent, fontSize: 40, fontWeight: FontWeight.bold ),
              ),
            )
          ],
        ),
      );
    }else if(postOrientation == "selling"){
      List<GridTile> gridTilesList = [];
      postsList.forEach((eachPost) {
        print("each post");
        print(eachPost.url);
        gridTilesList.add(GridTile(
          child: PostTile(eachPost),
        ));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTilesList,
      );

    }else if(postOrientation == "likes"){
      return Column(
        children: postsList,
      );
    }
  }

  createListAndGridPostOrientation(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        FlatButton(
          onPressed: () => setOrientation("selling"),
          child: Text(
            "Vendiendo",
            style: TextStyle(
              fontWeight: postOrientation=="selling" ? FontWeight.bold :  FontWeight.normal,
            ),
          ),
        ),
        FlatButton(
          onPressed: () => setOrientation("likes"),
          child: Text(
              "Gustados",
              style: TextStyle(
                fontWeight: postOrientation=="likes" ? FontWeight.bold :  FontWeight.normal,
             ),
          ),
        ),
        FlatButton(
          onPressed: () => setOrientation("saved"),
          child: Text(
              "Guardados",
               style: TextStyle(
                fontWeight: postOrientation=="saved" ? FontWeight.bold :  FontWeight.normal,
              ),
          ),
        ),
      ],
    );
  }

  setOrientation(String orientation){
    setState(() {
      this.postOrientation = orientation;
    });
  }

  getAllProfilePosts() async{
    setState(() {
      loading = true;
    });

    QuerySnapshot querySnapshot = await postsReference.document(widget.userProfileId).collection("usersPosts").orderBy("timestamp", descending: true).getDocuments();

    setState(() {
      loading = false;
      countPost = querySnapshot.documents.length;
      postsList = querySnapshot.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
    });

  }

}

/*
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            createColumns("posts", 0),
                            createColumns("followers", 0),
                            createColumns("following", 0),
                          ],
                        ),

             Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 13),
                child: Text(
                  user.username, style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),


 */
