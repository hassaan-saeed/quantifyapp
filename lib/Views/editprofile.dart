import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}


class _EditProfileState extends State<EditProfile> {

  final _formKey = GlobalKey<FormState>();
  ImagePicker imagePicker = ImagePicker();
  String name = '';
  String type = 'Select Type';
  File? _image;

  Future<void> chooseImageFromLibrary() async{
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if(image!=null){
        _image = File(image.path);
      }
    });
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 5),
        content: Text(value)
    ));
  }

  Future<void> save() async {
    // if(FirebaseAuth.instance.currentUser.)
    if(name!=''){
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).set(
          {
            "name" : name,
          }, SetOptions(merge: true))
          .then((value) => {
      }).catchError((error)=> showInSnackBar(error));
    }

    try {
      if(_image!=null){
        await FirebaseStorage.instance
            .ref('profilepics/${FirebaseAuth.instance.currentUser?.uid}')
            .putFile(_image!);
      }
    } on FirebaseException catch (e) {
      print(e);
    }
    // Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('profilepics/${FirebaseAuth.instance.currentUser?.uid}');
    // UploadTask uploadTask = firebaseStorageRef.putFile(_image!);
    // TaskSnapshot taskSnapshot = await uploadTask.snapshot;
    // taskSnapshot.ref.getDownloadURL().then(
    //       (value) => print("Done: $value"),
    // );
    Navigator.pop(context);
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _image = File('images/image.png');
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text("Edit Profile")),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: isDarkMode?Colors.amberAccent:Colors.lightBlueAccent,
                    child: TextButton(
                        onPressed: ()=>{chooseImageFromLibrary()},
                        child: _image==null?
                        Icon(Icons.add_photo_alternate_outlined,size: 50, color: isDarkMode?Colors.black:Colors.white,)
                            :
                        ClipOval(
                          child: SizedBox.fromSize(
                              size: Size.fromRadius(60),
                              child: Image.file(_image!, fit: BoxFit.cover)
                          ),
                        )

                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 40, right: 40, bottom: 10),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty){
                        return null;
                      }
                      else if(value.length >=17){
                        return 'Name should be less than 17 characters!';
                      }
                      else{
                        return null;
                      }
                    },
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Enter Name',
                      border: UnderlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    onChanged: (text) {
                      name = text;
                    },
                  ),
                ),
              ],
            ),


            // Container(
            //   width: MediaQuery.of(context).size.width*0.78,
            //   height: MediaQuery.of(context).size.height*0.08,
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(10),
            //       border: const Border(top: BorderSide(width: 1, color: Colors.black38), bottom: BorderSide(width: 1, color: Colors.black38), right: BorderSide(width: 1, color: Colors.black38), left: BorderSide(width: 1, color: Colors.black38))
            //   ),
            //   child: Center(
            //     child: DropdownButton<String>(
            //       value: type,
            //       icon: const Icon(Icons.arrow_downward),
            //       iconSize: 28,
            //       elevation: 16,
            //       style: const TextStyle(color: Colors.black87, fontSize: 22),
            //       underline: Container(
            //         height: 1,
            //         color: Colors.green.shade700,
            //       ),
            //       onChanged: (String? newValue) {
            //         setState(() {
            //           type = newValue!;
            //         });
            //       },
            //       items: <String>['Select Type','Individual', 'Business']
            //           .map<DropdownMenuItem<String>>((String value) {
            //         return DropdownMenuItem<String>(
            //           value: value,
            //           child: Text(value),
            //         );
            //       }).toList(),
            //     ),
            //   ),
            // ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
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
    );
  }
}
