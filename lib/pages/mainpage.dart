import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosapp/assets/my_flutter_app_icons.dart';
import 'package:sosapp/pages/flowpage.dart';
import 'package:sosapp/pages/notificationss.dart';
import 'package:sosapp/pages/profile.dart';
import 'package:sosapp/pages/search.dart';
import 'package:sosapp/pages/upload.dart';
import 'package:sosapp/services/authorizationservice.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPage = 0;
  PageController pageController;
  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  void dispose() {
    //sayfadan çıkarken controller'ı kapat
    pageController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    String activeUserId =
        Provider.of<AuthorizationService>(context, listen: false).activeUserId;
    return Scaffold(
      body: PageView(
        onPageChanged: (openedPageNo) {
          setState(() {
            _currentPage = openedPageNo;
          });
        },
        controller: pageController,
        children: <Widget>[
          FlowPage(),
          Search(),
          Upload(),
          Notificationss(),
          Profile(
            profilId: activeUserId,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Flow")),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore), title: Text("Explore")),
          BottomNavigationBarItem(
              icon: Icon(
                MyFlutterApp.sos_logo,
                size: 30.0,
              ),
              title: Text("Upload")),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), title: Text("Notification")),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), title: Text("Profile")),
        ],
        onTap: (selectedPageNo) {
          setState(() {
            _currentPage = selectedPageNo;
            pageController.jumpToPage(_currentPage);
          });
        },
      ),
    );
  }
}
