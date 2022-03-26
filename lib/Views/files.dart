import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quantify/Views/addfiles.dart';
import 'package:quantify/Views/reports.dart';
import 'package:quantify/Views/saveResult.dart';

class Files extends StatefulWidget {
  const Files({Key? key}) : super(key: key);

  @override
  _FilesState createState() => _FilesState();
}

class _FilesState extends State<Files> {

  List<String> files = [];

  Future<void> getFiles() async {

    await FirebaseFirestore.instance.collection('files').doc(FirebaseAuth.instance.currentUser?.uid).collection('records').get()
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFile())),
        label: const Text("ADD"),

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

