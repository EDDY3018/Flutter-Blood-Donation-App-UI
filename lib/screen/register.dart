import 'package:blood_donation_app/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/custom_dialogs.dart';

class RegisterPage extends StatefulWidget {
  final FirebaseAuth appAuth;
  const RegisterPage(this.appAuth, {Key? key}) : super(key: key);
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formkey = GlobalKey<FormState>();
  late String _email;
  late String _password;
  late String _name;
  final List<String> _bloodGroup = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  String _selected = '';
  bool _categorySelected = false;
  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addData(_user) async {
    if (isLoggedIn()) {
      FirebaseFirestore.instance
          .collection('User Details')
          .doc(_user['uid'])
          .set(_user)
          .catchError((e) {
        print(e);
      });
    } else {
      print('You need to be logged In');
    }
  }

  bool validateSave() {
    final form = formkey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateSubmit(BuildContext context) async {
    if (validateSave()) {
      try {
        CustomDialogs.progressDialog(
            context: context, message: 'Registration under process');
        User? user = (await widget.appAuth.createUserWithEmailAndPassword(
                email: _email, password: _password))
            .user;
        Navigator.pop(context);
        print('Registered User: ${user!.uid}');
        final Map<String, dynamic> userDetails = {
          'uid': user.uid,
          'name': _name,
          'email': _email,
          'bloodgroup': _selected,
        };
        addData(userDetails).then((result) {
          print("User Added");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        }).catchError((e) {
          print(e);
        });
      } catch (e) {
        print('Errr : $e');
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: const Text('Registration Failed'),
                content: Text('Error : $e'),
                actions: <Widget>[
                  FlatButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      })
                ],
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //top bar color
      systemNavigationBarColor: Colors.black, //bottom bar color
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: const Color.fromARGB(1000, 221, 46, 68),
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "Register",
          style: GoogleFonts.rubik(
            fontSize: 40.0,
            color: Colors.white,
          ),
        ),
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
        child: Container(
          height: 800.0,
          width: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: formkey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Name',
                            icon: Icon(
                              FontAwesomeIcons.user,
                              color: Color.fromARGB(1000, 221, 46, 68),
                            ),
                          ),
                          validator: (value) => value!.isEmpty
                              ? "Name field can't be empty"
                              : null,
                          onSaved: (value) => _name = value!,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Email ID',
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Color.fromARGB(1000, 221, 46, 68),
                            ),
                          ),
                          validator: (value) => value!.isEmpty
                              ? "Email ID field can't be empty"
                              : null,
                          onSaved: (value) => _email = value!.trim(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Password',
                            icon: Icon(
                              FontAwesomeIcons.userLock,
                              color: Color.fromARGB(1000, 221, 46, 68),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) => value!.isEmpty
                              ? "Password field can't be empty"
                              : null,
                          onSaved: (value) => _password = value!,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: DropdownButton(
                          hint: const Text(
                            'Please choose a Blood Group',
                            style: TextStyle(
                              color: Color.fromARGB(1000, 221, 46, 68),
                            ),
                          ),
                          iconSize: 40.0,
                          items: _bloodGroup.map((val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(val),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(
                              () {
                                _selected = newValue as String;
                                _categorySelected = true;
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        _selected,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Color.fromARGB(1000, 221, 46, 68),
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      RaisedButton(
                        onPressed: () => validateSubmit(context),
                        textColor: Colors.white,
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        color: const Color.fromARGB(1000, 221, 46, 68),
                        child: const Text("REGISTER"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
