
import 'package:artessan_v0/models/style.dart';
import 'package:artessan_v0/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'HomePage.dart';

class EditStylesPage extends StatefulWidget {
  @override
  _BagPageState createState() => _BagPageState();
}

class _BagPageState extends State<EditStylesPage> {

  List<Style> styles;
  List<Style> userStyles = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveStyles();
    retrieveUserStyles();
  }

  retrieveStyles() async{

    QuerySnapshot querySnapshot = await tagsReference.document("styles").collection("styles").getDocuments();

    List<Style> styles = querySnapshot.documents.map((document) =>Style.fromDocument(document)).toList();

    setState(() {
      this.styles = styles;
    });
  }

  retrieveUserStyles() async{

    QuerySnapshot querySnapshot = await userTagsReference.document(currentUser.id).collection("styles").getDocuments();
    userStyles = querySnapshot.documents.map((documentSnapshot) => Style.fromDocument(documentSnapshot)).toList();
    for(var style in styles){
      for(var userStyle in userStyles){
        if(style.name == userStyle.name){
          setState(() {
            style.id = userStyle.id;
            style.isSelected = true;
          });
        }
      }
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text("Estilos"),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
        body: Padding(
            padding: const EdgeInsets.all(15),
            child: styles != null ? ListView(
                children: <Widget>[
                  Text("Usaremos esta información para mostrarte productos que te gusten :)"),
                  Divider(color: Colors.white,),
                  showStyles()
                ]
            ) :  CircularProgressIndicator()
        ),
    );
  }

  /*
  ListView(
        children: <Widget>[
        Text("
            Usaremos esta información para mostrarte productos que te gusten :)
            "),
        Divider(color: Colors.white,),
        showStyles()
        ]
    )
   */

  showStyles() {
    List<GridTile> gridTilesList = [];
    styles.forEach((style) {
      gridTilesList.add(GridTile(
        child: style.isSelected
            ? ColorFiltered(
                colorFilter: ColorFilter.mode(
                    Colors.deepPurpleAccent.withOpacity(0.4),
                    BlendMode.srcOver),
                child: getImageWidget(style))
            : getImageWidget(style),
      ));
    });
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: gridTilesList,
    );
  }

  Widget getImageWidget(Style style) {
    return GestureDetector(
      onTap: ()=>updateStyleSelection(style),
      child: Container(
        decoration: new BoxDecoration(color: Colors.white),
        height: 240,
        child: Stack(
          children: <Widget>[
            Image.network(style.url),
            style.isSelected ? Positioned(
                top: 0, right: 0, bottom: 0, left: 0, //give the values according to your requirement
                child: Icon(Icons.favorite, color: Colors.white, size: 35,)
              //IconButton(icon: Icon(Icons.delete_forever, color: Colors.redAccent,), onPressed: () {  },),
            ) : Text(""),
            Positioned(
                bottom: 0, left: 5, //give the values according to your requirement
                child: textWithStroke(text: style.name, fontSize: 20)
              //IconButton(icon: Icon(Icons.delete_forever, color: Colors.redAccent,), onPressed: () {  },),
            ),

          ],
        ),
      ),
    );
  }

  updateStyleSelection(Style style){
    if (style.isSelected) {
      userTagsReference.document(currentUser.id).collection("styles").document(style.id).get().then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });

      setState(() {
        style.isSelected = false;
      });
    } else {
      var userStyleId = Uuid().v4();
      userTagsReference.document(currentUser.id).collection("styles").document(userStyleId).setData({
        "id": userStyleId,
        "name": style.name,
        "url": style.url,
      });

      setState(() {
        style.id = userStyleId;
        style.isSelected = true;
      });
    }


  }

  Widget textWithStroke({String text, String fontFamily, double fontSize: 12, double strokeWidth: 1, Color textColor: Colors.white, Color strokeColor: Colors.black}) {
    return Stack(
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: fontFamily,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(text, style: TextStyle(fontFamily: fontFamily, fontSize: fontSize, color: textColor)),
      ],
    );
  }
}
