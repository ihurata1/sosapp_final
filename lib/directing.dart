import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosapp/models/kullanici.dart';
import 'package:sosapp/pages/mainpage.dart';
import 'package:sosapp/pages/loginscreen.dart';
import 'package:sosapp/services/authorizationservice.dart';

class Directing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _authorizationService =
        Provider.of<AuthorizationService>(context, listen: false);
    return StreamBuilder(
      stream: _authorizationService.durumTakipcisi,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        if (snapshot.hasData) {
          Kullanici aktifKullanici = snapshot.data;
          _authorizationService.activeUserId = aktifKullanici.id;
          return MainPage();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
