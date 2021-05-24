import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosapp/models/Kullanici.dart';
import 'package:sosapp/models/post.dart';
import 'package:sosapp/pages/editProfile.dart';
import 'package:sosapp/pages/flowpage.dart';
import 'package:sosapp/services/authorizationservice.dart';
import 'package:sosapp/services/firestoresevice.dart';
import 'package:sosapp/widgets/postcart.dart';

import 'messages.dart';

class Profile extends StatefulWidget {
  final String profilId;

  const Profile({Key key, this.profilId}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _postNum = 0;
  int _followerNum = 0;
  int _followedNum = 0;
  List<Post> _posts = [];
  String postStyle = "list";
  String _activeUserId;
  Kullanici _profileOwner;
  bool _followed = false;

  _getFollowerNumber() async {
    // Kullanıcının takipçilerinin sayısını getirir
    int followerNumber =
        await FireStoreService().followerNumber(widget.profilId);
    if (mounted) {
      setState(() {
        _followerNum = followerNumber;
      });
    }
  }

  _getPosts() async {
    List<Post> posts = await FireStoreService().getPosts(widget.profilId);
    if (mounted) {
      setState(() {
        _posts = posts;
        _postNum = posts.length;
      });
    }
  }

  _getFollowedNumber() async {
    // Kullanıcının takip ettiklerinin sayısını getirir
    int followedNumber =
        await FireStoreService().followedNumber(widget.profilId);
    if (mounted) {
      setState(() {
        _followedNum = followedNumber;
      });
    }
  }

  _followCheck() async {
    bool isThereAFollow = await FireStoreService().followCheck(
        profileOwnerId: widget.profilId, activeUserId: _activeUserId);
    setState(() {
      _followed = isThereAFollow;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getFollowerNumber();
    _getFollowedNumber();
    _getPosts();
    _activeUserId =
        Provider.of<AuthorizationService>(context, listen: false).activeUserId;
    _followCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[100],
        actions: <Widget>[
          widget.profilId == _activeUserId
              ? IconButton(
                  icon: Icon(Icons.exit_to_app, color: Colors.black),
                  onPressed: _exit)
              : SizedBox(height: 0.0)
        ],
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: FutureBuilder<Object>(
          future: FireStoreService().getUser(widget.profilId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            _profileOwner = snapshot.data;
            return ListView(
              children: <Widget>[
                _profileDetails(snapshot.data),
                _showPosts(snapshot.data),
              ],
            );
          }),
    );
  }

  Widget _showPosts(Kullanici profileData) {
    if (postStyle == "list") {
      return ListView.builder(
        shrinkWrap: true,
        primary: false, // kaydırma özelliğini kapat
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return PostCart(
            post: _posts[index],
            user: profileData,
          );
        },
      );
    } else {
      List<GridTile> squares = []; //posts
      _posts.forEach((post) {
        squares.add(_createSquares(post));
      });
      return GridView.count(
          crossAxisCount: 3,
          shrinkWrap:
              true, // Sadece ihtiyacın olan alanı kaplar, kullanmazsak tüm sayfayı kaplar
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          childAspectRatio: 1.0,
          physics:
              NeverScrollableScrollPhysics(), // GridView ListView'ın içinde, ikisininde kaydırma özelliği aktif birini kapatmamız gerekiyor
          children: squares);
    }
  }

  GridTile _createSquares(Post post) {
    return GridTile(
        child: Image.network(
      post.postPicUrl,
      fit: BoxFit.cover,
    ));
  }

  Widget _profileDetails(Kullanici profileData) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, //start sola hizalar
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 50.0,
                backgroundImage: profileData.fotoUrl.isNotEmpty
                    ? NetworkImage(profileData.fotoUrl)
                    : AssetImage("assets/images/defaultProfilePic.png"),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _socialInfo(title: "Posts", number: _postNum),
                    _socialInfo(title: "Followers", number: _followerNum),
                    _socialInfo(title: "Followed", number: _followedNum),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            profileData.kullaniciAdi,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(profileData.hakkinda),
          SizedBox(height: 25.0),
          widget.profilId == _activeUserId
              ? _editProfileButton()
              : _buttonForFollow(),
          SizedBox(height: 2.0),
          widget.profilId == _activeUserId
              ? SizedBox(
                  height: 0,
                )
              : _messageButton(),
        ],
      ),
    );
  }

  Widget _buttonForFollow() {
    return _followed ? _unfollowButton() : _followButton();
  }

  Widget _messageButton() {
    //Messaj yollama
    return Container(
      width: double.infinity,
      child: FlatButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Messages(
                        profileId: widget.profilId,
                      ))); //profil düzenle sayfasına aktarır
        },
        color: Theme.of(context).primaryColor,
        child: Text(
          "Message",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _followButton() {
    return Container(
      width: double.infinity,
      child: FlatButton(
        color: Theme.of(context).primaryColor,
        onPressed: () {
          FireStoreService().follow(
              profileOwnerId: widget.profilId, activeUserId: _activeUserId);
          setState(() {
            _followed = true;
            _followerNum++;
          });
        },
        child: Text(
          "Follow",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _unfollowButton() {
    return Container(
      width: double.infinity,
      child: OutlineButton(
        onPressed: () {
          FireStoreService().unfollow(
              profileOwnerId: widget.profilId, activeUserId: _activeUserId);
          setState(() {
            _followed = false;
            _followerNum--;
          });
        },
        child: Text(
          "Unfollow",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _editProfileButton() {
    return Container(
      width: double.infinity,
      child: OutlineButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditProfile(
                        profile: _profileOwner,
                      ))); //profil düzenle sayfasına aktarır
        },
        child: Text("Edit Profile"),
      ),
    );
  }

  Widget _socialInfo({String title, int number}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment
          .center, // Kolon içindeki elemanları dikey eksende ortalar
      crossAxisAlignment: CrossAxisAlignment
          .center, // Kolon içindeki elemanları yatay eksende ortalar
      children: <Widget>[
        Text(
          number.toString(),
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2.0,
        ),
        Text(
          title,
          style: TextStyle(fontSize: 15.0),
        ),
      ],
    );
  }

  void _exit() {
    Provider.of<AuthorizationService>(context, listen: false).exit();
  }
}
