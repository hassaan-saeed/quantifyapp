import 'package:flutter/material.dart';

class Files extends StatefulWidget {
  const Files({Key? key}) : super(key: key);

  @override
  _FilesState createState() => _FilesState();
}

class _FilesState extends State<Files> {

  List<_FilesData> data = [
  _FilesData("January"),
  _FilesData("February"),
  _FilesData("March"),
  _FilesData("April"),
  _FilesData("May"),
  _FilesData("June"),
  _FilesData("July"),
  _FilesData("August"),
  _FilesData("September"),
  _FilesData("October"),
  _FilesData("November"),
  _FilesData("December"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Scrollbar(
        child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context,int index){
              return ListTile(
                  leading: Icon(Icons.analytics_outlined),
                  title: Text(data[index].filename,
                    style: const TextStyle(
                        color: Colors.black54,fontSize: 18),),

              );
            }
        ),
      ),
    );
  }
}

class _FilesData{
  _FilesData(this.filename);
  final String filename;
}
