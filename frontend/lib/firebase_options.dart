import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDsNqDfPJjvpWpsNeYFfhJ7RS_D8qDtJxg',
    appId: '1:892549514296:web:0bd734482fec5f3f6092cd',
    messagingSenderId: '892549514296',
    projectId: 'nut-ecom-app',
    authDomain: 'nut-ecom-app.firebaseapp.com',
    storageBucket: 'nut-ecom-app.firebasestorage.app',
    measurementId: 'G-C6TS4K9J2V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCY8HFjpMvZbP1RaYS0x8pIthnsjXa_K7Q',
    appId: '1:892549514296:android:0beab90b484261ff6092cd',
    messagingSenderId: '892549514296',
    projectId: 'nut-ecom-app',
    storageBucket: 'nut-ecom-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA3APqCAJ0bdhgvcGuoKwmWK8GHyjZ3nrw',
    appId: '1:892549514296:ios:b322c055add4cbbc6092cd',
    messagingSenderId: '892549514296',
    projectId: 'nut-ecom-app',
    storageBucket: 'nut-ecom-app.firebasestorage.app',
    iosBundleId: 'nut-ecom-app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.nutEcomApp',
  );
}
