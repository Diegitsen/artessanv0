import 'package:flutter/material.dart';

AppBar header(context, {bool isAppTitle = false, String strTitle, disappearedBackButton=true}) {
  return AppBar(
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    leading: IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () =>  Navigator.of(context, rootNavigator: true).pop(context)
    ),
    title: Text(
      isAppTitle ? "Artessan" : strTitle,
      style: TextStyle(
        color: Colors.black,
        //fontFamily: isAppTitle ? "Signatra" : "",
        fontSize: isAppTitle ? 45 : 22,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
