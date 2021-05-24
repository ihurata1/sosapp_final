import 'dart:io';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  StorageReference _storage = FirebaseStorage.instance.ref();
  String picId;
  Future<String> uploadPostImage(File imageFile) async {
    picId = Uuid().v4();
    StorageUploadTask storageUploadTask =
        _storage.child("images/posts/post_$picId.jpg").putFile(imageFile);
    StorageTaskSnapshot snapshot = await storageUploadTask.onComplete;
    String uploadedPicUrl = await snapshot.ref.getDownloadURL();
    return uploadedPicUrl;
  }

  Future<String> profilePicImage(File imageFile) async {
    picId = Uuid().v4();
    StorageUploadTask storageUploadTask =
        _storage.child("images/profile/profile_$picId.jpg").putFile(imageFile);
    StorageTaskSnapshot snapshot = await storageUploadTask.onComplete;
    String uploadedPicUrl = await snapshot.ref.getDownloadURL();
    return uploadedPicUrl;
  }

  deletePostPic(String postPicUrl) {
    RegExp search = RegExp(r"post_.+\.jpg");
    var match = search.firstMatch(postPicUrl);
    String fileName = match[0];

    if (fileName != null) {
      _storage.child("images/posts/$fileName").delete();
    }
  }
}
