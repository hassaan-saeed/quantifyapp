import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quantify/Views/addsubaccount.dart';

class SubAccounts extends StatefulWidget {
  const SubAccounts({Key? key}) : super(key: key);

  @override
  State<SubAccounts> createState() => _SubAccountsState();
}

class _SubAccountsState extends State<SubAccounts> {
  AsyncSnapshot<QuerySnapshot> snapshot = const AsyncSnapshot.nothing();
  List<dynamic> subsList = [];
  late TextEditingController _controller;

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.redAccent,
      duration: const Duration(seconds: 5),
        content: Text(value)
    ));
  }

  Future<String> getSubs() async {
    await FirebaseFirestore.instance
        .collection('subaccounts')
        .where('manager', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      subsList = [];
      querySnapshot.docs.forEach((doc) {
        subsList.add(doc.data());
        print(doc.data());
      });
    });
    return Future.value("Data download successfully");
  }

  deleteSub(String email, String password) async {
    FirebaseApp app = await Firebase.initializeApp(name: 'Secondary', options: Firebase.app().options);

    try {
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: app).signInWithEmailAndPassword(email: email, password: password);
      await FirebaseAuth.instanceFor(app: app).currentUser?.delete();
      await FirebaseFirestore.instance.collection("subaccounts").doc(userCredential.user?.uid).delete().then((value) => showInSnackBar("Sub-Account Deleted")).catchError((error) => print("Failed to delete user: $error"));
    } on FirebaseAuthException catch (e) {
      if(password==""){
        showInSnackBar("Empty Password");
      }
      if (e.code == 'requires-recent-login') {
        showInSnackBar('The user must re-authenticate before this operation can be executed.');
      }
      else if (e.code == 'user-not-found') {
        showInSnackBar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showInSnackBar('Wrong password provided for that user.');
      }
      else{
        print(e);
      }
    }
    await app.delete();
    Navigator.pop(context);
  }

  createDialog(String emailIn) {
    String email = emailIn;
    String _tpass = "";

    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("Delete?"),
              content: TextField(
                controller: _controller,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Sub-Account\'s Password',
                ),
                onChanged: (text) {
                      _tpass = text;
                      },
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, 'No'), child: const Text("No")),
                TextButton(onPressed: () => {deleteSub(email, _tpass)}, child: const Text("Yes")),
              ],
            ));
  }

  Future<void> _refresh() async {
    setState(() {
      getSubs();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TextEditingController();
    // getSubs();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text("Sub-Accounts")),
      ),
      body: FutureBuilder(
        future: getSubs(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Please wait its loading...'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Container(
              color: isDarkMode?Colors.black54:Colors.grey.shade300,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddNewSubAcc()))
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                      child: Text(
                        "Add New",
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                          itemCount: subsList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 5, bottom: 5),
                              child: Card(
                                child: ListTile(
                                  onTap: ()=>{createDialog(subsList[index]['email'])},
                                  title: Text(subsList[index]['name']),
                                  subtitle: Text(subsList[index]['email']),
                                ),
                              ),
                            );
                          }),
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
