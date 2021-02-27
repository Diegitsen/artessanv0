import 'dart:io';

import 'package:artessan_v0/pages/HomePage.dart';
import 'package:artessan_v0/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ImD;

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  TextEditingController usernameTextEditingController = TextEditingController(text: currentUser.username);
  TextEditingController emailTextEditingController = TextEditingController(text: currentUser.email);
  TextEditingController nameTextEditingController = TextEditingController(text: currentUser.profileName);
  TextEditingController bioTextEditingController = TextEditingController(text: currentUser.bio);
  File profilePic;
  String profilePicUrl = "aux";
  bool uploading = false;

  pickImageFromGallery() async{
   // Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );

    setState(() {
      this.profilePic = imageFile;
    });
  }

  compressingPhoto() async{
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(profilePic.readAsBytesSync());
    final compressedImageFile = File('$path/profilepic_${currentUser.id}.jpg')..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 90));
    setState(() {
      profilePic = compressedImageFile;
    });
  }

  controlUploadAndSave() async{
    setState(() {
      uploading = true;
    });

    await compressingPhoto();

    String downloadUrl = await uploadPhoto(profilePic);

    updateUserData(username: usernameTextEditingController.text, email: emailTextEditingController.text,
        profileName: nameTextEditingController.text, bio: bioTextEditingController.text, url: downloadUrl);

    setState(() {
      profilePic = null;
      uploading = false;
    });
  }

  Future<String> uploadPhoto(mImageFile) async{
    StorageUploadTask mStorageUploadTask = storageReference.child("profilepic_${currentUser.id}.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot = await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }


  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text("Editar perfil"),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.check, color: Colors.black),
            onPressed: ()=> controlUploadAndSave(),
          ),
        ],
      ),//heade
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            uploading ? linearProgress() : Text(""),
            Align(
              alignment: Alignment.centerLeft, // Align however you like (i.e .centerRight, centerLeft)
              child:  Text("Detalles del usuario", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.left,),
            ),
            Form(
              child: TextFormField(
                controller: usernameTextEditingController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)
                  ),
                  border: OutlineInputBorder(),
                  labelText: "Username",
                  labelStyle: TextStyle(fontSize: 16),
                  hintText: "Edita tu username",
                ),
              ),
            ),
            Form(
              child: TextFormField(
                controller: emailTextEditingController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)
                  ),
                  border: OutlineInputBorder(),
                  labelText: "Correo electrónico",
                  labelStyle: TextStyle(fontSize: 16),
                  hintText: "Edita tu correo electrónico",
                ),
              ),
            ),
            Form(
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)
                  ),
                  border: OutlineInputBorder(),
                  labelText: "Contraseña",
                  labelStyle: TextStyle(fontSize: 16),
                  hintText: "Edita tu contraseña",
                ),
              ),
            ),
            Divider(color: Colors.white, height: 20,),
            Align(
              alignment: Alignment.centerLeft, // Align however you like (i.e .centerRight, centerLeft)
              child:  Text("Acerca de mi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.left,),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Form(
                        child: TextFormField(
                          controller: nameTextEditingController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            border: OutlineInputBorder(),
                            labelText: "Nombre",
                            labelStyle: TextStyle(fontSize: 16),
                            hintText: "Edita tu nombre",
                          ),
                        ),
                      ),
                      Form(
                        child: TextFormField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            border: OutlineInputBorder(),
                            labelText: "Apellidos",
                            labelStyle: TextStyle(fontSize: 16),
                            hintText: "Edita tus apellidos",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: ()=>pickImageFromGallery(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage:  profilePic == null ? CachedNetworkImageProvider(currentUser.url ?? "") : FileImage(profilePic),
                    ),
                  ),
                )
              ],
            ), // FileImage(file)
            Form(
              child: TextFormField(
                controller: bioTextEditingController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  border: OutlineInputBorder(),
                  labelText: "Bio",
                  labelStyle: TextStyle(fontSize: 16),
                  hintText: "Edita tu biografía",
                ),
              ),
            ),
          ],
        ),
      ),// r(context, strTitle: "Profile"),

    );
  }

  updateUserData({String username, String email, String profileName, String bio, String url}){
    Navigator.pop(context);
    usersReference.document(currentUser.id).updateData({
      "username": username,
      "email": email,
      "profileName": profileName,
      "bio": bio,
      "url": url,
      //"timestamp": timestamp
    });
  }


}

/*
 */