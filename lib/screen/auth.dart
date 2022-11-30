import 'package:blood_donation_app/screen/home_screen.dart';
import 'package:blood_donation_app/screen/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/custom_dialogs.dart';

class AuthPage extends StatefulWidget {
  final FirebaseAuth appAuth;
  const AuthPage(this.appAuth, {Key? key}) : super(key: key);
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final formkey = GlobalKey<FormState>();
  late String _email;
  late String _password;
  bool validateSave() {
    final form = formkey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateSubmit() async {
    if (validateSave()) {
      try {
        CustomDialogs.progressDialog(context: context, message: 'Signing In');
        User? user = (await widget.appAuth
                .signInWithEmailAndPassword(email: _email, password: _password))
            .user;
        Navigator.pop(context);
        print('Signed in: ${user!.uid}');
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } catch (e) {
        print('Errr : $e');
        showDialog(
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('User Sign-In Failed !'),
                actions: <Widget>[
                  FlatButton(
                    child: const Text('OK'),
                    onPressed: () {
                      formkey.currentState!.reset();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            },
            context: context);
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
      backgroundColor: const Color(0xFFFF5864),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              child: Center(
                child: Text(
                  "Blood Donation",
                  style: GoogleFonts.rubik(
                    fontSize: 50.0,
                    color: Colors.white,
                  ),
                ),
              ),
              height: MediaQuery.of(context).size.height / 2.5,
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0)),
              child: Container(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).size.height / 2.5,
                width: double.infinity,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Form(
                          key: formkey,
                          child: Column(
                            children: <Widget>[
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
                              const SizedBox(
                                height: 30.0,
                              ),
                              ElevatedButton(
                                onPressed: validateSubmit,
                                child: const Text("LOGIN"),
                                style: ElevatedButton.styleFrom(
                                  primary:
                                      const Color.fromARGB(1000, 221, 46, 68),
                                  textStyle: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Text("New User? "),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RegisterPage(widget.appAuth),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Click here",
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(1000, 221, 46, 68),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}
