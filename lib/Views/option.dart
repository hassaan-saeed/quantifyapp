import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

late File _image;
String result = '';

class Option extends StatefulWidget {
  const Option({Key? key}) : super(key: key);

  @override
  State<Option> createState() => _OptionState();
}

class _OptionState extends State<Option> {

  ImagePicker imagePicker = ImagePicker();
  final imageLabeler = GoogleMlKit.vision.imageLabeler();

  @override
  void initState() {
    super.initState();
    _image = new File('images/image.png');
    // loadModelFiles();

  }

  Future<void> captureImageFromCamera() async{
    XFile? image = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(image!=null?image.path:"images/image.png");
    });
    doImageLabelling();
  }

  Future<void> chooseImageFromLibrary() async{
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!=null?image.path:"images/image.png");
    });
    doImageLabelling();
  }

  // loadModelFiles() async {
  //   String res = await Tflite.loadModel(
  //       model: "assets/mobilenet_v1_1.0_224.tflite",
  //       labels: "assets/mobilenet_v1_1.0_224.txt",
  //       numThreads: 1, // defaults to 1
  //       isAsset: true, // defaults to true, set to false to load resources outside assets
  //       useGpuDelegate: false // defaults to false, set to true to use GPU delegate
  //   );
  // }

  doImageLabelling() async {
    final inputImage = InputImage.fromFile(_image);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    result = "";
    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      setState(() {
        result += text+"    "+confidence.toStringAsFixed(2)+"\n";
      });

    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    imageLabeler.close();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: const Text("Select an option.."),
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
                  child: Container(child: Image.file(_image, fit: BoxFit.contain,), height: 450,),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: ()=>{chooseImageFromLibrary()},
                child: Container(
                  width: MediaQuery.of(context).size.width*0.4,
                  height: MediaQuery.of(context).size.height*0.07,
                  child: const Center(
                    child: Text("Photo Library", style: TextStyle(
                      fontSize: 24,
                    ),),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: ()=>{captureImageFromCamera()},
                child: Container(
                  width: MediaQuery.of(context).size.width*0.4,
                  height: MediaQuery.of(context).size.height*0.07,
                  child: Center(
                    child: Text("Camera", style: TextStyle(
                      fontSize: 24,
                    ),),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                child: Text(
                  '$result',
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
