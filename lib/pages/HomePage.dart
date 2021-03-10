
import 'dart:io';

import 'package:artessan_v0/models/user.dart';
import 'package:artessan_v0/pages/CreateAccountPage.dart';
import 'package:artessan_v0/pages/SearchPage.dart';
import 'package:artessan_v0/pages/TimeLinePage.dart';
import 'package:artessan_v0/pages/UploadPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


final GoogleSignIn gSignIn = GoogleSignIn();
final usersReference = Firestore.instance.collection("users");
final StorageReference storageReference = FirebaseStorage.instance.ref().child("Posts Pictures");
final DateTime timestamp = DateTime.now();
final postsReference = Firestore.instance.collection("posts");
final activityFeedReference = Firestore.instance.collection("feed");
final commentsReference = Firestore.instance.collection("comments");
final followersReference = Firestore.instance.collection("followers");
final followingReference = Firestore.instance.collection("following");
final timelineReference = Firestore.instance.collection("timeline");
final tagsReference = Firestore.instance.collection("tags");
final stylesReference = Firestore.instance.collection("styles");
final userTagsReference = Firestore.instance.collection("user_tags");


User currentUser;

class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  @override
  Widget build(BuildContext context) {
    if(isSignedIn){
      return buildHomeScreen();
    }else{
      return buildSignInScreen();
    }
  }

  bool isSignedIn = false;
  PageController pageController;
  int getPageIndex = 0;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void initState(){
    super.initState();

    pageController = PageController();

    gSignIn.onCurrentUserChanged.listen((gSigninAccount) {
      controlSignIn(gSigninAccount) ;
    }, onError: (gError){
      print("Error message: " + gError);
    });

    gSignIn.signInSilently(suppressErrors: false).then((gSigninAccount){
      controlSignIn(gSigninAccount);
    }).catchError((gError){
      print("Error message: " + gError);
    });
  }

  controlSignIn(GoogleSignInAccount signInAccount) async{
    print("ENTROOOOOO");
    if(signInAccount != null){
      await saveUserInfoToFireStore();
      setState(() {
        isSignedIn = true;
      });
    }else{
      setState(() {
        isSignedIn = false;
      });
    }
  }

  configureRealTimePushNotifications(){
    final GoogleSignInAccount gUser = gSignIn.currentUser;
    if(Platform.isIOS){
      getIOSPermissions();
    }

    _firebaseMessaging.getToken().then((token) =>{
      usersReference.document(gUser.id).updateData({"androidPushNotificationToken": token})
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> msg) async{
        final String recipientId = msg["data"]["recipient"];
        final String body = msg["notification"]["body"];

        if(recipientId == gUser.id){
          SnackBar snackBar = SnackBar(
              backgroundColor: Colors.grey,
              content: Text(body, style: TextStyle(color: Colors.black),
              overflow: TextOverflow.ellipsis,),
          );
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
      }
    );
  }

  getIOSPermissions(){
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print("Settings registered : $settings");
    });

  }

  saveUserInfoToFireStore() async{
    final GoogleSignInAccount gCurrentUser = gSignIn.currentUser;
    DocumentSnapshot documentSnapshot = await usersReference.document(gCurrentUser.id).get();

    if(!documentSnapshot.exists){
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));

      usersReference.document(gCurrentUser.id).setData({
        "id":gCurrentUser.id,
        "profileName":gCurrentUser.displayName,
        "username": username,
        "url":gCurrentUser.photoUrl,
        "email":gCurrentUser.email,
        "bio":"",
        "timestamp": timestamp
      });
      
      await followersReference.document(gCurrentUser.id).collection("userFollowers").document(gCurrentUser.id).setData({

      });

      documentSnapshot = await usersReference.document(gCurrentUser.id).get();

    }

    currentUser = User.fromDocument(documentSnapshot);
  }

  void dispose(){
    pageController.dispose();
    super.dispose();
  }

  loginUser(){
    gSignIn.signIn();
  }

  logoutUser(){
    gSignIn.signOut();
  }

  whenPageChanges(int pageIndex){
    setState(() {
      this.getPageIndex = pageIndex;
    });

  }

  onTapPageChanged(int pageIndex){
   // pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 400), curve: Curves.bounceInOut,);
    pageController.jumpToPage(pageIndex);
  }


  Widget buildHomeScreen(){
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          TimeLinePage(gCurrentUser: currentUser,),
          UploadPage(gCurrentUser: currentUser,),
          SearchPage(),
          //UploadPage(gCurrentUser: currentUser,),
         // NotificationsPage(),
         // ProfilePage(userProfileId: currentUser.id,)
        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapPageChanged,
        backgroundColor: Theme.of(context).accentColor,
        activeColor: Colors.black,
        inactiveColor: Colors.blueGrey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera, size: 30,)),
          BottomNavigationBarItem(icon: Icon(Icons.search, size: 30)),
         // BottomNavigationBarItem(icon: Icon(Icons.favorite)),
        //  BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  Scaffold buildSignInScreen(){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/depop_login.jpeg"),
                fit: BoxFit.cover
            )
        ),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Divider(height: 60,),
            Text(
              "  Artessan  ",
              style: TextStyle(
                  fontSize:35,
                  color: Colors.white,
                  backgroundColor: Colors.black,
                  fontFamily: "Signatra"
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: loginUser,
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Iniciar sesión",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: "Signatra"
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 15,),
            GestureDetector(
              onTap: loginUser,
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Registrarse",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: "Signatra"
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 15,),
            GestureDetector(
              onTap: loginUser,
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Continuar con Google",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: "Signatra"
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 65,),
          ],
        ),
      ),
    );
  }
}