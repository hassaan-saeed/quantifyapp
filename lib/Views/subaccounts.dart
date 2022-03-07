import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quantify/Views/addsubaccount.dart';

class SubAccounts extends StatefulWidget {
  const SubAccounts({Key? key}) : super(key: key);

  @override
  State<SubAccounts> createState() => _SubAccountsState();
}

class _SubAccountsState extends State<SubAccounts> {

  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('subaccounts').where('manager', isEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text("Sub-Accounts")),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: ()=>{Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNewSubAcc()))},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                child: Text("Add New", style: TextStyle(
                  fontSize: 24,
                ),),
              ),
            ),
            const SizedBox(height: 20,),
            StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }
                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['name']),
                      subtitle: Text(data['email']),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
