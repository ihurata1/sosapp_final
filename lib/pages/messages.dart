import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosapp/models/message.dart';
import 'package:sosapp/services/authorizationservice.dart';
import 'package:sosapp/services/firestoresevice.dart';

class Messages extends StatefulWidget {
  @override
  final String profileId;

  const Messages({Key key, this.profileId}) : super(key: key);
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  String _activeUserId;
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _activeUserId =
        Provider.of<AuthorizationService>(context, listen: false).activeUserId;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Chat",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: <Widget>[
          _showMessages(),
          _sendMessage(),
        ],
      ),
    );
  }

  _showMessages() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
      stream: FireStoreService().getMessages(_activeUserId, widget.profileId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            Message message =
                Message.dokumandanUret(snapshot.data.documents[index]);
            return Text(message.content);
          },
        );
      },
    ));
  }

  _sendMessage() {
    return ListTile(
      title: TextFormField(
        controller: _messageController,
        decoration: InputDecoration(hintText: "Message here!"),
      ),
      trailing: IconButton(
        icon: Icon(Icons.send),
        onPressed: _addMessage,
      ),
    );
  }

  void _addMessage() {
    FireStoreService().sendMessage(
        activeUserId: _activeUserId,
        profileOwnerId: widget.profileId,
        content: _messageController.text);
  }
}
