import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:location/location.dart' as loc;
// import 'package:geocoding/geocoding.dart';

class AddFile extends StatefulWidget {
  const AddFile(
      {Key? key,
      required this.category,
      required this.template,
      required this.count})
      : super(key: key);

  final String category;
  final String template;
  final String count;

  @override
  State<AddFile> createState() => _AddFileState();
}

class _AddFileState extends State<AddFile> {
  String name = '';
  int? selectedIndex;
  List<String> files = [];

  // loc.Location location = loc.Location();
  // String _address = '';

  // late bool _serviceEnabled;
  // late loc.PermissionStatus _permissionGranted;
  // late loc.LocationData _locationData;

  // checkLoc() async {
  //   _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await location.requestService();
  //     if (!_serviceEnabled) {
  //       return;
  //     }
  //   }
  //
  //   _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == loc.PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != loc.PermissionStatus.granted) {
  //       return;
  //     }
  //   }
  //
  //   _locationData = await location.getLocation();
  //   GetAddressFromLatLong(_locationData.latitude, _locationData.longitude);
  // }

  // Future<void> GetAddressFromLatLong(double? lat, double? lang)async {
  //   List<Placemark> placemarks = await placemarkFromCoordinates(lat!, lang!);
  //   print(placemarks);
  //   Placemark place = placemarks[0];
  //   _address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
  //   print(_address);
  // }

  @override
  void initState() {
    super.initState();
    // checkLoc();
  }

  Future<void> getFiles() async {
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
      files = [];
      for (var doc in querySnapshot.docs) {
        files.add(doc['name']);
        print(files);
      }
    });
    return Future.value("Files download successfully");
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            value == "Record Added" ? Colors.greenAccent : Colors.redAccent,
        duration: const Duration(seconds: 5),
        content: Text(value)));
  }

  Future<void> addFile() async {
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
        .doc(name)
        .set({"name": name});
    await FirebaseFirestore.instance
        .collection('files')
        .doc(_dataUser)
        .collection('records')
        .doc(name)
        .collection('results')
        .add({
          "category": widget.category,
          "template": widget.template,
          "count": widget.count,
          "date": DateTime.now(),
          "user": currentUser?.email,
          // "loc": _address
        })
        .then((value) => {showInSnackBar("Record Added")})
        .catchError((error) => showInSnackBar(error));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add to File"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height*0.7,
              child: FutureBuilder(
                future: getFiles(),
                builder:
                    (BuildContext context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return ListView.builder(
                        itemCount: files.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Material(
                              elevation: 2.0,
                              child: ListTile(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                    name = files[index];
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                tileColor: isDarkMode
                                    ? selectedIndex == index
                                        ? Colors.amber
                                        : Colors.black54
                                    : selectedIndex == index
                                        ? Colors.lightBlueAccent
                                        : Colors.white,
                                leading: const Icon(Icons.analytics_outlined),
                                title: Text(
                                  '${files[index]}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          );
                        });
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              onPressed: () => {
                if (selectedIndex != null) {addFile()}
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.07,
                child: const Center(
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
