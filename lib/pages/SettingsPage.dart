
import 'package:artessan_v0/pages/EditProfilePage.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  var list = ["one", "two", "three", "four"];


  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text("Configuración"),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),//header(context, strTitle: "Profile"),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 15),
            child: Align(
              alignment: Alignment.centerLeft, // Align however you like (i.e .centerRight, centerLeft)
              child:  Text("Mi cuenta", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.left,),
            ),
          ),
          ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: ListTile.divideTiles( //          <-- ListTile.divideTiles
                context: context,
                tiles: [
                  ListTile(
                    onTap: () => goToEditUser(context),//goToEditUser(context),
                    title: Text('Editar perfil'),
                  ),
                  ListTile(
                    title: Text('Intereses y tamaños'),
                  ),
                ]
            ).toList(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 15),
            child: Align(
              alignment: Alignment.centerLeft, // Align however you like (i.e .centerRight, centerLeft)
              child:  Text("Vender", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.left,),
            ),
          ),
          ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: ListTile.divideTiles( //          <-- ListTile.divideTiles
                context: context,
                tiles: [
                  ListTile(
                    onTap: ()=>{print("asd")},
                    title: Text('Cuenta Yape'),
                  ),
                  ListTile(
                    title: Text('Cuenta Tunki'),
                  ),
                  ListTile(
                    title: Text('Cuenta Paypal'),
                  ),
                  ListTile(
                    title: Text('Políticas de venta'),
                  ),
                ]
            ).toList(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 15),
            child: Align(
              alignment: Alignment.centerLeft, // Align however you like (i.e .centerRight, centerLeft)
              child:  Text("Redes sociales", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.left,),
            ),
          ),
          ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: ListTile.divideTiles( //          <-- ListTile.divideTiles
                context: context,
                tiles: [
                  ListTile(
                    onTap: ()=>{print("asd")},
                    title: Text('Facebook'),
                  ),
                  ListTile(
                    title: Text('Instagram'),
                  ),
                ]
            ).toList(),
          )
        ],
      )
    );
  }


  ListTile createItemAndFunction({String title, Function performFunction}){
    return ListTile(
      onTap: performFunction,
      title: Text('Horse'),
    );
  }

  goToEditUser(BuildContext context) async {
    await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation1, animation2){
          return FadeTransition(
            opacity: animation1,
            child: EditProfilePage(),);
        }));
  }



}