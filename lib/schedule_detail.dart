/**
 * Copyright 2019 360|Conferences
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */
import 'package:flutter/material.dart';
import 'package:threesixty_conferences/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model.dart' show ScheduleItem, Session, Event, EventStatus;
import 'speakers.dart' show SpeakerTile;
import 'feedback.dart';

class ScheduleDetailView extends StatefulWidget {
  ScheduleDetailView({Key key, this.item, this.status, this.userSession}) : super(key: key);

  final ScheduleItem item;
  final EventStatus status;
  final String userSession;

  @override
  _SchedulesDetailState createState() => new _SchedulesDetailState();
}

class _SchedulesDetailState extends State<ScheduleDetailView> {

  void _launchUrl(String url) async {
    print('Launching $url');
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _showFeedback(Session session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackView(session: session, userSession: widget.userSession),
        fullscreenDialog: true,
      )
    );
  }

  List<Widget> _getHeader(ScheduleItem item) {
    return [
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(item.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        child: Text(item.timeSpan,
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        child: Text(item.location,
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ),
    ];
  }

  List<Widget> _getFooter(ScheduleItem item) {
    return [
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(item.description),
      ),
    ];
  }

  List<Widget> _buildSession(Session session) {
    List<Widget> view = _getHeader(session);
    view.add(Divider());
    view.addAll(session.speakers.map((item) => SpeakerTile(speaker: item)));
    view.add(Divider());
    view.addAll(_getFooter(session));

    return view;
  }

  List<Widget> _buildEvent(Event event) {
    List<Widget> view = _getHeader(event);
    view.add(Divider());
    if (event.address != null) {
      view.addAll([
        InkWell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.location_on),
                Text(event.address)
              ],
            ),
          ),
          onTap: () => _launchUrl(event.mapUrl),
        ),
      ]);
      view.add(Divider());
    }
    view.addAll(_getFooter(event));

    return view;
  }

  bool _shouldShowStatus() {
    return (widget.item is Session) && (widget.status != EventStatus.future);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset('images/logo.png'),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              (widget.item is Session) ? _buildSession(widget.item) : _buildEvent(widget.item),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _shouldShowStatus() ? BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(widget.status == EventStatus.present ? 'Session in Progress' : 'Session has ended',
                style: TextStyle(
                  color: kThemeAccent,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.comment),
              onPressed: () => _showFeedback(widget.item),
            )
          ],
        ),
      ) : null,
    );
  }
}
