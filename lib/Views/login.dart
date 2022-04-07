import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quantify/Views/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home.dart';

class Login extends StatefulWidget {
  const Login({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  String _email = '';
  String _pass = '';

  checkAuthentication() async {
    auth.authStateChanges().listen((User? user) {
      if (user != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Home(
                      title: widget.title,
                    )));
      }
    });
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 5),
        content: Text(value)
    ));
  }

  guestSignIn() async {
    UserCredential user = await auth.signInAnonymously();
  }

  loginUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _pass);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showInSnackBar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showInSnackBar('Wrong password provided for that user.');
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: Center(child: Text(widget.title!)),
      // ),
      // backgroundColor: Colors.green.shade300,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 80),
                child: SizedBox(
                  child: Text(
                    "QUANTIFY",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode?Colors.amber:Colors.lightBlue,
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SizedBox(
                    child: Image.asset(isDarkMode?"images/logindark.png":"images/login.png", height: 300,)
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                        // color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 30, left: 20, right: 20, bottom: 10),
                          child: TextFormField(
                            validator: (value) {
                              return value!.isEmpty
                                  ? 'PLease enter an email!'
                                  : null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: '   Email',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                            ),
                            onChanged: (text) {
                              _email = text;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 20, right: 20, bottom: 20),
                          child: TextFormField(
                            validator: (value) {
                              return value!.isEmpty
                                  ? 'PLease enter password!'
                                  : null;
                            },
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: '   Password',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                            ),
                            onChanged: (text) {
                              _pass = text;
                            },
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          onPressed: () => {
                            if (_formKey != null)
                              {
                                if (_formKey.currentState!.validate())
                                  {loginUser()}
                              }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 40),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 16),
                              ),
                              SelectableText(
                                " Register",
                                onTap: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Signup(
                                                title: widget.title,
                                              )))
                                },
                                style: TextStyle(
                                    color: isDarkMode?Colors.amberAccent:Colors.lightBlueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Or, use as",
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 16),
                              ),
                              SelectableText(
                                " Guest",
                                onTap: () => {guestSignIn()},
                                style: TextStyle(
                                    color: isDarkMode?Colors.amberAccent:Colors.lightBlueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
