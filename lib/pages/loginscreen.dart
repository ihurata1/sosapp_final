import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosapp/pages/createaccount.dart';
import 'package:sosapp/pages/forgotpassword.dart';
import 'package:sosapp/services/authorizationservice.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  String email, password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColorLight,
      body: Stack(
        children: <Widget>[
          _pageElements(),
          _loadingAnimation(),
        ],
      ),
    );
  }

  Widget _loadingAnimation() {
    if (loading == true) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Center();
    }
  }

  Widget _pageElements() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0),
        children: <Widget>[
          Image.asset(
            'assets/images/sosLogo.png',
            scale: 5.0,
          ),
          SizedBox(
            height: 0.0,
          ),
          TextFormField(
            //autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email",
              prefixIcon: Icon(Icons.mail),
            ),
            validator: (input) {
              input.trim();
              if (input.isEmpty)
                return "Email field cannot be empty";
              else if (!input.contains("@")) return "Wrong email format";

              return null;
            },
            onSaved: (input) => email = input,
          ),
          SizedBox(
            height: 40.0,
          ),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: Icon(Icons.lock),
            ),
            validator: (input) {
              input.trim();
              if (input.isEmpty)
                return "Password field cannot be empty";
              else if (input.trim().length < 6)
                return "Password cannot be less than 6 characters";
              return null;
            },
            onSaved: (input) => password = input,
          ),
          SizedBox(
            height: 40.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CreateAccount()));
                  },
                  child: Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: FlatButton(
                  onPressed: _logIn,
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Center(
              child: Text(
            "or",
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          )),
          SizedBox(
            height: 20,
          ),
          Center(
              child: Text(
            "Log in with Google Account",
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          )),
          SizedBox(
            height: 20,
          ),
          Center(
              child: InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ForgotPassword()));
            },
            child: Text(
              "Forgot Password?",
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
          )),
        ],
      ),
    );
  }

  void _logIn() async {
    final _authorizationService =
        Provider.of<AuthorizationService>(context, listen: false);
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() {
        loading = true;
      });
      try {
        await _authorizationService.logInWithMail(email, password);
      } catch (error) {
        setState(() {
          loading = false;
        });
        var snackBar = SnackBar(
          content: Text(error.code),
          backgroundColor: Theme.of(context).errorColor,
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }
}
