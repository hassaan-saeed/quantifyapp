import 'package:flutter/material.dart';
import 'package:quantify/Views/templateList.dart';
import 'option.dart';
import 'templateList.dart';

class Template extends StatefulWidget {
  const Template({Key? key}) : super(key: key);

  @override
  _TemplateState createState() => _TemplateState();
}

class _TemplateState extends State<Template> {

  String? selectedValue;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Container(
      child: DefaultTabController(
        length: 8,
        child: Scaffold(
          // floatingActionButton: SpeedDial(
          //
          //   // visible: TemplateList._selectedIndex != null,
          //   children: [
          //     SpeedDialChild(
          //       child: Icon(Icons.camera_alt),
          //       label: 'Capture'
          //     ),
          //     SpeedDialChild(
          //         child: Icon(Icons.photo_library_outlined),
          //         label: 'Library'
          //     )
          //   ],
          // ),
          floatingActionButton: Visibility(
            visible: selectedValue!=null,
            child: FloatingActionButton.extended(
              onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => Option())),
              label: Text("Next"),

            ),
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            // backgroundColor: Colors.white,
            elevation: 0,
            bottom: TabBar(
              isScrollable: true,
              labelColor: isDarkMode?Colors.white:Colors.black54,
              indicatorColor: isDarkMode?Colors.white:Colors.black54,
              tabs: const [
                Tab( text: "Wood", ),
                Tab(text: "Beams",),
                Tab(text: "Tubes",),
                Tab(text: "Bottles",),
                Tab(text: "Layers",),
                Tab( text: "Metals", ),
                Tab(text: "Pharma",),
                Tab(text: "Misc",)
              ],
            ),
            title: const Text('Select a Template:'),
          ),
          body: TabBarView(
            children: [
              TemplateList(cat: "Wood", onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              }),
              TemplateList(cat: "Beams",onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              }),
              TemplateList(cat: "Tubes",onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              }),
              TemplateList(cat: "Bottles",onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              }),
              TemplateList(cat: "Layers",onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              }),
              TemplateList(cat: "Metals",onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              }),
              TemplateList(cat: "Pharma",onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              }),
              TemplateList(cat: "Misc",onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              })
            ],
          ),
        ),
      ),
    );
    // return Container(
    //   alignment: Alignment.topLeft,
    //   child: Column(
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.only(top: 10, left: 20),
    //         child: Text("Select a Template: ", style: TextStyle(fontSize: 26),),
    //       ),
    //
    //     ],
    //   ),
    // );
  }
}


