import 'package:blood_donation_app/screen/profile_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';

class PhoneNumberAuth extends StatefulWidget {
  const PhoneNumberAuth({Key? key}) : super(key: key);

  @override
  _PhoneNumberState createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumberAuth> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController otpCode = TextEditingController();

  OutlineInputBorder border = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.redAccent, width: 3.0));

  bool isLoading = false;
  String _name = "";
  String? verificationId;

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  void signInWithPhoneNumber() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpCode.text,
      );

      final User? user = (await _auth.signInWithCredential(credential)).user;

      showSnackbar("Successfully signed in UID: ${user!.uid}");

      Map<String, dynamic> _userInfo;

      DocumentSnapshot _snapshot = await FirebaseFirestore.instance
          .collection("User Details")
          .doc(user.uid)
          .get();
      if (_snapshot.data() != null) {
        _userInfo = _snapshot.data() as Map<String, dynamic>;

        setState(() {
          _name = _userInfo['name'];
        });

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => _name == ""
                    ? ProfileData(phoneNumber.text, user.uid)
                    : const HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ProfileData(phoneNumber.text, user.uid)));
      }
    } catch (e) {
      print(e.toString());
      showSnackbar("Failed to sign in: " + e.toString());
    }
  }

  Future<void> phoneSignIn({required String phoneNumber}) async {
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: _onCodeTimeout);
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    print("verification completed ${authCredential.smsCode}");
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      otpCode.text = authCredential.smsCode!;
    });
    if (authCredential.smsCode != null) {
      try {
        UserCredential credential =
            await user!.linkWithCredential(authCredential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked') {
          await _auth.signInWithCredential(authCredential);
        }
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      showMessage("The phone number entered is invalid!");
    }
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
    print(forceResendingToken);
    print("code sent");
  }

  _onCodeTimeout(String timeout) {
    return null;
  }

  void showMessage(String errorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext builderContext) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(errorMessage),
            actions: [
              TextButton(
                child: const Text("Ok"),
                onPressed: () async {
                  Navigator.of(builderContext).pop();
                },
              )
            ],
          );
        }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Login to OneBlood",
            style: GoogleFonts.rubik(
              color: Colors.black,
              fontSize: 25,
            ),
          ),
          systemOverlayStyle:
              const SystemUiOverlayStyle(statusBarColor: Colors.blue),
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.8,
                  child: Material(
                    elevation: 10.0,
                    shadowColor: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(25.0),
                    child: TextFormField(
                        keyboardType: TextInputType.phone,
                        controller: phoneNumber,
                        decoration: InputDecoration(
                          labelText: "Enter Phone",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10.0),
                        )),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                ElevatedButton(
                  child: Text("Verify Number",
                      style: const TextStyle(fontSize: 14)),
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(color: Colors.red)))),
                  onPressed: () async {
                    phoneSignIn(
                      phoneNumber: phoneNumber.text,
                    );
                  },
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                SizedBox(
                  width: size.width * 0.8,
                  child: Material(
                    elevation: 10.0,
                    shadowColor: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(25.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: otpCode,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Enter Otp",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        suffixIcon: const Padding(
                          child: FaIcon(
                            FontAwesomeIcons.eye,
                            size: 15,
                          ),
                          padding: EdgeInsets.only(top: 15, left: 15),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: size.height * 0.05)),
                !isLoading
                    ? SizedBox(
                        width: size.width * 0.8,
                        child: OutlinedButton(
                          onPressed: () async {
                            //     FirebaseService service = new FirebaseService();
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              signInWithPhoneNumber();
                            }
                          },
                          child: const Text("Login"),
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            side: MaterialStateProperty.all<BorderSide>(
                                BorderSide.none),
                          ),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ],
            ),
          ),
        ));
  }
}
