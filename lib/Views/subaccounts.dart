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

  Future<String> getSubs() async {
    await FirebaseFirestore.instance
        .collection('subaccounts')
        // .orderBy('name')
        .where('manager', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      // snapshot = querySnapshot as AsyncSnapshot<QuerySnapshot<Object?>>;
      // print(querySnapshot);
      querySnapshot.docs.forEach((doc) {
        subsList.add(doc.data());
        print(doc.data());
      });
    });
    return Future.value("Data download successfully");
  }

  deleteSub(String email, String password) async {
    FirebaseApp app = await Firebase.initializeApp(name: 'Secondary', options: Firebase.app().options);
    late UserCredential userCredential;
    try {
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      userCredential = await FirebaseAuth.instanceFor(app: app).signInWithCredential(credential);
      await FirebaseAuth.instanceFor(app: app).currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print('The user must reauthenticate before this operation can be executed.');
      }
    }
    await app.delete();
  }

  createDialog(String emailIn) {
    String email = emailIn;
    String pass = "";

    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("Delete?"),
              content: TextFormField(
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter Sub-Account\'s Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                onChanged: (text) {
                  pass = text;
                },
              ),
              // content: Text("Do you want to delete this account?"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, 'No'), child: Text("No")),
                TextButton(onPressed: () => {deleteSub(email, pass)}, child: Text("Yes")),
              ],
            ));
  }

  // final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('subaccounts').where('manager', isEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getSubs();
  }

  @override
  Widget build(BuildContext context) {
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
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
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
                  )
                  // ListView(
                  //   children: subsList.map((DocumentSnapshot document) {
                  //     Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  //     return ListTile(
                  //       title: Text(data['name']),
                  //       subtitle: Text(data['email']),
                  //     );
                  //   }).toList(),
                  // )
                  // StreamBuilder<QuerySnapshot>(
                  //   stream: _usersStream,
                  //   builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  //     if (snapshot.hasError) {
                  //       return Text('Something went wrong');
                  //     }
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //       return Text("Loading");
                  //     }
                  //     return ListView(
                  //       children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  //         Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  //         return ListTile(
                  //           title: Text(data['name']),
                  //           subtitle: Text(data['email']),
                  //         );
                  //       }).toList(),
                  //     );
                  //   },
                  // ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
