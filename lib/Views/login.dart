import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quantify/Views/signup.dart';
import 'package:firebase_core/firebase_core.dart';
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
    auth.authStateChanges()
        .listen((User? user) {
      if (user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(title: widget.title,)));
      }
    });
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value)
    ));
  }

  guestSignIn() async {
    UserCredential user = await auth.signInAnonymously();
  }

  loginUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _pass
      );
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text(widget.title!)),
      ),
      backgroundColor: Colors.green.shade300,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 80),
                child: Text("Make Your Daily Life Simple, Count Things Faster.",textAlign: TextAlign.center, style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                ),),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 10),
                          child: TextFormField(
                            validator: (value){
                              return value!.isEmpty ? 'PLease enter an email!' : null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'example@abc.com',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            onChanged: (text) {
                              _email = text;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
                          child: TextFormField(
                            validator: (value){
                              return value!.isEmpty ? 'PLease enter password!' : null;
                            },
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock),
                            ),
                            onChanged: (text) {
                              _pass = text;
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: ()=>{
                            if(_formKey != null){
                              if(_formKey.currentState!.validate()){
                                loginUser()
                              }
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                            child: Text("Login", style: TextStyle(
                              fontSize: 24,
                            ),),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 4, left: 20, right: 20),
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10,left: 20, right: 20, bottom: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: ()=>{Navigator.push(context, MaterialPageRoute(builder: (context) => Signup(title: widget.title,)))},
                                child: Container(
                                  width: MediaQuery.of(context).size.width*0.25,
                                  height: MediaQuery.of(context).size.height*0.06,
                                  child: Center(
                                    child: Text("Signup", style: TextStyle(
                                      fontSize: 24,
                                    ),),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              ElevatedButton(
                                onPressed: ()=>{guestSignIn()},
                                child: Container(
                                  width: MediaQuery.of(context).size.width*0.25,
                                  height: MediaQuery.of(context).size.height*0.06,
                                  child: Center(
                                    child: Text("Guest", style: TextStyle(
                                      fontSize: 24,
                                    ),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
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


