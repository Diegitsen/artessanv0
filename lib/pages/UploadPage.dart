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

  File filesito;
  File file1;
  File file2;
  File file3;
  File file4;
  bool uploading = false;
  String postId = Uuid().v4();
  TextEditingController locationTextEditingController = TextEditingController();
  TextEditingController descriptionTextEditingController = TextEditingController();
  TextEditingController priceTextEditingController = TextEditingController();
  int _conditionValue = -1;
  int _deliveryWayValue = -1;
  int _paymentWayValue = -1;
  String conditionWay = "Seleccionar +";
  String deliveryWay = "Seleccionar +";
  String paymentWay = "Seleccionar +";
  String categorySelected = "Selecciona una categoría";
  String subcategorySelected = "Selecciona una subcategoría";
  bool aux = false;

  captureImageWithCamera(int index) async{
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
      switch(index){
        case 1:
          file1 = croppedFile;
          break;
        case 2:
          file2 = croppedFile;
          break;
        case 3:
          file3 = croppedFile;
          break;
        case 4:
          file4 = croppedFile;
          break;
      }
    });
  }

  pickImageFromGallery(int index) async{
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
      switch(index){
        case 1:
          file1 = croppedFile;
          break;
        case 2:
          file2 = croppedFile;
          break;
        case 3:
          file3 = croppedFile;
          break;
        case 4:
          file4 = croppedFile;
          break;
      }
    });
  }

  takeImage(mContext, int index){
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
                onPressed: () => captureImageWithCamera(index),
              ),
              CupertinoDialogAction(
                child: Text("Selecciona una foto", style: TextStyle(color: Colors.black, ),),
                onPressed: () =>  pickImageFromGallery(index),
              ),
              CupertinoDialogAction(
                child: Text("Cancelar", style: TextStyle(color: Colors.black, ),),
                onPressed: () =>  pickImageFromGallery(index),
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
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  uploading ? linearProgress() : Text(""),
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
                                  controller: priceTextEditingController,
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
                    onTap: ()=>onDeliveryWayModal() ,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Forma de entrega",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Text(
                            deliveryWay,
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  GestureDetector(
                    onTap: ()=>onPaymentWayModal() ,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Forma de pago",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Text(
                            paymentWay,
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: Colors.white,),
                ],
              )
            ),
            Container(
              height: 40,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      onPressed: uploading ? null : ()=>savePostInfoToFireStore2(),
                      child: Text(
                        "Guardar",
                        style: TextStyle(color: Colors.black),
                      ),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(color: Colors.black)),
                    ),
                  ),
                  VerticalDivider(color: Colors.white,),
                  Expanded(
                    child: RaisedButton(
                      onPressed:  uploading ? null : ()=>controlUploadAndSave(),
                      child: Text(
                        "Publicar", style: TextStyle(color: Colors.white),),
                      color: Colors.black,
                    ),
                  )
                ],
              ),
            )
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
            uploadPicFrame(1),
            uploadPicFrame(2),
            uploadPicFrame(3),
            uploadPicFrame(4)
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
                setState(() => _conditionValue = newValue),
                Navigator.of(context).pop(),
                conditionWay = "Nueva"
              },
              cValue: _conditionValue
            ),
            _myRadioButton(
              title: "Como nueva",
              value: 1,
              onChanged: (newValue) => {
                setState(() => _conditionValue = newValue),
                Navigator.of(context).pop(),
                conditionWay = "Como nueva"
              },
                cValue: _conditionValue
            ),
            _myRadioButton(
              title: "Usado - Excelente",
              value: 2,
              onChanged: (newValue) => {
                setState(() => _conditionValue = newValue),
                Navigator.of(context).pop(),
                conditionWay = "Como nueva"
              },
                cValue: _conditionValue
            ),
            _myRadioButton(
              title: "Usado - Buen estado",
              value: 3,
              onChanged: (newValue) => {
                setState(() => _conditionValue = newValue),
                Navigator.of(context).pop(),
                conditionWay = "Usado - Buen estado"
              },
                cValue: _conditionValue
            ),
            _myRadioButton(
              title: "Usado - Justo",
              value: 4,
              onChanged: (newValue) => {
                setState(() => _conditionValue = newValue),
                Navigator.of(context).pop(),
                conditionWay = "Usado - Justo"
              },
                cValue: _conditionValue
            ),
          ],
        ),
      );
    });
  }

  void onDeliveryWayModal() {
    showModalBottomSheet(context: context, builder: (context) {
      return Container(
        height: 250,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Align(
                alignment: Alignment.centerLeft, // Align however you like (i.e .centerRight, centerLeft)
                child:  Text("Forma de entrega", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.left,),
              ),
            ),
            _myRadioButton(
              title: "Delivery",
              value: 0,
              onChanged: (newValue) => {
                setState(() => _deliveryWayValue = newValue),
                Navigator.of(context).pop(),
                deliveryWay = "Delivery"
              },
                cValue: _deliveryWayValue
            ),
            _myRadioButton(
              title: "Recojo",
              value: 1,
              onChanged: (newValue) => {
                setState(() => _deliveryWayValue = newValue),
                Navigator.of(context).pop(),
                deliveryWay = "Recojo"
              },
                cValue: _deliveryWayValue
            ),
            _myRadioButton(
                title: "Delivery y recojo",
                value: 2,
                onChanged: (newValue) => {
                  setState(() => _deliveryWayValue = newValue),
                  Navigator.of(context).pop(),
                  deliveryWay = "Delivery y recojo"
                },
                cValue: _deliveryWayValue
            ),
          ],
        ),
      );
    });
  }

  void onPaymentWayModal() {
    showModalBottomSheet(context: context, builder: (context) {
      return Container(
        height: 200,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Align(
                alignment: Alignment.centerLeft, // Align however you like (i.e .centerRight, centerLeft)
                child:  Text("Forma de pago", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.left,),
              ),
            ),
            _myRadioButton(
                title: "Yape",
                value: 0,
                onChanged: (newValue) => {
                  setState(() => _paymentWayValue = newValue),
                  Navigator.of(context).pop(),
                  paymentWay = "Yape"
                },
                cValue: _paymentWayValue
            ),
            _myRadioButton(
                title: "Plin",
                value: 1,
                onChanged: (newValue) => {
                  setState(() => _paymentWayValue = newValue),
                  Navigator.of(context).pop(),
                  paymentWay = "Plin"
                },
                cValue: _paymentWayValue
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

  Widget _myRadioButton({String title, int value, Function onChanged, int cValue}) {
    return RadioListTile(
      value: value,
      groupValue: cValue,
      onChanged: onChanged,
      title: Text(title),
      activeColor: Colors.black,
    );
  }

  GestureDetector uploadPicFrame(int index) {
    return GestureDetector(
      onTap: () => {takeImage(context, index)},
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: getImageWidget(index)
      ),
    );
  }

  /*

  file1 == null
            ? Container(
                width: 100.0,
                color: Colors.black12,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[Icon(Icons.camera_alt_outlined)],
                ),
              )
            : Container(
          width: 100.0,
          color: Colors.redAccent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[Icon(Icons.camera_alt_outlined)],
          ),
        )

   */
  
  void deleteFile(File f){
    setState(() {
      f = null;
    });
  }

  Widget getImageWidget(int index) {
    File f;

    switch(index){
      case 1:
        f = file1;
        break;
      case 2:
        f = file2;
        break;
      case 3:
        f = file3;
        break;
      case 4:
        f = file4;
        break;
    }

    if (f != null) {
      return Container(
        decoration: new BoxDecoration(color: Colors.white),
        height: 240,
        child: Stack(
          children: <Widget>[
            Image.file(f,fit: BoxFit.cover),
            Positioned(
              top: 2.5, right: 0, //give the values according to your requirement
              child: GestureDetector(child: Icon(Icons.delete_forever, color: Colors.redAccent,), onTap: ()=>deleteFile(f),)
              //IconButton(icon: Icon(Icons.delete_forever, color: Colors.redAccent,), onPressed: () {  },),
            ),
          ],
        ),
      );
      /*return Image.file(
        f,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );*/
    } else {
      return Container(
        width: 100.0,
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[Icon(Icons.camera_alt_outlined)],
        ),
      );
    }
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
      filesito = null;
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

  compressingPhoto(int index) async{
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;

    ImD.Image mImageFile;

    switch(index){
      case 1:
        mImageFile = ImD.decodeImage(file1.readAsBytesSync());
        break;
      case 2:
        mImageFile = ImD.decodeImage(file2.readAsBytesSync());
        break;
      case 3:
        mImageFile = ImD.decodeImage(file3.readAsBytesSync());
        break;
      case 4:
        mImageFile = ImD.decodeImage(file4.readAsBytesSync());
        break;
    }

    final compressedImageFile = File('$path/img_$postId$index.jpg')..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 90));
    setState(() {

      switch(index){
        case 1:
          file1 = compressedImageFile;
          break;
        case 2:
          file2 = compressedImageFile;
          break;
        case 3:
          file3 = compressedImageFile;
          break;
        case 4:
          file4 = compressedImageFile;
          break;
      }

    });
  }

  controlUploadAndSave() async{
    setState(() {
      uploading = true;
    });

    var arrayFiles = [];

    if(file1 != null){
      arrayFiles.add(1);
    }
    if(file2 != null){
      arrayFiles.add(2);
    }
    if(file3 != null){
      arrayFiles.add(3);
    }
    if(file4 != null){
      arrayFiles.add(4);
    }
    List<String> arrayPics = [];

    for (var item in arrayFiles){
      await compressingPhoto(item);

      String downloadUrl = await uploadPhoto(item);

      arrayPics.add(downloadUrl);
    }


    savePostInfoToFireStore(pics: arrayPics, location: locationTextEditingController.text, description: descriptionTextEditingController.text, category: categorySelected,
        subcategory: subcategorySelected, condition: conditionWay, price: priceTextEditingController.text, deliveryWay: deliveryWay, payment: paymentWay);


    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    priceTextEditingController.clear();

    setState(() {
      file1 = null;
      file2 = null;
      file3 = null;
      file4 = null;
      uploading = false;
      postId = Uuid().v4();
    });
  }

  Future<String> uploadPhoto(int index) async{
    File mImageFile;

    switch(index){
      case 1:
        mImageFile = file1;
        break;
      case 2:
        mImageFile = file2;
        break;
      case 3:
        mImageFile = file3;
        break;
      case 4:
        mImageFile = file4;
        break;
    }

    StorageUploadTask mStorageUploadTask = storageReference.child("post_$postId$index.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot = await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  savePostInfoToFireStore({List<String> pics, String location, String description, String category, String subcategory, String condition, String price, String deliveryWay, String payment}){
    postsReference.document(widget.gCurrentUser.id).collection("usersPosts").document(postId).setData({
      "postId": postId,
      "ownerId": widget.gCurrentUser.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": widget.gCurrentUser.username ?? "no@user",
      "description": description,
      "location": location,
      "pics": pics,
      "category": category,
      "subcategory": subcategory,
      "condition": condition,
      "price": price,
      "deliveryWay": deliveryWay,
      "payment": payment
    });
    //{"likes.$currentOnlineUserId":false}
  }

  savePostInfoToFireStore2({String url, String location, String description, String category, String subcategory, String condition, String price, String deliveryWay, String payment}){
    var list = ['1', '2', '3'];
    postsReference.document(widget.gCurrentUser.id).collection("usersPosts").document(postId).setData({
      "postId": "123",
      "ownerId": widget.gCurrentUser.id,
      "timestamp": DateTime.now(),
      "likes":list,
      "username": "no@user",
      "description": "asd",
      "location": "asd",
      "url":"asd",
      "category": "asd",
      "subcategory": "asd",
      "condition": "asd",
      "price": "asd",
      "deliveryWay": "asd",
      "payment": "asd",
    });

    //{"likes.$currentOnlineUserId":false}
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
                  decoration: BoxDecoration(image: DecorationImage(image: FileImage(filesito), fit: BoxFit.cover)),
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
    return displayUploadScreen();//file1 == null ? displayUploadScreen() : displayUploadFormScreen();
  }
}
