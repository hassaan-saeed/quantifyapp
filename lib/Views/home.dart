import 'package:flutter/material.dart';
import 'package:quantify/Views/template.dart';

import 'account.dart';
import 'files.dart';
import 'graph.dart';

class Home extends StatefulWidget {
  const Home({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _HomeState createState() => _HomeState();

}

class _HomeState extends State<Home> {

  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    AccountInfo(),
    Template(),
    Files(),
    Graph()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text(widget.title!)),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        // backgroundColor: Colors.green,
        // selectedItemColor: Colors.black38,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Files',

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
