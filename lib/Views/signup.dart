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
                padding: EdgeInsets.only(left: 40,right: 40, top: 60, bottom: 20),
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
                                labelText: 'example@abc.com',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
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
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
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
                                labelText: 'Confirm Password',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          width: MediaQuery.of(context).size.width*0.78,
                          height: MediaQuery.of(context).size.height*0.08,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: const Border(top: BorderSide(width: 1, color: Colors.black38), bottom: BorderSide(width: 1, color: Colors.black38), right: BorderSide(width: 1, color: Colors.black38), left: BorderSide(width: 1, color: Colors.black38))
                          ),
                          child: Center(
                            child: DropdownButton<String>(
                              value: dropdownValue,
                              icon: const Icon(Icons.arrow_downward),
                              iconSize: 28,
                              elevation: 16,
                              style: const TextStyle(color: Colors.black87, fontSize: 22),
                              underline: Container(
                                height: 1,
                                color: Colors.green.shade700,
                              ),
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
                            child: Center(
                              child: Text("Signup", style: TextStyle(
                                fontSize: 24,
                              ),),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 0, left: 20, right: 20),
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8,left: 20, right: 20, bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: ()=>{Navigator.push(context, MaterialPageRoute(builder: (context) => Login(title: widget.title,)))},
                                child: Container(
                                  width: MediaQuery.of(context).size.width*0.25,
                                  height: MediaQuery.of(context).size.height*0.06,
                                  child: Center(
                                    child: Text("Login", style: TextStyle(
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


