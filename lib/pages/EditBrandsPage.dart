
import 'package:artessan_v0/models/brand.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:uuid/uuid.dart';

import 'HomePage.dart';

class EditBrandsPage extends StatefulWidget {
  @override
  _BagPageState createState() => _BagPageState();
}

class _BagPageState extends State<EditBrandsPage> {


  List<Brand> brands;
  List<Brand> userBrands = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    retrieveBrands();
    //retrieveUserBrands();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text("Marcas"),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),//hea
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text("Esto hace más fácil buscarlos luego", textAlign: TextAlign.center,),
          ),
          Container(
            height: 108,
            color: Colors.grey,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Text("Has escogido 7 marcas"),
                  showBrands()
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              "Sugerido",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
            child: brands != null ? brandTags() : Text(""),
          ),
        ],
      ), // der(context, strTitle: "Profile"),
    );
  }

  brandTags(){

    return Tags(
      alignment: WrapAlignment.start,
      itemCount: brands.length,
      itemBuilder: (int index){
        final brand = brands[index];
        return ItemTags(
          index: index,
          // required
          title: brand.name,
          active: true,
          combine: ItemTagsCombine.withTextBefore,
          icon: ItemTagsIcon(
            icon: Icons.add,
          ),
          onPressed: (item) => updateBrandSelection(brand),
          activeColor: Colors.black,
          color: Colors.white,
        );
      },
    );
  }

  updateBrandSelection(Brand brand) {
    if (brand.isSelected) {
      userTagsReference
          .document(currentUser.id)
          .collection("brands")
          .document(brand.id)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });

      setState(() {
        brand.isSelected = false;
      });
    } else {
      var userBrandId = Uuid().v4();
      userTagsReference
          .document(currentUser.id)
          .collection("brands")
          .document(userBrandId)
          .setData({
            "id": userBrandId,
            "name": brand.name
      });

      setState(() {
        brand.id = userBrandId;
        brand.isSelected = true;
      });
    }
  }

  retrieveBrands() async{

    QuerySnapshot queryBrandsSnapshot = await tagsReference.document("brands").collection("brands").getDocuments();
    brands = queryBrandsSnapshot.documents.map((document) =>Brand.fromDocument(document)).toList();

    QuerySnapshot queryUserBrandsSnapshot = await userTagsReference.document(currentUser.id).collection("brands").getDocuments();
    userBrands = queryUserBrandsSnapshot.documents.map((documentSnapshot) => Brand.fromDocument(documentSnapshot)).toList();

    for(var brand in brands){
      for(var userBrand in userBrands){
        if(brand.name == userBrand.name){
          setState(() {
             brand.id = userBrand.id;
             brand.isSelected = true;
             userBrand.isSelected = true;
          });
        }
      }
    }
    //setState(() {
   //   this.brands = brands;
   // });
    setState(() {
      brands = brands.where(
              (x) => x.isSelected == false
      ).toList();
    });

  }

  retrieveUserBrands() async{

    QuerySnapshot querySnapshot = await userTagsReference.document(currentUser.id).collection("brands").getDocuments();
    userBrands = querySnapshot.documents.map((documentSnapshot) => Brand.fromDocument(documentSnapshot)).toList();
    for(var brand in brands){
      for(var userBrand in userBrands){
        if(brand.name == userBrand.name){
          setState(() {
           // brand.id = userBrand.id;
            brand.isSelected = true;
          });
        }
      }
    }

    brands = brands.where(
            (x) => x.isSelected == false
    ).toList();
  }

  Container showBrands() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 30.0,
        child: new ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            if (userBrands != null)
              for (var brand in userBrands) uploadBrand(brand)
            else
              Text("")//CircularProgressIndicator()
          ],
        ));
  }

  GestureDetector uploadBrand(Brand brand) {
    return GestureDetector(
      onTap: () => updateBrandSelection(brand),
      child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: getBrandWidget(brand)
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

}