import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _SignupState createState() => _SignupState();
}

String dropdownValue = "Select Type";

class _SignupState extends State<Signup> {

  final _formKey = GlobalKey<FormState>();
  String? _confPass;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
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
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 5),
        content: Text(value)
    ));
  }

  guestSignIn() async {
    UserCredential user = await auth.signInAnonymously();
  }

  signupUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email,
          password: _pass
      );
      await firestore.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).set(
          {
            "email" : _email,
            "type" : dropdownValue,
            "uid" : FirebaseAuth.instance.currentUser?.uid
          });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showInSnackBar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showInSnackBar('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      // appBar: AppBar(
      //     automaticallyImplyLeading: false,
      //     title: Center(child: Text(widget.title!)),
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
                        color: isDarkMode?Colors.amber:Colors.lightBlue
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              SizedBox(child: Image.asset(isDarkMode?"images/signupdark.png":"images/signup.png", height: 200,)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                        // color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10,),
                        Container(
                          width: MediaQuery.of(context).size.width*0.78,
                          height: MediaQuery.of(context).size.height*0.08,
                          child: Center(
                            child: TextFormField(
                              validator: (value){
                                return value!.isEmpty ? 'PLease enter an email!' : null;
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: '   Email',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),

                              ),
                              onChanged: (text) {
                                _email = text;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          width: MediaQuery.of(context).size.width*0.78,
                          height: MediaQuery.of(context).size.height*0.08,
                          child: Center(
                            child: TextFormField(
                              validator: (value){
                                _confPass = value;
                                if(value!.isEmpty){
                                  return 'Please enter a password!';
                                }
                                else if(value.length < 8){
                                  return 'Password must be 8 characters long!';
                                }
                                else{
                                  return null;
                                }
                              },
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: '   Password',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                              ),
                              onChanged: (text) {
                                _pass = text;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          width: MediaQuery.of(context).size.width*0.78,
                          height: MediaQuery.of(context).size.height*0.08,
                          child: Center(
                            child: TextFormField(
                              validator: (value){
                                if(value!.isEmpty){
                                  return 'Please enter a password!';
                                }
                                else if(value.length < 8){
                                  return 'Password must be 8 characters long!';
                                }
                                else if(value != _confPass){
                                  return 'Password must be same as above!';
                                }
                                else{
                                  return null;
                                }
                              },
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: '   Confirm Password',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          width: MediaQuery.of(context).size.width*0.78,
                          height: MediaQuery.of(context).size.height*0.08,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border:  Border(top: BorderSide(width: 1, color: isDarkMode?Colors.white60:Colors.black38), bottom: BorderSide(width: 1, color: isDarkMode?Colors.white60:Colors.black38), right: BorderSide(width: 1, color: isDarkMode?Colors.white60:Colors.black38), left: BorderSide(width: 1, color: isDarkMode?Colors.white60:Colors.black38))
                          ),
                          child: Center(
                            child: DropdownButton<String>(
                              value: dropdownValue,
                              icon: const Icon(Icons.arrow_downward),
                              iconSize: 28,
                              elevation: 16,
                              style: TextStyle(color: isDarkMode?Colors.white60:Colors.black54, fontSize: 22),

                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownValue = newValue!;
                                });
                              },
                              items: <String>['Select Type','Individual', 'Business']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(height: 12,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                          onPressed: ()=>{
                            if(_formKey != null){
                              if(_formKey.currentState!.validate()){
                                signupUser()
                              }
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.4,
                            height: MediaQuery.of(context).size.height*0.07,
                            child: const Center(
                              child: Text("Signup", style: TextStyle(
                                fontSize: 24,
                              ),),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account? ", style: TextStyle(color: Colors.grey.shade700, fontSize: 16),),
                              SelectableText(" Login", onTap: ()=>{Navigator.push(context, MaterialPageRoute(builder: (context) => Login(title: widget.title,)))}, style: TextStyle(color: isDarkMode?Colors.amberAccent:Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 18),),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20,),
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Or, use as", style: TextStyle(color: Colors.grey.shade700, fontSize: 16),),
                              SelectableText(" Guest", onTap: ()=>{guestSignIn()}, style: TextStyle(color: isDarkMode?Colors.amberAccent:Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 18),),
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


