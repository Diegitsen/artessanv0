import 'dart:io';

import 'package:artessan_v0/models/brand.dart';
import 'package:artessan_v0/models/style.dart';
import 'package:artessan_v0/pages/EditStylesPage.dart';
import 'package:artessan_v0/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InterestsPage extends StatefulWidget {
  @override
  _BagPageState createState() => _BagPageState();
}

class _BagPageState extends State<InterestsPage> {

  List<Style> styles;
  List<Brand> brands;

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text("Intereses"),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ), //header(context, strTitle: "Profile"),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(children: <Widget>[
          Row(children: <Widget>[
            Expanded(
                child: Text(
              "Estilos",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.left,
            )),
            GestureDetector(
                onTap: ()=>goToEditStyles(context),
                child: Text("editar estilos",
                    style: TextStyle(color: Colors.redAccent)))
          ]),
          showStyles(),
          Divider(),
          Row(children: <Widget>[
            Expanded(
                child: Text(
                  "Marcas",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.left,
                )),
            GestureDetector(
                onTap: ()=>{},
                child: Text("editar marcas",
                    style: TextStyle(color: Colors.redAccent)))
          ]),
          showBrands(),
          Divider(),
        ]),
      ),
    );
  }

  Container showStyles() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 180.0,
        child: new ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            if (styles != null)
              for (var style in styles) uploadPicFrame(style)
            else
              CircularProgressIndicator()
          ],
        ));
  }

  Container showBrands() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 30.0,
        child: new ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            if (brands != null)
              for (var brand in brands) uploadBrand(brand)
            else
              CircularProgressIndicator()
          ],
        ));
  }

  goToEditStyles(BuildContext context) async {
    await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation1, animation2){
          return FadeTransition(
            opacity: animation1,
            child: EditStylesPage(),);
        }));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    retrieveStyles();
    retrieveBrands();
  }

  GestureDetector uploadPicFrame(Style style) {
    return GestureDetector(
      onTap: () => {},
      child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: getImageWidget(style)
      ),
    );
  }

  GestureDetector uploadBrand(Brand brand) {
    return GestureDetector(
      onTap: () => {},
      child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: getBrandWidget(brand)
      ),
    );
  }

  retrieveStyles() async{

    QuerySnapshot querySnapshot = await userTagsReference.document(currentUser.id).collection("styles").getDocuments();
    List<Style> styles = querySnapshot.documents.map((document) =>Style.fromDocument(document)).toList();
    setState(() {
      this.styles = styles;
    });
  }

  retrieveBrands() async{

    QuerySnapshot querySnapshot = await tagsReference.document("brands").collection("brands").getDocuments();


    List<Brand> brands = querySnapshot.documents.map((document) =>Brand.fromDocument(document)).toList();

    print("brands");
    print(brands[0].name);
    setState(() {
      this.brands = brands;
    });
  }

  Widget getImageWidget(Style style) {

    return Container(
      decoration: new BoxDecoration(color: Colors.white),
      height: 240,
      child: Stack(
        children: <Widget>[
          Image.network(style.url),
          Positioned(
              top: 2.5, right: 0, //give the values according to your requirement
              child: GestureDetector(child: Icon(Icons.delete_forever, color: Colors.redAccent,), onTap: ()=>{},)
            //IconButton(icon: Icon(Icons.delete_forever, color: Colors.redAccent,), onPressed: () {  },),
          ),
          Positioned(
              bottom: 0, left: 5, //give the values according to your requirement
              child: textWithStroke(text: style.name, fontSize: 20)
            //IconButton(icon: Icon(Icons.delete_forever, color: Colors.redAccent,), onPressed: () {  },),
          ),

        ],
      ),
    );
  }

  Widget getBrandWidget(Brand brand) {

    return Container(
      child: Padding(
        padding: const EdgeInsets.only(right: 12, left: 12),
        child: Text(brand.name, style: TextStyle(color:  Colors.white , fontWeight: FontWeight.bold),),
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color:  Colors.black,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(6)
      ),
    );
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
