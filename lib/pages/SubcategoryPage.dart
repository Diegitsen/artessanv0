import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SubcategoryPage extends StatefulWidget {
  @override
  _SubcategoryPageState createState() => _SubcategoryPageState();
}

class _SubcategoryPageState extends State<SubcategoryPage> {

  var list = ["Cardigan", "Polo", "Polera", "Sueter", "Camisa", "Top", "Otro"];
  String subcategorySelected;

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text("Subcategoría"),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:  ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: ListTile.divideTiles( //          <-- ListTile.divideTiles
            context: context,
            tiles: [
              for(var item in list) ListTile(
                onTap: ()=>{selectCategory(item)},
                title: Text(item),
              ),
            ]
        ).toList(),
      ),
    );
  }

  selectCategory(String category){
    setState(() {
      subcategorySelected = category;
    });
    Navigator.pop(context, subcategorySelected);
  }



}