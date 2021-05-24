import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosapp/models/Kullanici.dart';
import 'package:sosapp/models/comment.dart';
import 'package:sosapp/models/post.dart';
import 'package:sosapp/services/authorizationservice.dart';
import 'package:sosapp/services/firestoresevice.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final Post post;

  const Comments({Key key, this.post}) : super(key: key);
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  TextEditingController _commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text("Comments", style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: <Widget>[
          _showComments(),
          _addComments(),
        ],
      ),
    );
  }

  _showComments() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FireStoreService().getComments(widget.post.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              Comment comment =
                  Comment.dokumandanUret(snapshot.data.documents[index]);
              return _commentLine(comment);
            },
          );
        },
      ),
    );
  }

  _commentLine(Comment comment) {
    return FutureBuilder<Kullanici>(
        future: FireStoreService().getUser(comment.publisherId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 0.0,
            );
          }

          Kullanici publisher = snapshot.data;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: publisher.fotoUrl == ""
                  ? AssetImage("assets/images/defaultProfilePic.png")
                  : NetworkImage(publisher.fotoUrl),
            ),
            title: RichText(
                text: TextSpan(
                    text: publisher.kullaniciAdi + " ",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                  TextSpan(
                    text: comment.content,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0,
                    ),
                  )
                ])),
            subtitle: Text(
                timeago.format(comment.creationTime.toDate(), locale: "en")),
          );
        });
  }

  _addComments() {
    return ListTile(
      title: TextFormField(
        controller: _commentController,
        decoration: InputDecoration(hintText: "Comment here"),
      ),
      trailing: IconButton(icon: Icon(Icons.send), onPressed: _sendComment),
    );
  }

  void _sendComment() {
    String activeUserId =
        Provider.of<AuthorizationService>(context, listen: false).activeUserId;

    FireStoreService().addComment(
        activeUserId: activeUserId,
        post: widget.post,
        content: _commentController.text);
    _commentController.clear();
  }
}
