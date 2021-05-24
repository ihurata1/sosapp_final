import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosapp/services/authorizationservice.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Reset Password"),
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
                      height: 50.0,
                    ),
                    FlatButton(
                      onPressed: _resetPassword,
                      child: Text(
                        'Reset Password',
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

  void _resetPassword() async {
    final _authorizationService =
        Provider.of<AuthorizationService>(context, listen: false);
    var _formState = _formKey.currentState;
    if (_formState.validate()) {
      _formState.save();
      setState(() {
        loading = true;
      });
      try {
        await _authorizationService.resetPassword(email);
        Navigator.pop(context);
      } catch (error) {
        setState(() {
          loading = false;
        });
        var snackBar = SnackBar(
          backgroundColor: Theme.of(context).errorColor,
          content: Text(error.code),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }
}
