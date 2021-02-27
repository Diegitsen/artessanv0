import 'package:artessan_v0/models/tag.dart';
import 'package:artessan_v0/models/user.dart';
import 'package:artessan_v0/pages/ProfilePage.dart';
import 'package:artessan_v0/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'HomePage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage>{

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;
  Future<QuerySnapshot> tagsResults;

  emptyTheTextFormField(){
    searchTextEditingController.clear();
  }

  controlSearching(String str){
    if(str != ""){
      Future<QuerySnapshot> allUsers = usersReference.where("email", isGreaterThanOrEqualTo: str).getDocuments();
      setState(() {
        futureSearchResults = allUsers;
      });
    }else{
      print("asddd");
      Future<QuerySnapshot> showTags = tagsReference.where("type", isEqualTo: "1").getDocuments();
      setState(() {
        tagsResults = showTags;
        print("www");
        if(tagsResults == null){
          print("ttt");
        }else{
          print("rrr");
        }
      });
    }
  }

 // var list = ["Vintage", "Oversize", "Gucci", "Retro", "80s", "Segunda", "Reinvento"];

  displayNoSearchResultScreen() {

    return FutureBuilder(
      future: tagsResults,
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData){
          print("ENTER HEREEE");
          return circularProgress();
        }

        List<Tag> tagsResult = [];
        dataSnapshot.data.documents.forEach((document){
          Tag eachTag = Tag.fromDocument(document);
          tagsResult.add(eachTag);
          print("HAAA");
          print(eachTag.name);
        });

        return Container(
            margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
            height: 35.0,
            child: new ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                for (var item in tagsResult)
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Container(
                      width: 100,
                      height: 35,
                      child: Text(
                        item.name,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  )
              ],
            ));
      },

    );
  }


  displayUsersFoundScreen(){
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData){
          return circularProgress();
        }

        List<UserResult> searchUsersResult = [];
        dataSnapshot.data.documents.forEach((document){
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser);
          searchUsersResult.add(userResult);
        });

        return ListView(children: searchUsersResult,);
      },
    );
  }

  AppBar searchPageHeader(){
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        style: TextStyle(fontSize: 18, color: Colors.black),
        controller: searchTextEditingController,
        decoration: InputDecoration(
            hintText: "Search here...",
            hintStyle: TextStyle(color: Colors.black),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            filled: true,
            prefixIcon: Icon(Icons.person_pin, color: Colors.black, size: 30,),
            suffixIcon: IconButton(icon: Icon(Icons.clear, color: Colors.black,), onPressed: emptyTheTextFormField,)
        ),
        onFieldSubmitted: controlSearching,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: searchPageHeader(),
      body: futureSearchResults == null ? displayNoSearchResultScreen() : displayUsersFoundScreen(),
    );
  }


  bool get wantKeepAlive => true;

}

class UserResult extends StatelessWidget {

  final User eachUser;
  UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: ()=> displayUserProfile(context, userProfileId: eachUser.id),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage: CachedNetworkImageProvider(eachUser.url),),
                title: Text(eachUser.profileName, style:
                TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
                subtitle: Text(
                  eachUser.username, style: TextStyle(
                    color: Colors.black,
                    fontSize: 13
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  displayUserProfile(BuildContext context, {String userProfileId}){
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userProfileId: userProfileId)));
  }

}