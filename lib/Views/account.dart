import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
            if(documentSnapshot.get('type')){
              _type = documentSnapshot.get('type');
            }
            if(documentSnapshot.get('email')){
              _email = documentSnapshot.get('email');
            }
            if(documentSnapshot.get('name')){
              _name = documentSnapshot.get('name');
            }


            print(_type);
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
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  color: isDarkMode?Colors.black54:Colors.white,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
                        child: Row(
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
                                          return Icon(Icons.add_photo_alternate_outlined,size: 50, color: isDarkMode?Colors.black:Colors.white,);
                                        }
                                      },
                                    ),
                                    // child: Image.network(_image, fit: BoxFit.cover)
                                ),
                              )
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                              child: Column(
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
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      // if(_type == "Individual" || _type == "Business"){
                      //   return
                      // }
                      Row(
                        mainAxisAlignment: _type == "Individual"?MainAxisAlignment.center:MainAxisAlignment.spaceEvenly,
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
                                    children: const [
                                      Icon(Icons.edit, size: 50,),
                                      Text(
                                        "Edit Profile",
                                        style: TextStyle(
                                          fontSize: 20,
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
                                    children: const [
                                      Icon(Icons.people, size: 50,),
                                      Text(
                                        "Manage SubAccounts",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 17,
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
                                onPressed: () => {},
                                child: Padding(
                                  padding:
                                  EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_card, size: 50,),
                                      Text(
                                        "Update Card",
                                        style: TextStyle(
                                          fontSize: 20,
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
                                    children: const [
                                      Icon(Icons.attach_money, size: 50,),
                                      Text(
                                        "Manage Subscribtion",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 17,
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
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
