import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFile extends StatefulWidget {
  const AddFile({Key? key}) : super(key: key);

  @override
  State<AddFile> createState() => _AddFileState();
}

class _AddFileState extends State<AddFile> {

  final _formKey = GlobalKey<FormState>();
  String name = '';
  String category = '';
  String template = '';
  String count = '';

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
        backgroundColor: value=="Record Added"?Colors.greenAccent:Colors.redAccent,
        duration: const Duration(seconds: 5),
        content: Text(value)
    ));
  }

  Future<void> addFile() async {

    var currentUser = FirebaseAuth.instance.currentUser;
    var _dataUser ;
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
            _dataUser = documentSnapshot.get('manager');
            print('Manager received');
          }
        });
      } else {
        _dataUser = currentUser?.uid;
      }
    }
    on FirebaseException catch (e){
      print(e);
    }
    catch(e){
      print(e);
    }

    await FirebaseFirestore.instance.collection('files').doc(_dataUser).collection('records').doc(name).set(
        {
          "name": name
        });
    await FirebaseFirestore.instance.collection('files').doc(_dataUser).collection('records').doc(name).collection('results')
        .add(
        {
          "category" : category,
          "template" : template,
          "count" : count,
          "date" : DateTime.now()
        })
        .then((value) => {
      showInSnackBar("Record Added")
    }).catchError((error)=> showInSnackBar(error));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a File"),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 40, right: 40, bottom: 10),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Please enter a name!';
                      }
                      else if(value.length >=21){
                        return 'Name should at most 20 characters!';
                      }
                      else{
                        return null;
                      }
                    },
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Enter File Name',
                      border: UnderlineInputBorder(),
                      prefixIcon: Icon(Icons.insert_drive_file),
                    ),
                    onChanged: (text) {
                      name = text;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0, left: 40, right: 40, bottom: 10),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Please enter a category!';
                      }
                      else if(value.length >=10){
                        return 'Name should at most 10 characters!';
                      }
                      else{
                        return null;
                      }
                    },
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Enter Category',
                      border: UnderlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    onChanged: (text) {
                      category = text;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0, left: 40, right: 40, bottom: 10),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Please enter a template name!';
                      }
                      else if(value.length >=20){
                        return 'Name should at most 20 characters!';
                      }
                      else{
                        return null;
                      }
                    },
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Enter Template Name',
                      border: UnderlineInputBorder(),
                      prefixIcon: Icon(Icons.menu),
                    ),
                    onChanged: (text) {
                      template = text;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0, left: 40, right: 40, bottom: 30),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Please enter a count!';
                      }
                      else if(value.length >=10){
                        return 'Name should at most 10 characters!';
                      }
                      else{
                        return null;
                      }
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter Count',
                      border: UnderlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    onChanged: (text) {
                      count = text;
                    },
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  onPressed: ()=>{
                    if(_formKey.currentState!.validate()){
                      addFile()
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.4,
                    height: MediaQuery.of(context).size.height*0.07,
                    child: const Center(
                      child: Text("Create", style: TextStyle(
                        fontSize: 24,
                      ),),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
