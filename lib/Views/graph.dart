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

  List<_GraphData> data = [
    _GraphData('Wood', 0),
    _GraphData('Beams', 0),
    _GraphData('Tubes', 0),
    _GraphData('Bottles', 0),
    _GraphData('Layers', 0),
    _GraphData('Metals', 0),
    _GraphData('Pharma', 0),
    _GraphData('Misc', 0)
  ];

  Future<void> getData() async {

    await FirebaseFirestore.instance.collection('files').doc(FirebaseAuth.instance.currentUser?.uid).collection('records').get()
        .then((QuerySnapshot querySnapshot) {
      data = [
        _GraphData('Wood', 0),
        _GraphData('Beams', 0),
        _GraphData('Tubes', 0),
        _GraphData('Bottles', 0),
        _GraphData('Layers', 0),
        _GraphData('Metals', 0),
        _GraphData('Pharma', 0),
        _GraphData('Misc', 0)
      ];
      for (var doc in querySnapshot.docs) {
        FirebaseFirestore.instance
            .collection('files')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('records')
            .doc(doc['name'])
            .collection('results')
            .get()
            .then((QuerySnapshot querySnapshot) {
          // reports = [];
          for (var doc in querySnapshot.docs) {
            for(var d in data){
              if(d.category == doc['category']){
                d.count+=int.parse(doc['count']);
                print(doc['count']);
                print(d.count);
              }
            }
            print(data);
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
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Container(
      color: isDarkMode?Colors.black54:Colors.white,
      height: MediaQuery.of(context).size.height,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SfCartesianChart(
                title: ChartTitle(text: 'Weekly', textStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),

                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(minimum: 0, maximum: 200, interval: 50),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <ChartSeries<_GraphData, String>>[
                    ColumnSeries<_GraphData, String>(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0),topRight: Radius.circular(6.0),),
                        dataSource: data,
                        xValueMapper: (_GraphData data, _) => data.category,
                        yValueMapper: (_GraphData data, _) => data.count,
                        name: 'Report',
                        color: Colors.teal
                    )
                  ]),
            ),
            //Initialize the chart widget
            SfCircularChart(
                // primaryXAxis: CategoryAxis(),
                // Chart title
                title: ChartTitle(text: 'Monthly', textStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                // Enable legend
                legend: Legend(isVisible: true),
                // Enable tooltip
                tooltipBehavior: TooltipBehavior(enable: true),

                series: <PieSeries<_GraphData, String>>[
                  PieSeries<_GraphData, String>(
                      radius: '90%',
                      explode: true,
                      dataSource: data,
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
