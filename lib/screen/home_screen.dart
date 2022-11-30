import 'package:blood_donation_app/screen/auth.dart';
import 'package:blood_donation_app/screen/map_view.dart';
import 'package:blood_donation_app/screen/phone_number_auth.dart';
import 'package:blood_donation_app/screen/request_blood.dart';
import 'package:blood_donation_app/screen/utility_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import '../utils/custom_wave_indicator.dart';
import 'campaigns_screen.dart';
import 'donor_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User currentUser;
  late String _name, _bloodgrp, _phoneNumber;
  late Position position;
  late Widget _child;

  Future<void> requestLocationPermission() async {
    final serviceStatusLocation = await Permission.locationWhenInUse.isGranted;

    final status = await Permission.locationWhenInUse.request();

    if (status == PermissionStatus.granted) {
      print('Permission Granted');
    } else if (status == PermissionStatus.denied) {
      print('Permission denied');
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('Permission Permanently Denied');
      await openAppSettings();
    }
  }

  Future<void> _fetchUserInfo() async {
    Map<String, dynamic> _userInfo;
    User? _currentUser = FirebaseAuth.instance.currentUser;

    DocumentSnapshot _snapshot = await FirebaseFirestore.instance
        .collection("User Details")
        .doc(_currentUser!.uid)
        .get();

    _userInfo = _snapshot.data() as Map<String, dynamic>;

    setState(() {
      _name = _userInfo['name'];
      _bloodgrp = _userInfo['bloodgroup'];
      _phoneNumber = _userInfo['phoneNumber'];
      _child = _myWidget();
    });
  }

  void _loadCurrentUser() {
    currentUser = FirebaseAuth.instance.currentUser!;
  }

  void getCurrentLocation() async {
    Position res = await Geolocator.getCurrentPosition();
    print(Position);
    setState(() {
      position = res;
    });

    print(position.latitude);
    print(position.longitude);
  }

  @override
  void initState() {
    _child = const WaveIndicator();
    requestLocationPermission().then((value) => {getCurrentLocation()});
    _loadCurrentUser();
    _fetchUserInfo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //top bar color
      systemNavigationBarColor: Colors.black, //bottom bar color
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return _child;
  }

  Widget _myWidget() {
    return Scaffold(
      backgroundColor: const Color.fromARGB(1000, 221, 46, 68),
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Home",
          style: TextStyle(
            fontSize: 60.0,
            fontFamily: "SouthernAire",
            color: Colors.white,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0.0),
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              accountName: Text(
                _name,
                style: const TextStyle(
                  fontSize: 22.0,
                ),
              ),
              accountEmail: Text(
                _phoneNumber,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _bloodgrp,
                  style: GoogleFonts.rubik(
                    fontSize: 30.0,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text("Home"),
              leading: const Icon(
                FontAwesomeIcons.home,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Blood Donors"),
              leading: const Icon(
                FontAwesomeIcons.handshake,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DonorsPage()));
              },
            ),
            ListTile(
              title: const Text("Request For Blood"),
              leading: const Icon(
                FontAwesomeIcons.burn,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RequestBlood(
                            position.latitude, position.longitude)));
              },
            ),
            ListTile(
              title: const Text("Campaigns"),
              leading: const Icon(
                FontAwesomeIcons.ribbon,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CampaignsPage()));
              },
            ),
            ListTile(
              title: const Text("Utility"),
              leading: const Icon(
                FontAwesomeIcons.plus,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UtilityScreen()));
              },
            ),
            ListTile(
              title: const Text("Ambulance Service"),
              leading: const Icon(
                FontAwesomeIcons.ambulance,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: SizedBox(
                          height: 300,
                          width: 350,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                ListTile(
                                  onTap: () {},
                                  dense: true,
                                  leading: Text(
                                    "Ambulance Phone Number",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunitoSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0F172A)
                                            .withOpacity(0.8)),
                                  ),
                                ),
                                ListTile(
                                  onTap: () {
                                    UrlLauncher.launch("tel:102");
                                  },
                                  dense: true,
                                  title: Text(
                                    "102",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunitoSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0F172A)
                                            .withOpacity(0.8)),
                                  ),
                                ),
                                ListTile(
                                  onTap: () {
                                    UrlLauncher.launch("tel:1298");
                                  },
                                  dense: true,
                                  title: Text(
                                    "1298",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunitoSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0F172A)
                                            .withOpacity(0.8)),
                                  ),
                                ),
                                ListTile(
                                  onTap: () {},
                                  dense: true,
                                  leading: Text(
                                    "Blood Bank Phone Number",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunitoSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0F172A)
                                            .withOpacity(0.8)),
                                  ),
                                ),
                                ListTile(
                                  onTap: () {
                                    UrlLauncher.launch("tel:104");
                                  },
                                  dense: true,
                                  title: Text(
                                    "104",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunitoSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0F172A)
                                            .withOpacity(0.8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              },
            ),
            ListTile(
              title: const Text("Logout"),
              leading: const Icon(
                FontAwesomeIcons.signOutAlt,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => PhoneNumberAuth()));
              },
            ),
          ],
        ),
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
        child: Container(
          height: 800.0,
          width: double.infinity,
          color: Colors.white,
          child: const MapView(),
        ),
      ),
    );
  }
}
