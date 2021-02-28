import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

  var list = ["Vintage", "Oversize", "Gucci", "Retro", "80s", "Segunda", "Reinvento"];
  String categorySelected;

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text("Categoría"),
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
      categorySelected = category;
    });
    Navigator.pop(context, categorySelected);
  }



}