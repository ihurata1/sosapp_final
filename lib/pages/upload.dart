import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sosapp/assets/my_flutter_app_icons.dart';
import 'package:sosapp/services/authorizationservice.dart';
import 'package:sosapp/services/firestoresevice.dart';
import 'package:sosapp/services/storageservice.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file;
  bool isLoading = false;

  TextEditingController descriptionTextControl = TextEditingController();
  TextEditingController loactionTextControl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return file == null ? uploadButton() : postForm();
  }

  Widget uploadButton() {
    return IconButton(
        icon: Icon(
          MyFlutterApp.sos_logo,
          size: 80.0,
        ),
        onPressed: () {
          photoPicker();
        });
  }

  Widget postForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        //Gönderi oluşturma app bar'ı
        title: Text(
          "Create a Post!",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            setState(() {
              file = null;
            });
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send, color: Colors.black),
            onPressed: _createPost,
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isLoading
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0, /*no effect*/
                ),
          AspectRatio(
            aspectRatio: 16.0 / 9.0,
            child: Image.file(file, fit: BoxFit.cover),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: descriptionTextControl,
            decoration: InputDecoration(
              hintText: "Add description",
              contentPadding: EdgeInsets.only(left: 15.0, right: 15.0),
            ),
          ),
          TextFormField(
            controller: loactionTextControl,
            decoration: InputDecoration(
              hintText: "Add location",
              contentPadding: EdgeInsets.only(left: 15.0, right: 15.0),
            ),
          ),
        ],
      ),
    );
  }

  void _createPost() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      String imageUrl = await StorageService().uploadPostImage(file);
      String activeUserId =
          Provider.of<AuthorizationService>(context, listen: false)
              .activeUserId;

      await FireStoreService().createPost(
          //create post
          picUrl: imageUrl,
          description: descriptionTextControl.text,
          publisherId: activeUserId,
          location: loactionTextControl.text);
    }
    setState(() {
      isLoading = false;
      descriptionTextControl
          .clear(); // açıklama konum alanına girilen bilgileri temizler
      loactionTextControl.clear();
      file = null;
    });
  }

  photoPicker() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create a Post"),
          children: <Widget>[
            SimpleDialogOption(
              child: Text("Take a Photo!"),
              onPressed: () {
                takePhoto();
              },
            ),
            SimpleDialogOption(
              child: Text("Upload from Galery!"),
              onPressed: () {
                uploadFromGalery();
              },
            ),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  takePhoto() async {
    Navigator.pop(context); // diyalog penceresini kapatır
    var image = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      file = File(image.path);
    });
  }

  uploadFromGalery() async {
    Navigator.pop(context); // diyalog penceresini kapatır
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      file = File(image.path);
    });
  }
}
