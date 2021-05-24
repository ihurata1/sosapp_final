import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sosapp/models/Kullanici.dart';
import 'package:sosapp/services/authorizationservice.dart';
import 'package:sosapp/services/firestoresevice.dart';
import 'package:sosapp/services/storageservice.dart';

class EditProfile extends StatefulWidget {
  final Kullanici profile;

  const EditProfile({Key key, this.profile}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var _formKey = GlobalKey<FormState>();
  String _username;
  String _about;
  File _pickedImage;
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context)),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.black,
              ),
              onPressed: _save),
        ],
      ),
      body: ListView(
        children: <Widget>[
          _loading
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0,
                ),
          _profilePic(),
          _userInfo(),
        ],
      ),
    );
  }

  _save() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _loading = true;
      });
      _formKey.currentState.save();
      String profilePhotoUrl;
      if (_pickedImage == null) {
        profilePhotoUrl = widget.profile.fotoUrl;
      } else {
        profilePhotoUrl = await StorageService().profilePicImage(_pickedImage);
      }
      String activeUserId =
          Provider.of<AuthorizationService>(context, listen: false)
              .activeUserId;
      FireStoreService().updateUser(
          userId: activeUserId,
          username: _username,
          about: _about,
          photoUrl: profilePhotoUrl);

      setState(() {
        _loading = false;
      });
      Navigator.pop(context);
    }
  }

  _profilePic() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
      child: Center(
        child: InkWell(
          onTap: _uploadFromGalery,
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: _pickedImage == null
                ? NetworkImage(widget.profile.fotoUrl)
                : FileImage(_pickedImage),
            radius: 55.0,
          ),
        ),
      ),
    );
  }

  _uploadFromGalery() async {
    //bu fonksiyon upload class'ındaki uploadFromGallery fonksiyonundan koplayandı
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      _pickedImage = File(image.path);
    });
  }

  _userInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            SizedBox(height: 20.0),
            TextFormField(
              initialValue: widget.profile.kullaniciAdi,
              decoration: InputDecoration(labelText: "Username"),
              validator: (input) {
                return input.trim().length <= 3
                    ? "Username must be at least 4 characters"
                    : null;
              },
              onSaved: (input) {
                _username = input;
              },
            ),
            TextFormField(
              initialValue: widget.profile.hakkinda,
              decoration: InputDecoration(labelText: "About"),
              validator: (input) {
                return input.trim().length > 100
                    ? "About must be at most 100 characters"
                    : null;
              },
              onSaved: (input) {
                _about = input;
              },
            ),
          ],
        ),
      ),
    );
  }
}
