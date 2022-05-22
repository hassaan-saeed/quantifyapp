import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'addfiles.dart';

String result = '';

class Option extends StatefulWidget {
  const Option({Key? key, required this.category, required this.template}) : super(key: key);

  final String category;
  final String template;

  @override
  State<Option> createState() => _OptionState();
}

class _OptionState extends State<Option> {
  ImagePicker imagePicker = ImagePicker();
  late File _image;

  var currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _image = new File('images/image.png');
    // loadModelFiles();
  }

  Future<void> captureImageFromCamera() async {
    XFile? image = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(image != null ? image.path : "images/image.png");
    });
    requestResult();
  }

  Future<void> chooseImageFromLibrary() async {
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image != null ? image.path : "images/image.png");
    });
    requestResult();
  }

  mkdir(imageInUnit8List) async {
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.png').create();
    file.writeAsBytesSync(imageInUnit8List);
    _image = file;
  }

  requestResult() async {
    result = '';
    List<int> imageBytes = _image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    print(base64Image);

    var url = Uri.parse('http://192.168.100.76:5000/${widget.template.toLowerCase()}');
    var response = await http.post(url, body: base64Image);
    var splitRes = response.body.split(" ");
    print(response.body);
    var res = splitRes[0];
    var im = splitRes[1];
    setState(() {
      print(res);
      result = res;
      print(im);
      Uint8List imageInUnit8List = base64Decode(im) ;
      mkdir(imageInUnit8List);

    });
    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 5),
        content: Text(value)));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    result = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: const Text("Quantify"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  color: Colors.transparent,
                  child: Container(
                    child: Image.file(
                      _image,
                      fit: BoxFit.contain,
                    ),
                    height: 450,
                  ),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.11,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      onPressed: () => {chooseImageFromLibrary()},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 30,
                            ),
                            Text(
                              "Photo Library",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.11,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      onPressed: () => {captureImageFromCamera()},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 30,
                            ),
                            Text(
                              "Camera",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Visibility(
                visible: result!='',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          color: Colors.redAccent.shade200,
                          child: Center(
                            child: Text("Result : $result", style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.greenAccent.shade400,
                            onPrimary: Colors.black87,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                        onPressed: () => {
                          if(currentUser?.isAnonymous == true){
                            showInSnackBar("Must be Logged In")
                          }
                          else{
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddFile(count: result, category: widget.category, template: widget.template,)))
                          }

                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.save_outlined,
                                size: 30,
                              ),
                              SizedBox(width: 6,),
                              Text(
                                "Save",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
