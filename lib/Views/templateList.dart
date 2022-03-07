import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';


class TemplateList extends StatefulWidget {
  const TemplateList({Key? key, this.cat}) : super(key: key);

  final String? cat;

  @override
  _TemplateListState createState() => _TemplateListState();
}

class _TemplateListState extends State<TemplateList> {


  String? _selectedIndex;

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

  List<_TemplateData> filteredData = [];



  _onSelected(String index) {
    setState(() => _selectedIndex = index);
  }


  @override
  Widget build(BuildContext context) {

    Iterable _filteredData = data.where((i) => i.category == widget.cat);
    filteredData =  List.from(_filteredData);

    return Container(
      padding: EdgeInsets.all(10),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
          ),
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 6,
                    offset: Offset( 0.5, 0)
                  )]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GridTile(
                    footer: GridTileBar(
                      backgroundColor: _selectedIndex == filteredData[index].tempName ? Colors.green.shade300 : Colors.white,
                        title: Center(child: AutoSizeText(filteredData[index].tempName, style: TextStyle(fontSize: 16, color: Colors.black87), maxLines: 2,))
                    ),
                    child: GestureDetector(
                      child: Image.asset(filteredData[index].imagePath, fit: BoxFit.cover,),
                      onTap: () => _onSelected(filteredData[index].tempName),
                    ),
                  ),
                ),
              ),
            );
            }


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

