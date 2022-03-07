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
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'constants.dart';
import 'model.dart' show Session, SessionFeedback;

class FeedbackView extends StatefulWidget {
  FeedbackView({Key key, this.session, this.userSession}) : super(key: key);

  final Session session;
  final String userSession;

  _FeedbackState createState() => _FeedbackState();
}

class _FeedbackState extends State<FeedbackView> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  DatabaseReference _feedbackRef;
  Stream<Event> _feedbackStream;

  double _overallScore, _technicalScore, _presentationScore;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _feedbackRef = FirebaseDatabase.instance
        .ref()
        .child('events')
        .child(kEventId)
        .child('feedback')
        .child('scores')
        .child(widget.session.id)
        .child(widget.userSession);
    _feedbackStream = _feedbackRef.onValue;
  }

  void _saveFeedback(BuildContext localContext) {
    // Validate entry data
    if (_overallScore == null ||
        _technicalScore == null ||
        _presentationScore == null) {
      final snackbar = SnackBar(
        content: Text('Please rate every category'),
        duration: Duration(seconds: 2),
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);
      return;
    }

    // Save feedback
    _feedbackRef.update({
      'overall': _overallScore,
      'technical': _technicalScore,
      'speaker': _presentationScore,
      'comment': _controller.text
    });
    // Dismiss popup
    Navigator.pop(context);
  }

  Widget _getFeedbackView(SessionFeedback feedback) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Overall session experience',
            style: Theme.of(context).textTheme.headlineMedium),
        FlutterRatingBar(
          initialRating: feedback.overallRating.toDouble(),
          fillColor: kThemeAccent,
          borderColor: kThemeAccent.withAlpha(50),
          allowHalfRating: true,
          onRatingUpdate: (rating) {
            setState(() {
              _overallScore = rating;
            });
          },
        ),
        Text('Technical level of the content',
            style: Theme.of(context).textTheme.headlineMedium),
        FlutterRatingBar(
          initialRating: feedback.technicalRating.toDouble(),
          fillColor: kThemeAccent,
          borderColor: kThemeAccent.withAlpha(50),
          allowHalfRating: true,
          onRatingUpdate: (rating) {
            setState(() {
              _technicalScore = rating;
            });
          },
        ),
        Text('Presentation skills of the speaker',
            style: Theme.of(context).textTheme.headlineMedium),
        FlutterRatingBar(
          initialRating: feedback.presentationRating.toDouble(),
          fillColor: kThemeAccent,
          borderColor: kThemeAccent.withAlpha(50),
          allowHalfRating: true,
          onRatingUpdate: (rating) {
            setState(() {
              _presentationScore = rating;
            });
          },
        ),
        Text('Comments', style: Theme.of(context).textTheme.headlineMedium),
        TextField(
          controller: _controller,
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
          decoration: InputDecoration(hintText: 'What did you think?'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Session Feedback'),
        actions: <Widget>[
          FlatButton(
            child: Text('SAVE', style: TextStyle(color: Colors.white)),
            onPressed: () => _saveFeedback(context),
          ),
        ],
      ),
      body: _feedbackStream == null
          ? Container()
          : StreamBuilder<Event>(
              stream: _feedbackStream,
              builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
                if (snapshot.hasError) {
                  return Text('Unable to load feedback');
                }

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    DataSnapshot data = snapshot.data.snapshot;
                    SessionFeedback feedback = (data.value != null)
                        ? SessionFeedback.fromData(data.value)
                        : SessionFeedback(0, 0, 0, '');
                    if (_controller.text.isEmpty) {
                      _controller.text = feedback.comment;
                    }
                    return Padding(
                      padding: EdgeInsets.all(8.0),
                      child: _getFeedbackView(feedback),
                    );
                }
              },
            ),
    );
  }
}
