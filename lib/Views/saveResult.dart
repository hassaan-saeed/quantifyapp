import 'package:flutter/material.dart';


class SaveResult extends StatefulWidget {
  const SaveResult({Key? key}) : super(key: key);

  @override
  State<SaveResult> createState() => _SaveResultState();
}



class _SaveResultState extends State<SaveResult> {

  String dropdownValue = "Wood";
  late String dropdownTypeValue;

  final List<_TemplateData> data = [
    _TemplateData("Logs","Wood","images/Woods/Logs.jpg"),
    _TemplateData("Logs in Shape","Wood","images/Woods/LogsinShape.jpg"),
    _TemplateData("Rectangle","Wood","images/Woods/Rectangle.jpg"),
    _TemplateData("Flat","Wood","images/Woods/Flat.jpg"),
    _TemplateData("Planks","Wood","images/Woods/Planks.jpg"),

    _TemplateData("Channel","Beams","images/Beams/Channel.jpg"),
    _TemplateData("Rebars","Beams","images/Beams/Rebars.jpg"),
    _TemplateData("Rebars2","Beams","images/Beams/Rebars2.jpeg"),
    _TemplateData("Flat","Beams","images/Beams/Flat.jpg"),
    _TemplateData("Square Channel","Beams","images/Beams/SquareChannel.jpg"),

    _TemplateData("Metal","Tubes","images/Tubes/Metal.jpeg"),
    _TemplateData("Test","Tubes","images/Tubes/Test.jpeg"),
    _TemplateData("Pop","Tubes","images/Tubes/Pop.jpg"),
    _TemplateData("Card-board","Tubes","images/Tubes/Cardboard.jpg"),
    _TemplateData("Nesting","Tubes","images/Tubes/Nesting.jpg"),

    _TemplateData("Plastic","Bottles","images/Bottles/Plastic.jpg"),
    _TemplateData("Glass","Bottles","images/Bottles/Glass.jpg"),
    _TemplateData("Steel","Bottles","images/Bottles/Steel.jpg"),
    _TemplateData("Sports","Bottles","images/Bottles/Sports.jpg"),
    _TemplateData("Dispenser","Bottles","images/Bottles/Dispenser.jpg"),

    _TemplateData("CurvedLines","Layers","images/Layers/CurvedLines.png"),
    _TemplateData("HorizontalLines","Layers","images/Layers/HorizontalLines.png"),
    _TemplateData("DottedLines","Layers","images/Layers/DottedLines.png"),
    _TemplateData("VerticalLines","Layers","images/Layers/VerticalLines.png"),
    _TemplateData("Diagonal Lines","Layers","images/Layers/DiagnolLines.jpg"),

    _TemplateData("Wires","Metals","images/Metals/Wires.jpg"),
    _TemplateData("Sheets","Metals","images/Metals/Sheets.jpg"),
    _TemplateData("Balls","Metals","images/Metals/Balls.jpg"),
    _TemplateData("Tubes","Metals","images/Metals/Tubes.jpg"),
    _TemplateData("Bricks","Metals","images/Metals/Bricks.jpg"),

    _TemplateData("Capsules","Pharma","images/Pharma/Capsules.jpg"),
    _TemplateData("Tablet1","Pharma","images/Pharma/Tablets1.jpg"),
    _TemplateData("Tablet2","Pharma","images/Pharma/Tablet2.jpg"),
    _TemplateData("Drip","Pharma","images/Pharma/Drip.jpg"),
    _TemplateData("Boxes","Pharma","images/Pharma/Boxes.jpg"),

  ];

  final List<String> templates = ['Wood', 'Beams', 'Tubes', 'Bottles', 'Layers', 'Metals', 'Pharma'];
  List<String> templateTypes = [];

  setTypes(String value){
    Iterable _filteredData = data.where((i) => i.category == value).map((e) => templateTypes.add(e.tempName));
    // filteredData =  List.from(_filteredData);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setTypes(dropdownValue);
    dropdownTypeValue = templateTypes[0];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: const Text("Select an option.."),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 28,
              elevation: 16,
              style: const TextStyle(color: Colors.black87, fontSize: 22),
              underline: Container(
                height: 1,
                color: Colors.green.shade700,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                  setTypes(dropdownValue);
                });
              },
              items: templates
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: dropdownTypeValue,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 28,
              elevation: 16,
              style: const TextStyle(color: Colors.black87, fontSize: 22),
              underline: Container(
                height: 1,
                color: Colors.green.shade700,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownTypeValue = newValue!;
                  setTypes(dropdownTypeValue);
                });
              },
              items: templateTypes
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}


class _TemplateData{

  _TemplateData(this.tempName,this.category , this.imagePath);
  final String tempName;
  final String category;
  final String imagePath;
}