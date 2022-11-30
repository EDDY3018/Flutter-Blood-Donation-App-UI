import 'dart:async';

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:blood_donation_app/screen/request_blood.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import '../utils/custom_dialogs.dart';
import '../utils/custom_ripple_indicator.dart';
import 'be_a_donor.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  late GoogleMapController _controller;
  late bool isMapCreated = false;
  late Position position;
  late Widget _child;
  late BitmapDescriptor bitmapImage;
  late Marker marker;
  late Uint8List markerIcon;
  var lat = [];
  var lng = [];
  late String _name;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  @override
  void initState() {
    _child = const RippleIndicator("Getting Location");
    getIcon();
    getCurrentLocation();
    populateClients();
    super.initState();
  }

  Future<void> _fetchrequestName(requestId) async {
    Map<String, dynamic> _userInfo;
    DocumentSnapshot _snapshot = await FirebaseFirestore.instance
        .collection("User Details")
        .doc(requestId)
        .get();

    _userInfo = _snapshot.data() as Map<String, dynamic>;

    setState(() {
      _name = _userInfo['name'];
    });
  }

  populateClients() {
    FirebaseFirestore.instance
        .collection('Blood Request Details')
        .get()
        .then((docs) {
      if (docs.docs.isNotEmpty) {
        for (int i = 0; i < docs.docChanges.length; ++i) {
          if (_currentUser!.uid != docs.docs[i].data()["uid"]) {
            initMarker(docs.docs[i].data(), docs.docs[i].id);
          }
        }
      }
    });
  }

  void initMarker(request, requestId) {
    var markerIdVal = requestId;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
        markerId: markerId,
        position:
            LatLng(request['location'].latitude, request['location'].longitude),
        onTap: () async {
          CustomDialogs.progressDialog(context: context, message: 'Fetching');
          await _fetchrequestName(requestId);
          Navigator.pop(context);
          return showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (BuildContext context) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  height: 180.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              child: Text(
                                request['bloodGroup'],
                                style: const TextStyle(
                                  fontSize: 30.0,
                                  color: Colors.white,
                                ),
                              ),
                              radius: 30.0,
                              backgroundColor:
                                  const Color.fromARGB(1000, 221, 46, 68),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                _name,
                                style: const TextStyle(
                                    fontSize: 18.0, color: Colors.black87),
                              ),
                              Text(
                                "Quantity: " + request['quantity'] + " ml",
                                style: const TextStyle(
                                    fontSize: 14.0, color: Colors.black87),
                              ),
                              Text(
                                "Due Date: " + request['dueDate'],
                                style: const TextStyle(
                                    fontSize: 14.0, color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                        child: Text(
                          request['address'],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () {
                              UrlLauncher.launch("tel:${request['phone']}");
                            },
                            textColor: Colors.white,
                            padding:
                                const EdgeInsets.only(left: 5.0, right: 5.0),
                            color: const Color.fromARGB(1000, 221, 46, 68),
                            child: const Icon(Icons.phone),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                          ),
                          RaisedButton(
                            onPressed: () {
                              String message =
                                  "Hello $_name, I am a potential blood donor willing to help you. Reply back if you still need blood.";
                              UrlLauncher.launch(
                                  "sms:${request['phone']}?body=$message");
                            },
                            textColor: Colors.white,
                            padding:
                                const EdgeInsets.only(left: 5.0, right: 5.0),
                            color: const Color.fromARGB(1000, 221, 46, 68),
                            child: const Icon(Icons.message),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              });
        });

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
      print(markerId);
    });
  }

  void getCurrentLocation() async {
    Position res = await Geolocator.getCurrentPosition();
    print(Position);
    setState(() {
      position = res;
      _child = mapWidget();
    });

    print(position.latitude);
    print(position.longitude);
  }

  void getIcon() async {
    markerIcon = await getBytesFromAsset('assets/marker2.png', 120);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Set<Marker> _createMarker() {
    return <Marker>{
      Marker(
        markerId: const MarkerId("home"),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.fromBytes(markerIcon),
      ),
    };
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setmapstyle(String mapStyle) {
    _controller.setMapStyle(mapStyle);
  }

  @override
  Widget build(BuildContext context) {
    if (isMapCreated) {
      getJsonFile('assets/customStyle.json').then(setmapstyle);
    }
    return _child;
  }

  Widget mapWidget() {
    return Stack(
      children: <Widget>[
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 18.0,
          ),
          markers: Set<Marker>.of(markers.values),
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            isMapCreated = true;
            getJsonFile('assets/customStyle.json').then(setmapstyle);
          },
        ),
        Positioned(
          top: 640,
          left: 85,
          child: Container(
            width: 220.0,
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.extended(
              heroTag: "btn1",
              backgroundColor: const Color.fromARGB(1000, 221, 46, 68),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BeADonor(),
                  ),
                );
              },
              icon: const Icon(FontAwesomeIcons.burn),
              label: const Text("Be a Donor"),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.extended(
              heroTag: "btn2",
              backgroundColor: const Color.fromARGB(1000, 221, 46, 68),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RequestBlood(
                            position.latitude, position.longitude)));
              },
              icon: const Icon(FontAwesomeIcons.burn),
              label: const Text("Request For Blood"),
            ),
          ),
        )
      ],
    );
  }
}
