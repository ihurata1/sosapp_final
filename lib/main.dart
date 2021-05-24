import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosapp/directing.dart';
import 'package:sosapp/services/authorizationservice.dart';

void main() => runApp(MyApp());

Map<int, Color> color = {
  50: Color.fromRGBO(136, 14, 79, .1),
  100: Color.fromRGBO(136, 14, 79, .2),
  200: Color.fromRGBO(136, 14, 79, .3),
  300: Color.fromRGBO(136, 14, 79, .4),
  400: Color.fromRGBO(136, 14, 79, .5),
  500: Color.fromRGBO(136, 14, 79, .6),
  600: Color.fromRGBO(136, 14, 79, .7),
  700: Color.fromRGBO(136, 14, 79, .8),
  800: Color.fromRGBO(136, 14, 79, .9),
  900: Color.fromRGBO(136, 14, 79, 1),
};

class MyApp extends StatelessWidget {
  MaterialColor themeColor = MaterialColor(0xFFCD5C5C, color);
  @override
  Widget build(BuildContext context) {
    return Provider<AuthorizationService>(
      create: (_) => AuthorizationService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Projem',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Directing(),
      ),
    );
  }
}
