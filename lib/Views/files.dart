import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quantify/Views/reports.dart';

class Files extends StatefulWidget {
  const Files({Key? key}) : super(key: key);

  @override
  _FilesState createState() => _FilesState();
}

class _FilesState extends State<Files> {

  List<String> files = [];
  late TextEditingController _controller;
  var currentUser = FirebaseAuth.instance.currentUser;

  Future<void> getFiles() async {

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

    await FirebaseFirestore.instance.collection('files').doc(_dataUser).collection('records').get()
        .then((QuerySnapshot querySnapshot) {
      files = [];
      for (var doc in querySnapshot.docs) {
        files.add(doc['name']);
        print(files);
      }
    });
    return Future.value("Files download successfully");
  }

  Future<void> _refresh() async {
    setState(() {
      getFiles();
    });
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: value=="File Created"?Colors.greenAccent:Colors.redAccent,
        duration: const Duration(seconds: 5),
        content: Text(value)
    ));
  }

  deleteFile(String file) async {

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

    await FirebaseFirestore.instance.collection("files").doc(_dataUser).collection('records').doc(file).delete().then((value) => showInSnackBar("File Deleted")).catchError((error) => print("Failed to delete user: $error"));
    _refresh();
    Navigator.pop(context);

  }

  createDialog(String file) {

    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Delete?"),
          content: Text("File: $file"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, 'No'), child: const Text("No")),
            TextButton(onPressed: () => {deleteFile(file)}, child: const Text("Yes")),
          ],
        ));
  }

  Future<void> addFile(String name) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    var _dataUser;
    try {
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
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    await FirebaseFirestore.instance
        .collection('files')
        .doc(_dataUser)
        .collection('records')
        .doc(name)
        .set({"name": name})
        .then((value) => {showInSnackBar("File Created")})
        .catchError((error) => showInSnackBar(error));
    Navigator.pop(context);
  }

  createDialogAdd() {
    String name = "";

    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Create File"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter File Name',
            ),
            onChanged: (text) {
              name = text;
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, 'Cancel'), child: const Text("Cancel")),
            TextButton(onPressed: () => {addFile(name)}, child: const Text("Done")),
          ],
        ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TextEditingController();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => {currentUser?.isAnonymous == true?showInSnackBar("Must be Logged In"):createDialogAdd()},
        child: Icon(Icons.add),
      ),

      body: Container(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder(
            future: getFiles(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot){
              if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                return ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (BuildContext context,int index){
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Material(
                          elevation: 2.0,
                          child: ListTile(
                            onTap: ()=>{Navigator.push(context, MaterialPageRoute(builder: (context) => Reports(file: files[index])))},
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            tileColor: isDarkMode?Colors.black54:Colors.white,
                            leading: const Icon(Icons.analytics_outlined),
                            trailing: InkWell(child: const Icon(Icons.delete_forever_outlined, color: Colors.red,), onTap: () => {createDialog(files[index])},),
                            title: Text('${files[index]}',
                              style: const TextStyle(fontSize: 18),),

                          ),
                        ),
                      );
                    }
                );
              }
              else{
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}

