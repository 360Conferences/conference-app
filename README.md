# 360|Conferences Mobile App

This repository contains the iOS/Android mobile app (written in Flutter) for attendees
of various 360|Conferences events.

## Getting Started

1. Edit the values in `constants.dart` for your event:
    - Event title
    - Event id
    - Event timezone offset
    - Primary/accent theme colors

1. Configure Firebase
    - [Add an Android app](https://firebase.google.com/docs/flutter/setup#configure_an_android_app)
    - [Add an iOS app](https://firebase.google.com/docs/flutter/setup#configure_an_ios_app)

1. Enable Google Maps APIs for your Firebase project
    - Launch the [Google Cloud Platform Console](https://console.cloud.google.com/google/maps-apis/overview)
    - Select **APIs & Services > Library** from the menu
    - Enable `Maps SDK for Android` and `Maps SDK for iOS`

1. Add Maps API keys to your app
    - [Android](https://developers.google.com/maps/documentation/android-sdk/get-api-key)
    - [iOS](https://developers.google.com/maps/documentation/ios-sdk/get-api-key)

1. Add image assets
    - `images/logo.png`: Conference logo (recommended size 144x144)
    - `images/2.0x/logo.png`: Conference logo (recommended size 288x288)
    - `images/3.0x/logo.png`: Conference logo (recommended size 432x432)

## Building for release

Follow the instructions provided for preparing a Flutter app for release:

- [Android](https://flutter.dev/docs/deployment/android)
    - This project is configured to use `signing.properties` for the keystore
    properties file.
- [iOS](https://flutter.dev/docs/deployment/ios)

## License

This software is available under the Apache License, Version 2.0.
See [LICENSE](LICENSE).