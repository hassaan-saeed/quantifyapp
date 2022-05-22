import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Graph extends StatefulWidget {
  const Graph({Key? key}) : super(key: key);

  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  List<_GraphData> dataMonth = [
    _GraphData('Furniture', 0),
    _GraphData('Metals', 0),
    _GraphData('Vehicles', 0),
    _GraphData('Misc', 0)
  ];

  List<_GraphData> dataWeek = [
    _GraphData('Furniture', 0),
    _GraphData('Metals', 0),
    _GraphData('Vehicles', 0),
    _GraphData('Misc', 0)
  ];

  Future<void> getData() async {
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
        .get()
        .then((QuerySnapshot querySnapshot) {
      dataMonth = [
        _GraphData('Furniture', 0),
        _GraphData('Metals', 0),
        _GraphData('Vehicles', 0),
        _GraphData('Misc', 0)
      ];

      dataWeek = [
        _GraphData('Furniture', 0),
        _GraphData('Metals', 0),
        _GraphData('Vehicles', 0),
        _GraphData('Misc', 0)
      ];
      for (var doc in querySnapshot.docs) {
        FirebaseFirestore.instance
            .collection('files')
            .doc(_dataUser)
            .collection('records')
            .doc(doc['name'])
            .collection('results')
            .get()
            .then((QuerySnapshot querySnapshot) {
          // reports = [];
          for (var doc in querySnapshot.docs) {
            DateTime date = doc['date'].toDate();
            print(DateTime.now().difference(date).inDays);
            if (DateTime.now().difference(date).inDays < 7) {
              for (var d in dataWeek) {
                if (d.category == doc['category']) {
                  d.count += int.parse(doc['count']);
                  print(doc['count']);
                  print(d.count);
                }
              }
            }
            if (DateTime.now().difference(date).inDays < 31) {
              for (var d in dataMonth) {
                if (d.category == doc['category']) {
                  d.count += int.parse(doc['count']);
                  print(doc['count']);
                  print(d.count);
                }
              }
            }

            print(dataWeek[0].count.runtimeType);
          }
        });
      }
    });
    return Future.value("Files download successfully");
  }

  Future<void> _refresh() async {
    setState(() {
      getData();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Container(
      color: isDarkMode ? Colors.black54 : Colors.white,
      height: MediaQuery.of(context).size.height,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SfCartesianChart(
                  title: ChartTitle(
                      text: 'Weekly',
                      textStyle:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  primaryXAxis: CategoryAxis(),

                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <ChartSeries<_GraphData, String>>[
                    ColumnSeries<_GraphData, String>(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6.0),
                          topRight: Radius.circular(6.0),
                        ),
                        dataSource: dataWeek,
                        xValueMapper: (_GraphData data, _) => data.category,
                        yValueMapper: (_GraphData data, _) => data.count,
                        name: 'Report',
                        color: Colors.teal)
                  ]),
            ),
            const SizedBox(height: 20,),
            //Initialize the chart widget
            SfCircularChart(
                // primaryXAxis: CategoryAxis(),
                // Chart title
                title: ChartTitle(
                    text: 'Monthly',
                    textStyle:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                // Enable legend
                legend: Legend(isVisible: true),
                // Enable tooltip
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <PieSeries<_GraphData, String>>[
                  PieSeries<_GraphData, String>(
                      radius: '90%',
                      explode: true,
                      dataSource: dataMonth,
                      xValueMapper: (_GraphData data, _) => data.category,
                      yValueMapper: (_GraphData data, _) => data.count,
                      name: 'Report',
                      // Enable data label
                      dataLabelSettings: DataLabelSettings(isVisible: true)
                      // dataLabelSettings: DataLabelSettings(
                      // margin: const EdgeInsets.all(0),
                      // isVisible: true,
                      // labelPosition: ChartDataLabelPosition.outside,
                      // connectorLineSettings: const ConnectorLineSettings(
                      // type: ConnectorType.curve, length: '20%'),
                      // labelIntersectAction: _labelIntersectAction)
                      )
                ]),
          ]),
        ),
      ),
    );
  }
}

class _GraphData {
  _GraphData(this.category, this.count);

  String category;
  double count;
}
