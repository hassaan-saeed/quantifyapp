import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AddNewSubAcc extends StatefulWidget {
  const AddNewSubAcc({Key? key}) : super(key: key);

  @override
  State<AddNewSubAcc> createState() => _AddNewSubAccState();
}

class _AddNewSubAccState extends State<AddNewSubAcc> {

  final _formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String _name = '';
  String _email = '';
  String _pass = '';

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: value=="Sub-Account Created"?Colors.greenAccent:Colors.redAccent,
        duration: const Duration(seconds: 5),
        content: Text(value)
    ));
  }

  Future<UserCredential> register(String email, String password) async {
    FirebaseApp app = await Firebase.initializeApp(name: 'Secondary', options: Firebase.app().options);
    late UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instanceFor(app: app).createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance.collection('subaccounts').doc(userCredential.user?.uid).set(
          {
            "email" : _email,
            "name" : _name,
            "manager" : FirebaseAuth.instance.currentUser?.uid,
            "type" : "subaccount"
          });
    }on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'weak-password') {
        showInSnackBar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showInSnackBar('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        showInSnackBar('The email is not correct.');
      }
    }
    catch (e) {print(e);}
    await app.delete();
    return Future.sync(() => userCredential);
  }

  createSubAcc() async {
    try {
      register(_email, _pass);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showInSnackBar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showInSnackBar('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    showInSnackBar("Sub-Account Created");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("Add Sub-Account")),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10,),
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width*0.78,
                    height: MediaQuery.of(context).size.height*0.08,
                    child: TextFormField(
                      validator: (value){
                        if(value!.isEmpty){
                          return 'PLease enter a name!';
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
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      onChanged: (text) {
                        _name = text;
                      },
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Container(
                    width: MediaQuery.of(context).size.width*0.78,
                    height: MediaQuery.of(context).size.height*0.08,
                    child: TextFormField(
                      validator: (value){
                        return value!.isEmpty ? 'PLease enter an email!' : null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Enter Email',
                        border: UnderlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      onChanged: (text) {
                        _email = text;
                      },
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Container(
                    width: MediaQuery.of(context).size.width*0.78,
                    height: MediaQuery.of(context).size.height*0.08,
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
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Enter Password',
                        border: UnderlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      onChanged: (text) {
                        _pass = text;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: ()=>{
                  if(_formKey != null){
                    if(_formKey.currentState!.validate()){
                      createSubAcc()
                    }
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width*0.4,
                  height: MediaQuery.of(context).size.height*0.07,
                  child: const Center(
                    child: Text("ADD", style: TextStyle(
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
