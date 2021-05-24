import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String content;
  final Timestamp creationTime;
  Message({this.id, this.content, this.creationTime});
  factory Message.dokumandanUret(DocumentSnapshot doc) {
    return Message(
      id: doc.documentID,
      content: doc['content'],
      creationTime: doc['creationTime'],
    );
  }
}
