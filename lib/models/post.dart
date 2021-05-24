import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String postPicUrl;
  final String description;
  final String publisherId;
  final int likeNumber;
  final String location;

  Post(
      {this.id,
      this.postPicUrl,
      this.description,
      this.publisherId,
      this.likeNumber,
      this.location});

  factory Post.dokumandanUret(DocumentSnapshot doc) {
    return Post(
      id: doc.documentID,
      postPicUrl: doc['postPicUrl'],
      description: doc['description'],
      publisherId: doc['publisherId'],
      likeNumber: doc['likeNumber'],
      location: doc['location'],
    );
  }
}
