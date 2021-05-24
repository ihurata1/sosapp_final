import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosapp/assets/my_flutter_app_icons.dart';
import 'package:sosapp/models/Kullanici.dart';
import 'package:sosapp/models/post.dart';
import 'package:sosapp/services/authorizationservice.dart';
import 'package:sosapp/services/firestoresevice.dart';
import 'package:sosapp/widgets/nondeletingfuturebuilder.dart';
import 'package:sosapp/widgets/postcart.dart';

class FlowPage extends StatefulWidget {
  @override
  _FlowPageState createState() => _FlowPageState();
}

class _FlowPageState extends State<FlowPage> {
  List<Post> _posts = [];

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 1));
    _getFlowPosts();
  }

  _getFlowPosts() async {
    String activeUserId =
        Provider.of<AuthorizationService>(context, listen: false).activeUserId;
    List<Post> posts = await FireStoreService().getFlowPosts(activeUserId);
    if (mounted) {
      setState(() {
        _posts = posts;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getFlowPosts();
  }

  Widget list() {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      primary: false, // kaydırma özelliğini kapat
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        Post post = _posts[index];
        return nonDeletingFutureBuilder(
            future: FireStoreService().getUser(post.publisherId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox(); //postlar yüklenene kadar boş döndürür
              }
              Kullanici postOwner = snapshot.data;
              return PostCart(post: post, user: postOwner);
            });
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/sosLogo.png',
          scale: 10.0,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          await refreshList();
        },
        child: list(),
      ),
    );
  }
}
