import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quantify/Views/editprofile.dart';
import 'package:quantify/Views/resetpass.dart';
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
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const Login(
                      title: 'Quantify',
                    )));
      }
    });
  }

  Future<String> getData() async {
    // String? temail = FirebaseAuth.instance.currentUser?.email;

    try{
      var cond1 = await FirebaseFirestore.instance
          .collection("subaccounts")
          .doc(currentUser?.uid)
          .get();
      if (cond1.exists) {
        await FirebaseFirestore.instance
            .collection('subaccounts')
            .doc(currentUser?.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            _type = documentSnapshot.get('type');
            _email = documentSnapshot.get('email');
            _name = documentSnapshot.get('name');
            if(_type=="subaccount"){
              _type = "Sub-Account";
            }
            print('Document exists on the database sub');
            return documentSnapshot;
          }
        });
        return Future.value("Data download successfully");
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            _type = documentSnapshot.get('type');
            _email = documentSnapshot.get('email');
            _name = documentSnapshot.get('name');
            print(_type);
            print('Document exists on the database users');
            return documentSnapshot;
          }
        });

        return Future.value("Data download successfully");
      }
    }
    on FirebaseException catch (e){
      print(e);
    }
    catch(e){
      print(e);
    }
    return "";
  }

  Future<String> downloadURL() async {
    Reference ref = FirebaseStorage.instance
        .ref('profilepics/${FirebaseAuth.instance.currentUser?.uid}');
    return await ref.getDownloadURL();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkAuthentication();
    // getData();
  }



  Future<void> _refresh() async {
    setState(() {
      print(MediaQuery.of(context).size.width);
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {

    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Please wait its loading...'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            if( currentUser?.isAnonymous == true){
              return Container(
                width: MediaQuery.of(context).size.width,
                color: isDarkMode?Colors.black54:Colors.white,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text("Guest User Access", style: TextStyle(fontSize: 28),),
                    const SizedBox(height: 110,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      onPressed: () => {signOut()},
                      child: const Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                        child: Text(
                          "Signout",
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              backgroundColor: isDarkMode?Colors.black54:Colors.white,
              onRefresh: _refresh,
              child: Container(
                color: isDarkMode?Colors.black54:Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CircleAvatar(
                                  radius: 65,
                                  backgroundColor: isDarkMode?Colors.amberAccent:Colors.lightBlueAccent,
                                  child: ClipOval(
                                    child: SizedBox.fromSize(
                                        size: Size.fromRadius(60),
                                        child: FutureBuilder(
                                          future: downloadURL(),
                                          builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                                            if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                                              return Image.network(snapshot.data!, fit: BoxFit.cover);
                                            }
                                            else{
                                              return Icon(_type!="Sub-Account"?Icons.add_photo_alternate_outlined:Icons.people_alt_outlined,size: 50, color: isDarkMode?Colors.black:Colors.white,);
                                            }
                                          },
                                        ),
                                        // child: Image.network(_image, fit: BoxFit.cover)
                                    ),
                                  )
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _name,
                                      style: TextStyle(
                                          fontSize: _name.length>=10?22:26,
                                          fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Text(
                                      _type,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Text(
                                      _email,
                                      style: TextStyle(
                                          fontSize: _email.length>=25?12:14,
                                          fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 50,
                            ),

                            Row(
                              mainAxisAlignment: _type != "Business"?MainAxisAlignment.center:MainAxisAlignment.spaceEvenly,
                              children: [
                                Visibility(
                                  visible: _type == "Individual" || _type == "Business",
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width*0.4,
                                    height: MediaQuery.of(context).size.height*0.15,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: isDarkMode?Colors.deepOrange.shade400:Colors.indigo.shade300,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20))),
                                      onPressed: () => {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const EditProfile()))
                                      },
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.edit, size: MediaQuery.of(context).size.width>360?50:40,),
                                            Text(
                                              "Edit Profile",
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width>360?20:16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _type == "Business",
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width*0.4,
                                    height: MediaQuery.of(context).size.height*0.15,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: isDarkMode?Colors.deepPurple.shade300:Colors.blue.shade400,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20))),
                                      onPressed: () => {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const SubAccounts()))
                                      },
                                      child: Padding(
                                        padding:
                                        EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.people, size: MediaQuery.of(context).size.width>360?50:40,),
                                            Text(
                                              "Manage SubAccounts",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width>360?17:15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Visibility(
                                  visible: _type == "Individual" || _type == "Business",
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width*0.4,
                                    height: MediaQuery.of(context).size.height*0.15,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: isDarkMode?Colors.cyan.shade400:Colors.lightBlue.shade700,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20))),
                                      onPressed: () => {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const ResetPass()))
                                      },
                                      child: Padding(
                                        padding:
                                        EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.lock, size: MediaQuery.of(context).size.width>360?50:40,),
                                            Text(
                                              "Change Password",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width>360?18:15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _type == "Individual" || _type == "Business",
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width*0.4,
                                    height: MediaQuery.of(context).size.height*0.15,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: isDarkMode?Colors.green.shade500:Colors.teal.shade300,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20))),
                                      onPressed: () => {},
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.attach_money, size: MediaQuery.of(context).size.width>360?50:40,),
                                            Text(
                                              "Manage Subscribtion",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width>360?17:15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.85,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20))),
                                onPressed: () => {signOut()},
                                child: const Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                                  child: Text(
                                    "Signout",
                                    style: TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }
}
