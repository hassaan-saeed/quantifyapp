import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class Reports extends StatefulWidget {
  const Reports({Key? key, required this.file}) : super(key: key);

  final String file;

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  List<dynamic> reports = [];

  Future<void> getReports() async {

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

    await FirebaseFirestore.instance
        .collection('files')
        .doc(_dataUser)
        .collection('records')
        .doc(widget.file)
        .collection('results')
        .get()
        .then((QuerySnapshot querySnapshot) {
      reports = [];
      for (var doc in querySnapshot.docs) {
        var obj = {
          "id" : doc.id,
          "category": doc['category'],
          "template": doc['template'],
          "count": doc['count'],
        };
        reports.add(obj);
        print(obj);
      }
    });
    return Future.value("Files download successfully");
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 5),
        content: Text(value)
    ));
  }

  createExcel() async {
    var excel = Excel.createExcel(); // automatically creates 1 empty sheet: Sheet1

    excel.rename('Sheet1', widget.file);
    Sheet sheetObject = excel[widget.file];

    for(var r in reports){
      List<dynamic> list = [];
      list.add(r['category']);
      list.add(r['template']);
      list.add(r['count']);
      sheetObject.appendRow(list);
    }

    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/excel.xlsx';

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/excel.xlsx');

    excel.encode().then((onValue) {
      file
        ..createSync(recursive: true)
        ..writeAsBytesSync(onValue);
    });

    Share.shareFiles([filePath]);
  }

  deleteResult(String result) async {

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

    await FirebaseFirestore.instance.collection("files").doc(_dataUser).collection('records').doc(widget.file).collection('results').doc(result).delete().then((value) => showInSnackBar("Result Deleted")).catchError((error) => print("Failed to delete Result: $error"));
    _refresh();
    Navigator.pop(context);

  }

  createDialog(String result) {

    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Confirm Delete?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, 'No'), child: const Text("No")),
            TextButton(onPressed: () => {deleteResult(result)}, child: const Text("Yes")),
          ],
        ));
  }

  Future<void> _refresh() async {
    setState(() {
      getReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: ()=>{ createExcel() },
                child: const Icon(
                    Icons.ios_share
                ),
              )
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FutureBuilder(
              future: getReports(),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return DataTable(
                    horizontalMargin: 6,
                    columnSpacing: 38,
                    sortAscending: true,
                      columns: const <DataColumn>[
                        DataColumn(label: Text("#")),
                        DataColumn(label: Text("Category")),
                        DataColumn(label: Text("Template")),
                        DataColumn(label: Text("Count"), numeric: true),
                        DataColumn(label: Text("Delete"), numeric: true)
                      ],
                      rows: List<DataRow>.generate(
                          reports.length,
                          (index) => DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('${index+1}')),
                                  DataCell(Text('${reports[index]['category']}')),
                                  DataCell(Text('${reports[index]['template']}')),
                                  DataCell(Text('${reports[index]['count']}')),
                                  DataCell(InkWell(child: const Icon(Icons.delete_forever_outlined, color: Colors.red,), onTap: () => {createDialog(reports[index]['id'])},))
                                ],
                              )
                      )
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
