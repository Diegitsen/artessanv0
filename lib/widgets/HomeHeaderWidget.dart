import 'package:artessan_v0/pages/BagPage.dart';
import 'package:artessan_v0/pages/HomePage.dart';
import 'package:artessan_v0/pages/ProfilePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

homeHeader1(context) {
  return Container(
    decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5 ))
    ),
    height: 50,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
            child:  GestureDetector(
              onTap: (){
                goToProfile(context);
              },
              child: Center(
                child: CircleAvatar(radius: 13, backgroundImage: (currentUser.url == null) ? CachedNetworkImageProvider("") : CachedNetworkImageProvider(currentUser.url),),

              ),
            ),
        ),
        Spacer(),
        Text("Artessan",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22
          ),),
        Spacer(),
        Expanded(
            child: GestureDetector(
                child:
                  Icon(Icons.shopping_bag_outlined),
              onTap: (){
                goToBag(context);
              },
            )
        ),
      ],
    ),
  );
}

homeHeader(context) {
  return AppBar(
    elevation: 1,
    backgroundColor: Colors.white,
    centerTitle: true,
    title: Text("Artessan"),
    leading: GestureDetector(
      onTap: (){
        goToProfile(context);
      },
      child: Center(
        child: CircleAvatar(radius: 13, backgroundImage: (currentUser.url == null) ? CachedNetworkImageProvider("") : CachedNetworkImageProvider(currentUser.url),),
      ),
    ),
    actions: <Widget>[
      IconButton(
          icon: Icon(
            Icons.shopping_bag_outlined,
            color: Colors.black,
          ),
          onPressed: (){
            goToBag(context);
          },),
    ],
  );
}

goToProfile(BuildContext context) async {

  await Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation1, animation2){
        return FadeTransition(
          opacity: animation1,
          child: ProfilePage(userProfileId: currentUser.id,),);
      }));
}

goToBag(BuildContext context) async {

  await Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation1, animation2){
        return FadeTransition(
          opacity: animation1,
          child: BagPage(),);
      }));
}

/*
 () async {
               // SharedPreferences prefs = await SharedPreferences.getInstance();
               // prefs.remove('isLogin');
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (BuildContext ctx) => ProfilePage(userProfileId: currentUser.id,)));
              //  Navigator.pushReplacementNamed(context, '/ProfilePage');
              }
 */

