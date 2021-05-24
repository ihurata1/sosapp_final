import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosapp/models/kullanici.dart';
import 'package:sosapp/services/authorizationservice.dart';
import 'package:sosapp/services/firestoresevice.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String username, email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Create an Account"),
        ),
        body: ListView(
          children: <Widget>[
            loading
                ? LinearProgressIndicator()
                : SizedBox(
                    height: 0.0,
                  ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      //autocorrect: true,
                      decoration: InputDecoration(
                        //hintText: "Username",
                        labelText: "Username",
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (input) {
                        input.trim();
                        if (input.isEmpty)
                          return "Username field cannot be empty";
                        else if (input.trim().length < 6 ||
                            input.trim().length > 12)
                          return "Username cannot be less than 6, more than 12 characters";

                        return null;
                      },
                      onSaved: (enteredValue) => username = enteredValue,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      //autocorrect: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        //hintText: "Email",
                        labelText: "Email",
                        prefixIcon: Icon(Icons.mail),
                      ),
                      validator: (input) {
                        input.trim();
                        if (input.isEmpty)
                          return "Email field cannot be empty";
                        else if (!input.contains("@"))
                          return "Wrong email format";

                        return null;
                      },
                      onSaved: (enteredValue) => email = enteredValue,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        //hintText: "Password",
                        labelText: "Password",
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
                      onSaved: (enteredValue) => password = enteredValue,
                    ),
                    SizedBox(
                      height: 50.0,
                    ),
                    FlatButton(
                      onPressed: _createUser,
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
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  void _createUser() async {
    final _authorizationService =
        Provider.of<AuthorizationService>(context, listen: false);
    var _formState = _formKey.currentState;
    if (_formState.validate()) {
      _formState.save();
      setState(() {
        loading = true;
      });
      try {
        Kullanici kullanici =
            await _authorizationService.regWithMail(email, password);
        if (kullanici != null) {
          FireStoreService().createUser(
            id: kullanici.id,
            email: email,
            username: username,
          );
        }
        Navigator.pop(context);
      } catch (error) {
        setState(() {
          loading = false;
        });
        var snackBar = SnackBar(
          backgroundColor: Theme.of(context).errorColor,
          content: Text(error.message),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }
}
