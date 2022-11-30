import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class CampaignsPage extends StatefulWidget {
  const CampaignsPage({Key? key}) : super(key: key);

  @override
  _CampaignsPageState createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  List<String> campaignsName = [];
  List<String> location = [];
  List<String> image = [];
  List<String> phoneNumber = [];

  late Widget _child;

  Future<void> getCampaigns() async {
    await FirebaseFirestore.instance.collection('campaigns').get().then((docs) {
      if (docs.docs.isNotEmpty) {
        for (int i = 0; i < docs.docs.length; ++i) {
          campaignsName.add(docs.docs[i].data()['name']);
          location.add(docs.docs[i].data()['location']);
          image.add(docs.docs[i].data()['image']);
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
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(1000, 221, 46, 68),
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "Campaigns",
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
                itemCount: campaignsName.length,
                itemBuilder: (ctx, index) {
                  return Container(
                    margin: EdgeInsets.all(
                      25,
                    ),
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              15.0,
                            ),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: image[index],
                              height: 180,
                              width: 500,
                            ),
                          ),
                          ListTile(
                            title: Container(
                              margin: const EdgeInsets.only(
                                bottom: 7,
                                top: 7,
                              ),
                              child: AutoSizeText(
                                campaignsName[index],
                                maxLines: 2,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            subtitle: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 7,
                                  ),
                                  child: AutoSizeText(
                                    location[index],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: AutoSizeText(
                                        phoneNumber[index],
                                        maxLines: 1,
                                        style: GoogleFonts.poppins(
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCampaigns();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return _child;
  }
}
