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
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

/// Enumeration for a schedule item's status
enum EventStatus { past, present, future }

/// Base class for items rendered in the schedule
abstract class ScheduleItem {
  ScheduleItem(this.id, this.title, this.description, this.location,
      this.startTime, this.endTime);

  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;

  String get timeSpan =>
      '${DateFormat.MMMEd().add_jm().format(startTime.toUtc().add(kEventOffset))}' +
      ' - ' +
      '${DateFormat.jm().format(endTime.toUtc().add(kEventOffset))}';
  String get startAt =>
      DateFormat.jm().format(startTime.toUtc().add(kEventOffset));
  String get endAt => DateFormat.jm().format(endTime.toUtc().add(kEventOffset));

  EventStatus computeEventStatus(DateTime time) {
    return time.isBefore(this.startTime)
        ? EventStatus.future
        : time.isBefore(this.endTime)
            ? EventStatus.present
            : EventStatus.past;
  }

  factory ScheduleItem.fromData(Map<dynamic, dynamic> data,
      Map<dynamic, dynamic> speakers, Map<dynamic, dynamic> favorites) {
    switch (data['type']) {
      case 'session':
        List<Speaker> items = (data['speakers'] as List<dynamic>)
            .map((id) => Speaker.fromData(speakers[id]))
            .toList();
        bool isFavorite =
            favorites != null && favorites.containsKey(data['id']);
        return Session(
            data['id'],
            data['title'],
            data['description'],
            data['location'],
            DateTime.parse(data['start_time']),
            DateTime.parse(data['end_time']),
            items,
            isFavorite);
      case 'event':
        return Event(
            data['id'],
            data['title'],
            data['description'],
            data['location'],
            DateTime.parse(data['start_time']),
            DateTime.parse(data['end_time']),
            data['address']);
      default:
        throw ('Invalid item type');
    }
  }
}

/// Schedule items of type "session"
class Session extends ScheduleItem {
  Session(String id, String title, String description, String location,
      DateTime startTime, DateTime endTime, this.speakers, this.isFavorite)
      : super(id, title, description, location, startTime, endTime);

  final List<Speaker> speakers;
  final bool isFavorite;
}

/// Schedule items of type "event"
class Event extends ScheduleItem {
  Event(String id, String title, String description, String location,
      DateTime startTime, DateTime endTime, this.address)
      : super(id, title, description, location, startTime, endTime);

  final String address;

  String get mapUrl =>
      'https://www.google.com/maps/search/?api=1&query=${this.location},+${this.address}'
          .replaceAll(RegExp('[\\r\\n\\s]'), '+');
}

/// Speaker data model
class Speaker {
  Speaker(this.id, this.name, this.company, this.email, this.bio, this.social);

  final String id;
  final String name;
  final String company;
  final String email;
  final String bio;
  final String social;

  factory Speaker.fromData(Map<dynamic, dynamic> data) {
    return Speaker(data['id'], data['name'], data['company'], data['email'],
        data['bio'], data['twitter']);
  }

  Future<dynamic> get avatar {
    return FirebaseStorage.instance
        .ref()
        .child(kEventId)
        .child('profiles')
        .child(this.id)
        .getDownloadURL();
  }

  String get socialUrl =>
      'https://www.twitter.com/${this.social}'.replaceAll(RegExp('@'), '');
}

/// Venue data model
class Venue {
  Venue(this.name, this.address, this.phone, this.latitude, this.longitude);

  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;

  String get mapUrl =>
      'https://www.google.com/maps/search/?api=1&query=${this.address}'
          .replaceAll(RegExp('[\\r\\n\\s]'), '+');

  String get phoneUrl => 'tel://${this.phone}';

  factory Venue.fromData(Map<dynamic, dynamic> data) {
    return Venue(data['name'], data['address'], data['phone'], data['latitude'],
        data['longitude']);
  }
}

/// Feedback data model
class SessionFeedback {
  SessionFeedback(this.overallRating, this.technicalRating,
      this.presentationRating, this.comment);

  final num overallRating;
  final num technicalRating;
  final num presentationRating;
  final String comment;

  factory SessionFeedback.fromData(Map<dynamic, dynamic> data) {
    return SessionFeedback(
        data['overall'], data['technical'], data['speaker'], data['comment']);
  }
}
