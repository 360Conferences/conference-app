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

import 'constants.dart';
import 'schedule.dart';
import 'speakers.dart';
import 'venue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      theme: ThemeData(primaryColor: kThemePrimary, accentColor: kThemeAccent),
      home: MyHomePage(title: kAppTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum SelectedRoute { schedule, speakers, venue }

class _MyHomePageState extends State<MyHomePage> {
  SelectedRoute _route = SelectedRoute.schedule;

  void _selectItem(SelectedRoute route) {
    if (route == _route) return;

    setState(() {
      _route = route;
    });
  }

  Widget _getSelectedWidget(SelectedRoute route) {
    switch (route) {
      case SelectedRoute.schedule:
        return ScheduleView(
          key: PageStorageKey('Schedule'),
        );
      case SelectedRoute.speakers:
        return SpeakerView(
          key: PageStorageKey('Speakers'),
        );
      case SelectedRoute.venue:
        return VenueView(
          key: PageStorageKey('Venue'),
        );
      default:
        throw Exception('Invalid route selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _getSelectedWidget(_route),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Speakers'),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_on), label: 'Location'),
        ],
        currentIndex: _route.index,
        onTap: (index) {
          _selectItem(SelectedRoute.values[index]);
        },
      ),
    );
  }
}
