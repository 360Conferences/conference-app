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
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'model.dart' show Venue;

class VenueView extends StatefulWidget {
  const VenueView({Key key}) : super(key: key);

  @override
  _VenueState createState() => _VenueState();
}

class _VenueState extends State<VenueView> {
  // Completer<GoogleMapController> _controller = Completer();

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Widget _getVenueDetail(Venue venue) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(venue.name, style: Theme.of(context).textTheme.headlineMedium),
          (venue.address != null && venue.address.isNotEmpty)
              ? InkWell(
                  child: Padding(
                      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.location_on),
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(venue.address,
                                style: Theme.of(context).textTheme.subtitle1),
                          ),
                        ],
                      )),
                  onTap: () => _launchUrl(venue.mapUrl),
                )
              : Container(),
          (venue.phone != null && venue.phone.isNotEmpty)
              ? InkWell(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.phone),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(venue.phone,
                              style: Theme.of(context).textTheme.subtitle1),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => _launchUrl(venue.phoneUrl),
                )
              : Container(),
          Expanded(
            // child: GoogleMap(
            //   mapType: MapType.normal,
            //   initialCameraPosition: CameraPosition(
            //       target: LatLng(venue.latitude, venue.longitude), zoom: 17.0),
            //   markers: [
            //     Marker(
            //       markerId: MarkerId('1'),
            //       position: LatLng(venue.latitude, venue.longitude),
            //     ),
            //   ].toSet(),
            //   rotateGesturesEnabled: false,
            //   scrollGesturesEnabled: false,
            //   tiltGesturesEnabled: false,
            //   onMapCreated: (GoogleMapController controller) {
            //     _controller.complete(controller);
            //   },
            // ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance
          .ref()
          .child('events')
          .child(kEventId)
          .child('venue')
          .onValue,
      builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasError) {
          return Text('Unable to load venue');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            Map<dynamic, dynamic> result = snapshot.data.snapshot.value;
            Venue venue = Venue.fromData(result);
            return _getVenueDetail(venue);
        }
      },
    );
  }
}
