import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPass extends StatefulWidget {
  const ResetPass({Key? key}) : super(key: key);

  @override
  State<ResetPass> createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {

  final _formKey = GlobalKey<FormState>();
  String _oldPass = '';
  String _pass = '';
  String? _confPass = '';

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: value=="Password Changed Successfully"?Colors.greenAccent:Colors.redAccent,
        duration: const Duration(seconds: 5),
        content: Text(value)
    ));
  }

  void _changePassword(String password) async {
    String? email = FirebaseAuth.instance.currentUser?.email;

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.toString(),
        password: _oldPass,
      );

      FirebaseAuth.instance.currentUser?.updatePassword(password).then((_){
        showInSnackBar("Password Changed Successfully");
      }).catchError((error){
        showInSnackBar("Password can't be changed" + error.toString());
        //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showInSnackBar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showInSnackBar('Wrong password provided for that user.');
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text("Update Password")),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 40, right: 40, bottom: 30),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Please enter a password!';
                      }
                      else if(value.length < 8){
                        return 'Password must be 8 characters long!';
                      }
                      else{
                        return null;
                      }
                    },
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(
                      labelText: 'Enter Old Password',
                      border: UnderlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    onChanged: (text) {
                      _oldPass = text;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 40, right: 40, bottom: 10),
                  child: TextFormField(
                    validator: (value){
                      _confPass = value;
                      if(value!.isEmpty){
                        return 'Please enter a password!';
                      }
                      else if(value.length < 8){
                        return 'Password must be 8 characters long!';
                      }
                      else{
                        return null;
                      }
                    },
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(
                      labelText: 'Enter New Password',
                      border: UnderlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    onChanged: (text) {
                      _pass = text;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 40, right: 40, bottom: 10),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Please enter a password!';
                      }
                      else if(value.length < 8){
                        return 'Password must be 8 characters long!';
                      }
                      else if(value != _confPass){
                        return 'Password must be same as above!';
                      }
                      else{
                        return null;
                      }
                    },
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(
                      labelText: 'Enter New Password Again',
                      border: UnderlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                  ),
                ),
              ],
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              onPressed: ()=>{
                if(_formKey.currentState!.validate()){
                  _changePassword(_pass)
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width*0.4,
                height: MediaQuery.of(context).size.height*0.07,
                child: const Center(
                  child: Text("Confirm", style: TextStyle(
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
