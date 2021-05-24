import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String content;
  final String publisherId;
  final Timestamp creationTime;

  Comment({this.id, this.content, this.publisherId, this.creationTime});
  factory Comment.dokumandanUret(DocumentSnapshot doc) {
    return Comment(
      id: doc.documentID,
      content: doc['content'],
      publisherId: doc['publisherId'],
      creationTime: doc['creationTime'],
    );
  }
}
