import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key, required this.file}) : super(key: key);

  final String file;

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  List<dynamic> reports = [];

  Future<void> getReports() async {
    await FirebaseFirestore.instance
        .collection('files')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('records')
        .doc(widget.file)
        .collection('results')
        .get()
        .then((QuerySnapshot querySnapshot) {
      reports = [];
      for (var doc in querySnapshot.docs) {
        var obj = {
          "category": doc['category'],
          "template": doc['template'],
          "count": doc['count'],
        };
        reports.add(obj);
      }
    });
    return Future.value("Files download successfully");
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
        title: Center(child: Text(widget.file)),
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
                    sortAscending: true,
                      columns: const <DataColumn>[
                        DataColumn(label: Text("#")),
                        DataColumn(label: Text("Category")),
                        DataColumn(label: Text("Template")),
                        DataColumn(label: Text("Count"), numeric: true)
                      ],
                      rows: List<DataRow>.generate(
                          reports.length,
                          (index) => DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('${index+1}')),
                                  DataCell(Text('${reports[index]['category']}')),
                                  DataCell(Text('${reports[index]['template']}')),
                                  DataCell(Text('${reports[index]['count']}'))
                                ],
                              )));
                  // return ListView.builder(
                  //     itemCount: reports.length,
                  //     itemBuilder: (BuildContext context,int index){
                  //       return Padding(
                  //         padding: const EdgeInsets.all(6.0),
                  //         child: Material(
                  //           elevation: 2.0,
                  //           child: ListTile(
                  //             shape: RoundedRectangleBorder(
                  //                 borderRadius: BorderRadius.circular(10)),
                  //             tileColor: isDarkMode?Colors.black54:Colors.white,
                  //             leading: const Icon(Icons.analytics_outlined),
                  //             title: Text('${files[index]}',
                  //               style: const TextStyle(fontSize: 18),),
                  //
                  //           ),
                  //         ),
                  //       );
                  //     }
                  // );
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
