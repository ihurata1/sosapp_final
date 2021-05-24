import 'package:cloud_firestore/cloud_firestore.dart';

class Notificationn {
  final String id;
  final String activatorId;
  final String activateType;
  final String postId;
  final String postPic;
  final String comment;
  final Timestamp creationTime;

  Notificationn(
      {this.id,
      this.activatorId,
      this.activateType,
      this.postId,
      this.postPic,
      this.comment,
      this.creationTime});

  factory Notificationn.dokumandanUret(DocumentSnapshot doc) {
    return Notificationn(
      id: doc.documentID,
      activatorId: doc['activatorId'],
      activateType: doc['activateType'],
      postId: doc['postId'],
      postPic: doc['postPic'],
      comment: doc['comment'],
      creationTime: doc['creationTime'],
    );
  }
}
