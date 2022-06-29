import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;

class Graph extends StatefulWidget {
  const Graph({Key? key}) : super(key: key);

  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  late GlobalKey<SfCircularChartState> _circularChartKey;
  late GlobalKey<SfCartesianChartState> _cartesianChartKey;

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

  Future<void> _renderPDF() async {
    final List<int> imageBytes = await _readImageData();
    final PdfBitmap bitmap = PdfBitmap(imageBytes);
    final PdfDocument document = PdfDocument();
    document.pageSettings.size =
        Size(bitmap.width.toDouble(), bitmap.height.toDouble());
    final PdfPage page = document.pages.add();
    final Size pageSize = page.getClientSize();
    page.graphics.drawImage(
        bitmap, Rect.fromLTWH(0, 0, pageSize.width, pageSize.height));

    final List<int> imageBytes2 = await _readImageData2();
    final PdfBitmap bitmap2 = PdfBitmap(imageBytes2);
    document.pageSettings.size =
        Size(bitmap2.width.toDouble(), bitmap2.height.toDouble());
    final PdfPage page2 = document.pages.add();
    final Size pageSize2 = page2.getClientSize();
    page2.graphics.drawImage(
        bitmap2, Rect.fromLTWH(0, 0, pageSize2.width, pageSize2.height));

    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String path = appDocumentsDirectory.path; // 2
    final File file = File('$path/charts.pdf');
    await file.writeAsBytes(document.save(), flush: true);

    String filePath = '$path/charts.pdf';

    Share.shareFiles([filePath]);
  }

  Future<List<int>> _readImageData() async {
    final ui.Image data =
        await _circularChartKey.currentState!.toImage(pixelRatio: 3.0);
    final ByteData? bytes =
        await data.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }

  Future<List<int>> _readImageData2() async {
    final ui.Image data =
        await _cartesianChartKey.currentState!.toImage(pixelRatio: 3.0);
    final ByteData? bytes =
        await data.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }

  Future<void> _refresh() async {
    setState(() {
      getData();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _circularChartKey = GlobalKey();
    _cartesianChartKey = GlobalKey();
    setState(() {
      getData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: () => {_renderPDF()},
        child: const Icon(Icons.ios_share),
      ),
      body: Container(
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
                        key: _cartesianChartKey,
                        title: ChartTitle(
                            text: 'Weekly',
                            textStyle: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                        primaryXAxis: CategoryAxis(),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <ChartSeries<_GraphData, String>>[
                          ColumnSeries<_GraphData, String>(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6.0),
                                topRight: Radius.circular(6.0),
                              ),
                              dataSource: dataWeek,
                              xValueMapper: (_GraphData data, _) =>
                                  data.category,
                              yValueMapper: (_GraphData data, _) => data.count,
                              name: 'Report',
                              color: Colors.teal)
                        ]),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //Initialize the chart widget
                  SfCircularChart(
                      key: _circularChartKey,
                      // primaryXAxis: CategoryAxis(),
                      // Chart title
                      title: ChartTitle(
                          text: 'Monthly',
                          textStyle: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold)),
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
                            dataLabelSettings:
                                DataLabelSettings(isVisible: true)
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
      ),
    );
  }
}

class _GraphData {
  _GraphData(this.category, this.count);

  String category;
  double count;
}
