import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import '../utils/custom_wave_indicator.dart';
//

class DonorsPage extends StatefulWidget {
  const DonorsPage({Key? key}) : super(key: key);

  @override
  _DonorsPageState createState() => _DonorsPageState();
}

class _DonorsPageState extends State<DonorsPage> {
  List<String> donors = [];
  List<String> bloodgroup = [];
  List<String> uid = [];
  List<String> phoneNumber = [];

  late Widget _child;
  User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    _child = const WaveIndicator();
    getDonors();
    super.initState();
  }

  Future<void> getDonors() async {
    await FirebaseFirestore.instance.collection('Donor').get().then((docs) {
      if (docs.docs.isNotEmpty) {
        for (int i = 0; i < docs.docs.length; ++i) {
          donors.add(docs.docs[i].data()['name']);
          bloodgroup.add(docs.docs[i].data()['bloodgroup']);
          uid.add(docs.docs[i].data()['uid']);
          phoneNumber.add(docs.docs[i].data()['phoneNumber']);
        }
      }
    });
    setState(() {
      _child = myWidget();
    });
  }

  Widget myWidget() {
    return Scaffold(
      backgroundColor: const Color.fromARGB(1000, 221, 46, 68),
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "Donors",
          style: GoogleFonts.rubik(
            fontSize: 35.0,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.reply,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
        child: Container(
          height: 800.0,
          width: double.infinity,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: donors.length,
              itemBuilder: (BuildContext context, int index) {
                return _currentUser!.uid == uid[index]
                    ? const SizedBox()
                    : ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(donors[index]),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.message),
                                onPressed: () {
                                  String message =
                                      "Hello ${donors[index]}, I am in a need of a blood donor if you are willing to help me. Reply back if you can donate blood.";
                                  UrlLauncher.launch(
                                      "sms:${phoneNumber[index]}?body=$message");
                                },
                                color: const Color.fromARGB(1000, 221, 46, 68),
                              ),
                            ),
                          ],
                        ),
                        leading: CircleAvatar(
                          child: Text(
                            bloodgroup[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor:
                              const Color.fromARGB(1000, 221, 46, 68),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.phone),
                          onPressed: () {
                            UrlLauncher.launch("tel:${phoneNumber[index]}");
                          },
                          color: const Color.fromARGB(1000, 221, 46, 68),
                        ),
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _child;
  }
}
