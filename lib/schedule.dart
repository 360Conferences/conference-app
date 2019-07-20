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
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'schedule_detail.dart';
import 'model.dart' show ScheduleItem, EventStatus, Session;
import 'constants.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({Key key}) : super(key: key);

  @override
  _ScheduleState createState() => new _ScheduleState();
}

class _ScheduleState extends State<ScheduleView> with WidgetsBindingObserver {
  String _userSessionId;
  DatabaseReference _favoritesRef;
  List<DateTime> _eventDates = [];
  DateTime _current = DateTime.now();

  _OffsetTracker _tracker = _OffsetTracker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _ensureUserSession().then((sessionId) => setState(() {
      _userSessionId = sessionId;
      _favoritesRef = FirebaseDatabase.instance.reference()
        .child('events').child(kEventId).child('favorites').child(_userSessionId);
    }));

    FirebaseDatabase.instance.reference()
        .child('events').child(kEventId).child('config').child('event_dates')
        .once().then((DataSnapshot snapshot) {
      List<dynamic> result = snapshot.value;
      setState(() {
        _eventDates = result.map((item) => DateTime.parse(item)).toList();
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Update time state on each resume
    if (state == AppLifecycleState.resumed) {
      _updateTimeState();
    }
  }

  Future<String> _ensureUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userSession')) {
        var uuid = Uuid();
        await prefs.setString('userSession', uuid.v4());
    }

    return prefs.getString('userSession');
  }

  void _updateTimeState() {
    setState(() {
      _current = DateTime.now();
    });
  }

  Widget _getHeaderView(DateTime date) {
    _tracker.advance(48.0);

    return SliverPersistentHeader(
      delegate: _SliverHeaderDelegate(
        height: 48.0,
        child: Center(
          child: Text(
            DateFormat.MMMMEEEEd().format(date),
            style:
                Theme.of(context).textTheme.title.copyWith(color: kThemeAccent),
          ),
        ),
      ),
    );
  }

  Widget _getContentView(DateTime date, List<ScheduleItem> sessions) {
    List<ScheduleItem> filtered = sessions.where((item) {
      DateTime gate = date.add(Duration(days: 1));
      return item.startTime.isAfter(date) && item.startTime.isBefore(gate);
    }).toList();
    filtered.forEach((item) => _tracker.add(item, 72.0));

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        ScheduleItem item = filtered[index];
        ScheduleItem previous = index > 0 ? filtered[index - 1] : null;
        //Check if this is the first item with the given start time
        bool first = previous?.startTime?.isBefore(item.startTime) ?? true;
        return ScheduleTile(
          parent: this,
          item: item,
          showTime: first,
          status: item.computeEventStatus(_current),
        );
      }, childCount: filtered.length),
    );
  }

  List<Widget> _buildSchedule(List<ScheduleItem> sessions) {
    _tracker.clear();

    List<Widget> slivers = [];
    _eventDates.forEach((date) {
      slivers.add(_getHeaderView(date));
      slivers.add(_getContentView(date, sessions));
    });
    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    if (_userSessionId == null || _eventDates.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    var sessionStream = FirebaseDatabase.instance.reference()
        .child('events').child(kEventId).child('sessions')
        .onValue;
    var speakerStream = FirebaseDatabase.instance.reference()
        .child('events').child(kEventId).child('speakers')
        .onValue;
    var favoriteStream = _favoritesRef.onValue;
    var combined = Observable.combineLatest3<Event, Event, Event, List<ScheduleItem>>(
        sessionStream, speakerStream, favoriteStream, (first, second, third) {
      Map<dynamic, dynamic> sessions = first.snapshot.value;
      Map<dynamic, dynamic> speakers = second.snapshot.value;
      Map<dynamic, dynamic> favorites = third.snapshot.value;
      var result = sessions.values
          .map((item) => ScheduleItem.fromData(item, speakers, favorites))
          .toList();
      result.sort((a, b) {
        return a.startTime.compareTo(b.startTime);
      });
      return result;
    });

    return StreamBuilder<List<ScheduleItem>>(
        stream: combined,
        builder:(BuildContext context, AsyncSnapshot<List<ScheduleItem>> snapshot) {
          if (snapshot.hasError) {
            return Text('Unable to load sessions');
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<ScheduleItem> sessions = snapshot.data;

          ScheduleItem first;
          // During event, offset to the first item still to occur
          if (_eventDates.any((item) => item.difference(_current).inDays == 0)) {
            first = sessions.firstWhere((item) =>
              item.computeEventStatus(_current) != EventStatus.past, orElse: () => null);
          }
          
          return CustomScrollView(
            slivers: _buildSchedule(sessions),
            controller: ScrollController(
              initialScrollOffset: _tracker.getOffset(first),
            ),
          );
        });
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverHeaderDelegate({@required this.height, @required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: this.child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return this.height != oldDelegate.height || this.child != oldDelegate.child;
  }
}

class ScheduleTile extends StatelessWidget {
  ScheduleTile({this.parent, this.item, this.showTime, this.status});

  final _ScheduleState parent;
  final bool showTime;
  final ScheduleItem item;
  final EventStatus status;

  void _showSessionDetail(BuildContext context) async {
    // Update time state before navigation and upon return
    this.parent._updateTimeState();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleDetailView(item: this.item, status: this.status, userSession: parent._userSessionId),
      ),
    );
    this.parent._updateTimeState();
  }

  void _setSessionFavorite(Session session) {
    DatabaseReference ref = parent._favoritesRef.child(session.id);
    if (session.isFavorite) {
      ref.remove();
    } else {
      ref.set(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 56.0,
        child: showTime
            ? Text(item.startAt,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: kThemePrimary),
              )
            : Container(),
      ),
      trailing: (item is Session) ? IconButton(
        icon: (item as Session).isFavorite ?
          Icon(Icons.star, color: kThemeAccent) : Icon(Icons.star_border),
        onPressed: () => _setSessionFavorite(item as Session),
      ) : null,
      title: Text(item.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: (this.status != EventStatus.past) ? null : TextStyle(
          color: Colors.grey,
        ),
      ),
      subtitle: Text(item.location,
        style: (this.status != EventStatus.past) ? null : TextStyle(
          color: Colors.grey,
        ), 
      ),
      onTap: () => _showSessionDetail(context),
    );
  }
}

/// Track pixel offsets for each item during build so we can
/// set initial scroll offsets based on date/time.
class _OffsetTracker {
  _OffsetTracker();

  num _offsetCount;
  final Map<String, num> _offsets = Map<String, num>();

  void clear() {
    _offsetCount = 0;
    _offsets.clear();
  }

  void advance(num height) {
    _offsetCount += height;
  }

  void add(ScheduleItem item, num height) {
    _offsets[item.id] = _offsetCount;
    _offsetCount += height;
  }

  num getOffset(ScheduleItem item) {
    return _offsets.containsKey(item?.id) ? _offsets[item?.id] : 0.0;
  }
}
