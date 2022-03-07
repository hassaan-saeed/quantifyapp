import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Graph extends StatefulWidget {
  const Graph({Key? key}) : super(key: key);

  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  
  List<_GraphData> data = [
    _GraphData('Wood', 185),
    _GraphData('Beams', 138),
    _GraphData('Tubes', 74),
    _GraphData('Bottles', 162),
    _GraphData('Layers', 140),
    _GraphData('Metals', 114),
    _GraphData('Pharma', 32),
    _GraphData('Misc', 162)
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
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
    );
  }
}

class _GraphData {
  _GraphData(this.category, this.count);

  final String category;
  final double count;
}
