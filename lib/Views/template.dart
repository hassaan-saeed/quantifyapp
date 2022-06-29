import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'option.dart';

class Template extends StatefulWidget {
  const Template({Key? key}) : super(key: key);

  @override
  _TemplateState createState() => _TemplateState();
}

class _TemplateState extends State<Template> {
  int? _selectedIndex;
  String category = '';
  String template = '';

  final List<_TemplateData> data = [
    _TemplateData("Chairs", "Furniture", "images/chairs.jpg"),
    _TemplateData("Dining-Tables", "Furniture", "images/tables.jpg"),
    _TemplateData("Beds", "Furniture", "images/beds.jpg"),
    _TemplateData("Cups", "Misc", "images/cups.jpg"),
    _TemplateData("Books", "Misc", "images/books.jpg"),
    _TemplateData("Bottles", "Misc", "images/bottles.jpg"),
    _TemplateData("Mouse", "Misc", "images/mouse.jpg"),
    _TemplateData("Keyboards", "Misc", "images/keyboards.jpg"),
    _TemplateData("Backpacks", "Misc", "images/backpacks.jpg"),
    _TemplateData("Laptops", "Misc", "images/laptops.jpg"),
    _TemplateData("Cars", "Vehicles", "images/cars.jpg"),
    _TemplateData("Motorcycles", "Vehicles", "images/motorcycles.jpg"),
    _TemplateData("Bicycles", "Vehicles", "images/bicycles.jpg"),
    _TemplateData("Trucks", "Vehicles", "images/trucks.jpg"),
  ];

  _onSelected(int index) {
    setState(() => {
      _selectedIndex = index,
      category = data[index].category,
      template = data[index].tempName
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Container(
        child: Scaffold(
      floatingActionButton: Visibility(
        visible: _selectedIndex != null,
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Option(
                        template: template,
                        category: category,
                      ))),
          label: Text("Next"),
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // backgroundColor: Colors.white,
        elevation: 0,

        title: const Text('Select a Template:'),
      ),
      body: Container(
        color: isDarkMode ? Colors.black45 : Colors.grey.shade200,
        padding: EdgeInsets.all(10),
        child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 3,
                        blurRadius: 6,
                        offset: Offset(0.5, 0))
                  ]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GridTile(
                      footer: GridTileBar(
                          backgroundColor: _selectedIndex == index
                              ? Colors.redAccent
                              : isDarkMode
                                  ? Colors.black87
                                  : Colors.white70,
                          title: Center(
                              child: AutoSizeText(
                            data[index].tempName,
                            style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87),
                            maxLines: 2,
                          ))),
                      child: GestureDetector(
                        child: Image.asset(
                          data[index].imagePath,
                          fit: BoxFit.cover,
                        ),
                        onTap: () => _onSelected(index),
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    ));
  }
}

class _TemplateData {
  _TemplateData(this.tempName, this.category, this.imagePath);
  final String tempName;
  final String category;
  final String imagePath;
}
