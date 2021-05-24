import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sosapp/models/Kullanici.dart';
import 'package:sosapp/models/notificationn.dart';
import 'package:provider/provider.dart';
import 'package:sosapp/pages/profile.dart';
import 'package:sosapp/pages/singlepost.dart';
import 'package:sosapp/services/authorizationservice.dart';
import 'package:sosapp/services/firestoresevice.dart';
import 'package:timeago/timeago.dart' as timeago;

class Notificationss extends StatefulWidget {
  @override
  _NotificationssState createState() => _NotificationssState();
}

class _NotificationssState extends State<Notificationss> {
  List<Notificationn> _notifications;
  String _activeUserId;
  bool _loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _activeUserId =
        Provider.of<AuthorizationService>(context, listen: false).activeUserId;
    getNotifications();
  }

  Future<void> getNotifications() async {
    List<Notificationn> notifications =
        await FireStoreService().getNotification(profileUserId: _activeUserId);
    if (mounted) {
      setState(() {
        _notifications = notifications;
        _loading = false;
      });
    }
  }

  showNotifications() {
    if (_loading) {
      Center(child: CircularProgressIndicator());
    }
    if (_notifications?.isEmpty ?? true) {
      return Center(child: Text("There is no Notification!"));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: RefreshIndicator(
        onRefresh: getNotifications,
        child: ListView.builder(
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            Notificationn notification = _notifications[index];
            return notificationLine(notification);
          },
        ),
      ),
    );
  }

  notificationLine(Notificationn notification) {
    String message = createMessage(notification.activateType);
    return FutureBuilder(
      future: FireStoreService().getUser(notification.activatorId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(height: 0.0);
        }
        Kullanici activator = snapshot.data;

        return ListTile(
          leading: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profile(
                            profilId: notification.activatorId,
                          )));
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: activator.fotoUrl == ""
                  ? AssetImage(
                      "assets/images/defaultProfilePic.png",
                    )
                  : NetworkImage(activator.fotoUrl),
            ),
          ),
          title: RichText(
            text: TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profile(
                                  profilId: notification.activatorId,
                                )));
                  },
                text: "${activator.kullaniciAdi}",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: notification.comment == null
                        ? " $message"
                        : " $message ${notification.comment}",
                    style: TextStyle(fontWeight: FontWeight.normal),
                  )
                ]),
          ),
          subtitle: Text(timeago.format(notification.creationTime.toDate())),
          trailing: postVisual(notification.activateType, notification.postPic,
              notification.postId),
        );
      },
    );
  }

  postVisual(String activateType, String postPic, String postId) {
    if (activateType == "follow")
      return null;
    else if (activateType == "like" || activateType == "comment") {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SinglePost(
                        postId: postId,
                        postOwnerId: _activeUserId,
                      )));
        },
        child: Image.network(
          postPic,
          width: 50.0,
          height: 50.0,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  createMessage(String activateType) {
    if (activateType == "like") {
      return ("liked your post.");
    } else if (activateType == "follow") {
      return ("followed you.");
    } else if (activateType == "comment") {
      return ("commented on your post.");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Notifications",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: showNotifications(),
    );
  }
}
