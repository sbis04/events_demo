import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final CollectionReference mainCollection =
    FirebaseFirestore.instance.collection('event');

final DocumentReference documentReference = mainCollection.doc('test');

class Storage {
  Future<void> storeEventData({
    @required String id,
    @required String name,
    @required String description,
    @required int startTimeInEpoch,
    @required int endTimeInEpoch,
    @required int numberOfAttedees,
  }) async {
    // TODO: Initialize it only once during the starting of the app
    await Firebase.initializeApp();
    DocumentReference documentReferencer =
        documentReference.collection('events').doc(id);

    Map<String, dynamic> data = <String, dynamic>{
      "id": id,
      "name": name,
      "desc": description,
      "start": startTimeInEpoch,
      "end": endTimeInEpoch,
      "attendees": numberOfAttedees,
    };
    print('DATA:\n$data');

    await documentReferencer.set(data).whenComplete(() {
      print("Event added to the database, id: {$id}");
    }).catchError((e) => print(e));
  }
}
