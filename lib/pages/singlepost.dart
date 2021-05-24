import 'package:flutter/material.dart';
import 'package:sosapp/models/Kullanici.dart';
import 'package:sosapp/models/post.dart';
import 'package:sosapp/services/firestoresevice.dart';
import 'package:sosapp/widgets/postcart.dart';

class SinglePost extends StatefulWidget {
  final String postId;
  final String postOwnerId;

  const SinglePost({Key key, this.postId, this.postOwnerId}) : super(key: key);

  @override
  _SinglePostState createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  Post _post;
  Kullanici _postOwner;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    getPost();
  }

  getPost() async {
    Post post = await FireStoreService()
        .getSinglePost(widget.postId, widget.postOwnerId);
    if (post != null) {
      Kullanici postOwner = await FireStoreService().getUser(post.publisherId);
      setState(() {
        _post = post;
        _postOwner = postOwner;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Post",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: !_loading
          ? PostCart(
              post: _post,
              user: _postOwner,
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
