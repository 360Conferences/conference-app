/// Copyright 2019 360|Conferences
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
/// http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
/// or implied. See the License for the specific language governing
/// permissions and limitations under the License.
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'model.dart' show Speaker;
import 'speaker_detail.dart';

class SpeakerView extends StatefulWidget {
  const SpeakerView({Key key}) : super(key: key);

  @override
  _SpeakerState createState() => _SpeakerState();
}

class _SpeakerState extends State<SpeakerView> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Event>(
      stream: FirebaseDatabase.instance
          .ref()
          .child('events')
          .child(kEventId)
          .child('speakers')
          .onValue,
      builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
        if (snapshot.hasError) {
          return Text('Unable to load speakers');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            Map<dynamic, dynamic> result = snapshot.data.snapshot.value;
            List<Speaker> speakers =
                result.values.map((item) => Speaker.fromData(item)).toList();
            speakers.sort((a, b) => a.name.compareTo(b.name));
            return ListView(
              children: speakers.map((item) {
                return SpeakerTile(speaker: item);
              }).toList(),
            );
        }
      },
    );
  }
}

class SpeakerTile extends StatelessWidget {
  SpeakerTile({this.speaker});

  final Speaker speaker;

  void _showSpeakerDetail(BuildContext context, Speaker speaker) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SpeakerDetailView(speaker: speaker)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(speaker.name),
      subtitle: Text(speaker.company),
      leading: FutureBuilder(
        future: speaker.avatar,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return CircleAvatar(
                backgroundImage: NetworkImage(snapshot.data),
              );
            default:
              return Icon(Icons.person);
          }
        },
      ),
      onTap: () => _showSpeakerDetail(context, speaker),
    );
  }
}
