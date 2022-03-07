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
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'model.dart' show Speaker;

class SpeakerDetailView extends StatefulWidget {
  SpeakerDetailView({Key key, this.speaker}) : super(key: key);

  final Speaker speaker;

  @override
  _SpeakerDetailState createState() => _SpeakerDetailState();
}

class _SpeakerDetailState extends State<SpeakerDetailView> {
  void _launchSocial(String socialUrl) async {
    if (await canLaunch(socialUrl)) {
      await launch(socialUrl);
    }
  }

  List<Widget> _getSpeakerDetails() {
    return [
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: FutureBuilder(
              future: widget.speaker.avatar,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return ClipOval(
                      child: Image.network(
                        snapshot.data,
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                    );
                  default:
                    return Icon(Icons.person, size: 200.0);
                }
              }),
        ),
      ),
      Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            widget.speaker.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
      Center(
        child: Text(
          widget.speaker.company,
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ),
      Divider(),
      Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Follow',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      Center(
        child: GestureDetector(
          child: Image.asset('images/logo_twitter.png'),
          onTap: () => _launchSocial(widget.speaker.socialUrl),
        ),
      ),
      Divider(),
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(widget.speaker.bio),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate(_getSpeakerDetails()),
          ),
        ],
      ),
    );
  }
}
