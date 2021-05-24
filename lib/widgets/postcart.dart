import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosapp/models/Kullanici.dart';
import 'package:sosapp/models/post.dart';
import 'package:sosapp/pages/comments.dart';
import 'package:sosapp/pages/profile.dart';
import 'package:sosapp/services/authorizationservice.dart';
import 'package:sosapp/services/firestoresevice.dart';

class PostCart extends StatefulWidget {
  @override
  final Post post;
  final Kullanici user;

  const PostCart({Key key, this.post, this.user}) : super(key: key);
  _PostCartState createState() => _PostCartState();
}

class _PostCartState extends State<PostCart> {
  int _likeScore = 0;
  bool _isLiked = false;
  String _activeUserId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _activeUserId =
        Provider.of<AuthorizationService>(context, listen: false).activeUserId;
    _likeScore = widget.post.likeNumber;
    isLikeExists();
  }

  isLikeExists() async {
    bool isLikeExists =
        await FireStoreService().isLikeExists(widget.post, _activeUserId);
    if (isLikeExists) {
      if (mounted) {
        setState(() {
          _isLiked = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: <Widget>[
          _postTitle(),
          _postPic(),
          _bottomPost(),
        ],
      ),
    );
  }

  postOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Delete Post"),
                onPressed: () {
                  FireStoreService().deletePost(
                      activeUserId: _activeUserId, post: widget.post);
                },
              ),
              SimpleDialogOption(
                child: Text("Cancel", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Widget _postTitle() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profile(
                          profilId: widget.post.publisherId,
                        ))); //akıştaki gönderi üzerindeki profil resmine tıkladığında yayınlayan kullanıcının profile atar
          },
          child: CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage: widget.user.fotoUrl.isNotEmpty
                ? NetworkImage(widget.user.fotoUrl)
                : AssetImage("assets/images/defaultProfilePic.png"),
          ),
        ),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Profile(
                        profilId: widget.post.publisherId,
                      ))); //akıştaki gönderi üzerindeki profil resmine tıkladığında yayınlayan kullanıcının profile atar
        },
        child: Text(widget.user.kullaniciAdi,
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
      ),
      trailing: _activeUserId == widget.post.publisherId
          ? IconButton(
              icon: Icon(Icons.more_vert), onPressed: () => postOptions())
          : null,
      contentPadding: EdgeInsets.all(0.0),
    );
  }

  Widget _postPic() {
    return GestureDetector(
      onDoubleTap: _changeLike,
      child: Image.network(
        widget.post.postPicUrl,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _bottomPost() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: !_isLiked
                  ? Icon(Icons.favorite_border, size: 30.0)
                  : Icon(
                      Icons.favorite,
                      size: 25.0,
                      color: Colors.red,
                    ),
              onPressed: _changeLike,
            ),
            IconButton(
                icon: Icon(Icons.comment, size: 30.0),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Comments(
                                post: widget.post,
                              ))); // yorumlar sayfasına gönderir
                }),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text("$_likeScore Likes",
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 2.0),
        widget.post.description.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: RichText(
                    text: TextSpan(
                        text: widget.user.kullaniciAdi + " ",
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        children: [
                      TextSpan(
                        text: widget.post.description,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14.0,
                        ),
                      )
                    ])),
              )
            : SizedBox(height: 0.0)
      ],
    );
  }

  void _changeLike() {
    if (_isLiked) {
      //liked
      setState(() {
        _isLiked = false;
        _likeScore = _likeScore - 1;
      });
      FireStoreService().unlikePost(widget.post, _activeUserId);
    } else {
      //"not liked"
      setState(() {
        _isLiked = true;
        _likeScore = _likeScore + 1;
      });
      FireStoreService().likePost(widget.post, _activeUserId);
    }
  }
}
