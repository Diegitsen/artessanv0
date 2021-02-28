import 'dart:io';

import 'package:artessan_v0/models/user.dart';
import 'package:artessan_v0/pages/CategoryPage.dart';
import 'package:artessan_v0/pages/SubcategoryPage.dart';
import 'package:artessan_v0/widgets/HeaderWidget.dart';
import 'package:artessan_v0/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;
import 'package:flutter/cupertino.dart';

import 'HomePage.dart';

class UploadPage extends StatefulWidget {

  final User gCurrentUser;
  UploadPage({this.gCurrentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {

  File file;
  bool uploading = false;
  String postId = Uuid().v4();
  TextEditingController locationTextEditingController = TextEditingController();
  TextEditingController descriptionTextEditingController = TextEditingController();
  int _groupValue = -1;
  String conditionWay = "Seleccionar +";
  String categorySelected = "Selecciona una categoría";
  String subcategorySelected = "Selecciona una subcategoría";
  bool aux = false;

  captureImageWithCamera() async{
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxHeight: 680,
        maxWidth: 970
    );

    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Recortar foto',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
        maxHeight: 512,
        maxWidth: 512,
       aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1)

    );

    setState(() {
      this.file = croppedFile;
    });
  }

  pickImageFromGallery() async{
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );

    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );

    setState(() {
      this.file = croppedFile;
    });
  }

  takeImage(mContext){
    return showDialog(
        context: mContext,
        builder: (context){
          return CupertinoAlertDialog(
            title: Text("Sube una imagen para subir tu publicación", style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
            ),),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("Toma una foto", style: TextStyle(color: Colors.black, ),),
                onPressed: captureImageWithCamera,
              ),
              CupertinoDialogAction(
                child: Text("Selecciona una foto", style: TextStyle(color: Colors.black, ),),
                onPressed: pickImageFromGallery,
              ),
              CupertinoDialogAction(
                child: Text("Cancelar", style: TextStyle(color: Colors.black, ),),
                onPressed: pickImageFromGallery,
              ),
            ],
          );
        }
    );
  }

  displayUploadScreen(){
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Divider(),
                  showPicsFrame(),
                  Align(
                    alignment: Alignment.centerLeft, // Align however you like (i.e .centerRight, centerLeft)
                    child:  Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23), textAlign: TextAlign.left,),
                  ),
                  TextField(
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 700,
                    maxLengthEnforced: true,
                    style: TextStyle(color: Colors.black),
                    controller: descriptionTextEditingController,
                    decoration: InputDecoration(
                      hintText: "Cuentanos acerca de tu producto. Añade información extra acerca de su condición, talla o estilo",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft, // Align however you like (i.e .centerRight, centerLeft)
                    child:  Text("Info", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23), textAlign: TextAlign.left,),
                  ),
                  Divider(color: Colors.white,),
                  GestureDetector(
                    onTap: ()=>onUbicationModal(),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Ubicación",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Text(
                            locationTextEditingController.text == "" ? "Agregue su ubicación" : locationTextEditingController.text,
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  GestureDetector(
                    onTap: ()=>goToCategory(context),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Categoría",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Text(
                            categorySelected,
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  GestureDetector(
                    onTap: ()=>goToSubcategory(context),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Subcategoría",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Text(
                            subcategorySelected,
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  GestureDetector(
                    onTap: ()=>onConditionModal() ,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Condición",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Text(
                            conditionWay,
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            "Precio",
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                        Container(
                          width: 80,
                          child: Row(
                            children: [
                              Text("S/"),
                              VerticalDivider(color: Colors.white,),
                              Flexible(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: "",
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(),
                  Divider(color: Colors.white,),
                  Align(
                    alignment: Alignment.centerLeft, // Align however you like (i.e .centerRight, centerLeft)
                    child:  Text("Mejore su publicación", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23), textAlign: TextAlign.left,),
                  ),
                  Divider(color: Colors.white,),
                  Align(
                    alignment: Alignment.centerLeft, // Align however you like (i.e .centerRight, centerLeft)
                    child:  Text("Ayude a los compradores a encontrar su producto taggeando con detalles extras :)", style: TextStyle(fontSize: 16), textAlign: TextAlign.left,),
                  ),
                  Divider(color: Colors.white,),
                  Align(
                    alignment: Alignment.centerLeft, // Align however you like (i.e .centerRight, centerLeft)
                    child:  Text("Entrega del producto", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23), textAlign: TextAlign.left,),
                  ),
                  Divider(color: Colors.white,),
                  GestureDetector(
                    onTap: ()=>{print("asd")},
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Precio",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Text(
                            "S/",
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  Container showPicsFrame() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 100.0,
        child: new ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            uploadPicFrame(),
            uploadPicFrame(),
            uploadPicFrame(),
            uploadPicFrame()
          ],
        ));
  }



  void onConditionModal() {
    showModalBottomSheet(context: context, builder: (context) {
      return Container(
        height: 360,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Align(
                alignment: Alignment.centerLeft, // Align however you like (i.e .centerRight, centerLeft)
                child:  Text("Condición", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.left,),
              ),
            ),
            _myRadioButton(
              title: "Nueva",
              value: 0,
              onChanged: (newValue) => {
                setState(() => _groupValue = newValue),
                Navigator.of(context).pop(),
                conditionWay = "Nueva"
              },
            ),
            _myRadioButton(
              title: "Como nueva",
              value: 1,
              onChanged: (newValue) => {
                setState(() => _groupValue = newValue),
                Navigator.of(context).pop(),
                conditionWay = "Como nueva"
              },
            ),
            _myRadioButton(
              title: "Usado - Excelente",
              value: 2,
              onChanged: (newValue) => {
                setState(() => _groupValue = newValue),
                Navigator.of(context).pop(),
                conditionWay = "Como nueva"
              },
            ),
            _myRadioButton(
              title: "Usado - Buen estado",
              value: 3,
              onChanged: (newValue) => {
                setState(() => _groupValue = newValue),
                Navigator.of(context).pop(),
                conditionWay = "Usado - Buen estado"
              },
            ),
            _myRadioButton(
              title: "Usado - Justo",
              value: 4,
              onChanged: (newValue) => {
                setState(() => _groupValue = newValue),
                Navigator.of(context).pop(),
                conditionWay = "Usado - Justo"
              },
            ),
          ],
        ),
      );
    });
  }

  void onUbicationModal() {
    showModalBottomSheet(context: context, builder: (context) {
      return Container(
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft, // Align however you like (i.e .centerRight, centerLeft)
                child:  Text("Ubicación", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.left,),
              ),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                        maxLengthEnforced: true,
                        style: TextStyle(color: Colors.black),
                        controller: locationTextEditingController,
                        decoration: InputDecoration(
                          hintText: "Ingrese su ubicación",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      )
                  ),
                  IconButton(
                    icon: Icon(Icons.my_location),
                    iconSize: 30,
                    onPressed: gUserCurrentLocation,
                  )
                ],
              ),
              Divider(color: Colors.white,),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: RaisedButton(
                  child: Text("Aceptar", style: TextStyle(color: Colors.white),),
                  color: Colors.black,
                  onPressed: ()=>Navigator.of(context).pop(),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  goToCategory2(BuildContext context) async {


    await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation1, animation2){
          return FadeTransition(
            opacity: animation1,
            child: CategoryPage(),);
        }));
  }

  goToCategory(BuildContext context) async {
    final category = await Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryPage()));
    setState(() {
      categorySelected = category;
    });
  }

  goToSubcategory(BuildContext context) async {
    final subcategory = await Navigator.push(context, MaterialPageRoute(builder: (context) => SubcategoryPage()));
    setState(() {
      subcategorySelected = subcategory;
    });
  }

  Widget _myRadioButton({String title, int value, Function onChanged}) {
    return RadioListTile(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
      title: Text(title),
      activeColor: Colors.black,
    );
  }

  GestureDetector uploadPicFrame() {
    return GestureDetector(
      onTap: ()=>{takeImage(context)},
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          width: 100.0,
          color: Colors.black12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(Icons.camera_alt_outlined)
            ],
          ),
        ),
      ),
    );
  }

  /*

  Icon(Icons.add_photo_alternate, color: Colors.grey, size: 80,),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              child: Text("Subir imagen", style: TextStyle(color: Colors.white, fontSize: 20),),
              color: Colors.green,
              onPressed: () => takeImage(context),
            ),
          )


   */

  clearPostInfo(){

    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    setState(() {
      file = null;
    });

  }

  gUserCurrentLocation() async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mPlacemark = placeMarks[0];
    String completeAddressInfo = '${mPlacemark.subThoroughfare}, ${mPlacemark.thoroughfare}, ${mPlacemark.subLocality}, ${mPlacemark.locality}, ${mPlacemark.subAdministrativeArea} ${mPlacemark.administrativeArea}, ${mPlacemark.postalCode} ${mPlacemark.country}';
    String specificAddress = '${mPlacemark.locality}, ${mPlacemark.country}';
    locationTextEditingController.text = specificAddress;
  }

  compressingPhoto() async{
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 90));
    setState(() {
      file = compressedImageFile;
    });
  }

  controlUploadAndSave() async{
    setState(() {
      uploading = true;
    });

    await compressingPhoto();

    String downloadUrl = await uploadPhoto(file);

    savePostInfoToFireStore(url: downloadUrl, location: locationTextEditingController.text, description: descriptionTextEditingController.text);

    locationTextEditingController.clear();
    descriptionTextEditingController.clear();

    setState(() {
      file = null;
      uploading = false;
      postId = Uuid().v4();
    });
  }

  Future<String> uploadPhoto(mImageFile) async{
    StorageUploadTask mStorageUploadTask = storageReference.child("post_$postId.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot = await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  savePostInfoToFireStore({String url, String location, String description}){
    postsReference.document(widget.gCurrentUser.id).collection("usersPosts").document(postId).setData({
      "postId": postId,
      "ownerId": widget.gCurrentUser.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": widget.gCurrentUser.username ?? "godi",
      "description": description,
      "location": location,
      "url": url
    });
  }

  displayUploadFormScreen(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: clearPostInfo,),
        title: Text("Nueva publicación", style: TextStyle(fontSize: 24, color: Colors.white,
            fontWeight: FontWeight.bold),),
        actions: <Widget>[
          FlatButton(
            onPressed: uploading ? null : ()=>controlUploadAndSave(),
            child: Text("Subir :3", style: TextStyle(color: Colors.lightGreenAccent),),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          uploading ? linearProgress() : Text(""),
          Container(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.0,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(image: DecorationImage(image: FileImage(file), fit: BoxFit.cover)),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 12)),
          ListTile(
            // CachedNetworkImageProvider("https://lh3.googleusercontent.com/a-/AOh14GgA5UD6H1AthKJQkRA82gCAJFqNRScSyxACAB3rgA=s96-c")),
          // (widget.gCurrentUser.url == null) ? CachedNetworkImageProvider("https://lh3.googleusercontent.com/a-/AOh14GgA5UD6H1AthKJQkRA82gCAJFqNRScSyxACAB3rgA=s96-c") : CachedNetworkImageProvider(widget.gCurrentUser.url),),
            leading: CircleAvatar(backgroundImage: (widget.gCurrentUser.url == null) ? CachedNetworkImageProvider("") : CachedNetworkImageProvider(widget.gCurrentUser.url),),
            title: Container(
              width: 250,
              child: TextField(
                style: TextStyle(color: Colors.black),
                controller: descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: "Say something about the image",
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person_pin_circle, color: Colors.black, size: 36,),
            title: Container(
              width: 250,
              child: TextField(
                style: TextStyle(color: Colors.black),
                controller: locationTextEditingController,
                decoration: InputDecoration(
                  hintText: "Write the location here",
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 220,
            height: 110,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: gUserCurrentLocation,
              icon: Icon(Icons.location_on, color: Colors.white,),
              label: Text("Get my current location", style: TextStyle(color: Colors.white),),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void showAlertDialog(BuildContext context) {

    showDialog(
        context: context,
        child:  CupertinoAlertDialog(
          title: Text("Log out?"),
          content: Text( "Are you sure you want to log out?"),
          actions: <Widget>[
            CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Cancel")
            ),
            CupertinoDialogAction(
                textStyle: TextStyle(color: Colors.red),
                isDefaultAction: true,
               /* onPressed: () async {
                  Navigator.pop(context);
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.remove('isLogin');
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (BuildContext ctx) => LoginScreen()));
                },*/
                child: Text("Log out")
            ),
          ],
        ));
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(context) {
    return file == null ? displayUploadScreen() : displayUploadFormScreen();
  }
}
