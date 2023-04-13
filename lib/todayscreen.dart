import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'model/user.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shared_preferences/shared_preferences.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenHeight = 0;
  double screenwidth = 0;

  String checkIn = "--/--";
  String checkOut = "--/--";

  @override
  void initState() {
    super.initState();
    _getRecord();
  }

  void _getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where("id", isEqualTo: User.username)
          .get();

      print(snap.docs[0].id);
      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      setState(() {
        checkIn = snap2['checkIn'];
        checkOut = snap2['checkOut'];
      });
    } catch (e) {
      setState(() {
        checkIn = "--/--";
        checkOut = "--/--";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenwidth = MediaQuery.of(context).size.width;
    Color primary = const Color(0xffeef444c);

    return Scaffold(
        body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 32),
            child: Text(
              "Welcome",
              style: TextStyle(
                color: Colors.black54,
                fontFamily: "NexaRegular",
                fontSize: screenwidth / 20,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Employee " + User.username,
              style: TextStyle(
                fontFamily: "NexaRegular",
                fontSize: screenwidth / 18,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 32),
            child: Text(
              "Today's Status",
              style: TextStyle(
                fontFamily: "NexaRegular",
                fontSize: screenwidth / 18,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 150,
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(2, 2))
                ],
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Check In",
                      style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: screenwidth / 20,
                          color: Colors.black54),
                    ),
                    Text(
                      checkIn,
                      style: TextStyle(
                        fontFamily: "NexaBold",
                        fontSize: screenwidth / 18,
                      ),
                    )
                  ],
                )),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Check Out",
                      style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: screenwidth / 20,
                          color: Colors.black54),
                    ),
                    Text(
                      checkOut,
                      style: TextStyle(
                        fontFamily: "NexaBold",
                        fontSize: screenwidth / 18,
                      ),
                    )
                  ],
                ))
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 24),
            alignment: Alignment.centerLeft,
            child: RichText(
                text: TextSpan(
                    text: DateTime.now().day.toString(),
                    style: TextStyle(
                      color: primary,
                      fontSize: screenwidth / 18,
                      fontFamily: "NexaBold",
                    ),
                    children: [
                  TextSpan(
                      text: DateFormat(' MMMM yyyy').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenwidth / 20,
                        fontFamily: "NexaBold",
                      ))
                ])),
          ),
          StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormat('hh:mm:ss a').format(DateTime.now()),
                    style: TextStyle(
                      fontFamily: "NexaRegular",
                      fontSize: screenwidth / 20,
                      color: Colors.black54,
                    ),
                  ),
                );
              }),
          checkOut == "--/--"
              ? Container(
                  margin: const EdgeInsets.only(top: 24),
                  child: Builder(builder: (context) {
                    final GlobalKey<SlideActionState> key = GlobalKey();

                    return SlideAction(
                      text: checkIn == "--/--"
                          ? "Slide to Check In"
                          : "Slide to Check Out",
                      textStyle: TextStyle(
                        color: Colors.black54,
                        fontSize: screenwidth / 20,
                        fontFamily: "NexaRegular",
                      ),
                      outerColor: Colors.white,
                      innerColor: primary,
                      key: key,
                      onSubmit: () async {
                        Timer(const Duration(seconds: 1), () {
                          key.currentState!.reset();
                        });
                        QuerySnapshot snap = await FirebaseFirestore.instance
                            .collection("Employee")
                            .where("id", isEqualTo: User.username)
                            .get();

                        DocumentSnapshot snap2 = await FirebaseFirestore
                            .instance
                            .collection("Employee")
                            .doc(snap.docs[0].id)
                            .collection("Record")
                            .doc(DateFormat('dd MMMM yyyy')
                                .format(DateTime.now()))
                            .get();

                        try {
                          String checkIn = snap2['checkIn'];

                          setState(() {
                            checkOut =
                                DateFormat('hh:mm').format(DateTime.now());
                          });
                          await FirebaseFirestore.instance
                              .collection("Employee")
                              .doc(snap.docs[0].id)
                              .collection("Record")
                              .doc(DateFormat('dd MMMM yyyy')
                                  .format(DateTime.now()))
                              .update({
                            'checkIn': checkIn,
                            'checkOut':
                                DateFormat('hh:mm').format(DateTime.now()),
                          });
                        } catch (e) {
                          setState(() {
                            checkIn =
                                DateFormat('hh:mm').format(DateTime.now());
                          });
                          await FirebaseFirestore.instance
                              .collection("Employee")
                              .doc(snap.docs[0].id)
                              .collection("Record")
                              .doc(DateFormat('dd MMMM yyyy')
                                  .format(DateTime.now()))
                              .set({
                            'checkIn':
                                DateFormat('hh:mm').format(DateTime.now())
                          });
                        }
                      },
                    );
                  }),
                )
              : Container(
                  margin: const EdgeInsets.only(top: 32),
                  child: Text(
                    "You have completed this day!",
                    style: TextStyle(
                        fontFamily: "NexaRegular",
                        fontSize: screenwidth / 20,
                        color: Colors.black54),
                  ),
                )
        ],
      ),
    ));
  }
}
