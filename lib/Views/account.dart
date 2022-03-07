import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quantify/Views/editprofile.dart';
import 'package:quantify/Views/subaccounts.dart';

import 'login.dart';

class AccountInfo extends StatefulWidget {
  const AccountInfo({Key? key}) : super(key: key);

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {

  var currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  String _test = "";
  String _name = "Name";
  String _type = "Account Type";
  String _email = "Email@xyz.com";

  signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  checkAuthentication() async {
    FirebaseAuth.instance.authStateChanges()
        .listen((User? user) {
      if (user == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login(title: 'Quantify',)));
      }
    });
  }

  getData(){
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        _name = documentSnapshot.get('name');
        _type = documentSnapshot.get('type');
        _email = documentSnapshot.get('email');
        print('Document exists on the database');
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkAuthentication();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.black54,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage("images/image.png"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
                      Text(_name, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),),
                      SizedBox(height: 16,),
                      Text(_type, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),),
                      Text(_email, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 50,),
          ElevatedButton(
            onPressed: ()=>{Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfile()))},
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              child: Text("Edit Profile", style: TextStyle(
                fontSize: 24,
              ),),
            ),
          ),
          const SizedBox(height: 20,),
          ElevatedButton(
            onPressed: ()=>{Navigator.push(context, MaterialPageRoute(builder: (context) => const SubAccounts()))},
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              child: Text("Manage Sub-Accounts", style: TextStyle(
                fontSize: 24,
              ),),
            ),
          ),
          const SizedBox(height: 20,),
          ElevatedButton(
            onPressed: ()=>{signOut()},
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              child: Text("Signout", style: TextStyle(
                fontSize: 24,
              ),),
            ),
          ),
        ],
      ),
    );
  }
}
