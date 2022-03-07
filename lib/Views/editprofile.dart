import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

late File _image;

class _EditProfileState extends State<EditProfile> {

  final _formKey = GlobalKey<FormState>();
  ImagePicker imagePicker = ImagePicker();
  String name = '';
  String type = 'Select Type';

  Future<void> chooseImageFromLibrary() async{
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!=null?image.path:"images/image.png");
    });
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value)
    ));
  }

  save() async {
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).set(
        {
          "name" : name,
          "type" : type,
          // "profilepic" : _image
        }, SetOptions(merge: true))
        .then((value) => {
          Navigator.pop(context)
    }).catchError((error)=> showInSnackBar(error));

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _image = File('images/image.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text("Edit Profile")),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 10),
                child: TextFormField(
                  validator: (value){
                    return value!.isEmpty ? 'PLease enter a name!' : null;
                  },
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    labelText: 'Enter Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (text) {
                    name = text;
                  },
                ),
              ),
              const SizedBox(height: 20,),
              Container(
                width: MediaQuery.of(context).size.width*0.78,
                height: MediaQuery.of(context).size.height*0.08,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(top: BorderSide(width: 1, color: Colors.black38), bottom: BorderSide(width: 1, color: Colors.black38), right: BorderSide(width: 1, color: Colors.black38), left: BorderSide(width: 1, color: Colors.black38))
                ),
                child: Center(
                  child: DropdownButton<String>(
                    value: type,
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
                        type = newValue!;
                      });
                    },
                    items: <String>['Select Type','Individual', 'Business']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: ()=>{chooseImageFromLibrary()},
                child: Container(
                  width: MediaQuery.of(context).size.width*0.7,
                  height: MediaQuery.of(context).size.height*0.07,
                  child: const Center(
                    child: Text("Upload Profile Pic", style: TextStyle(
                      fontSize: 24,
                    ),),
                  ),
                ),
              ),
              const SizedBox(height: 50,),
              ElevatedButton(
                onPressed: ()=>{
                  if(_formKey.currentState!.validate()){
                    save()
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width*0.4,
                  height: MediaQuery.of(context).size.height*0.07,
                  child: const Center(
                    child: Text("Save", style: TextStyle(
                      fontSize: 24,
                    ),),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
