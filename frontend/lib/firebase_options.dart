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
    apiKey: "AIzaSyDn_sTYrWNq9oAtxi2-jUMow3hrVxTRiow",
  authDomain: "nut-ecom-app-d4de6.firebaseapp.com",
  projectId: "nut-ecom-app-d4de6",
  storageBucket: "nut-ecom-app-d4de6.firebasestorage.app",
  messagingSenderId: "360061350144",
  appId: "1:360061350144:web:ce6e00bac092a77a7b83e5",
  measurementId: "G-7CP7LD1W51",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzXBGrXtFWef2MsawW-wk80iZRdqRKbcM',
    appId: '1:360061350144:android:3d32cb00003ef1b47b83e5',
    messagingSenderId: '360061350144',
    projectId: 'nut-ecom-app-d4de6',
    storageBucket: 'nut-ecom-app-d4de6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDn1L5pRwvPwpcrOdMyAhbuf_iDg1sdA8s',
    appId: '1:360061350144:ios:47fa1b4e93bc5c227b83e5',
    messagingSenderId: '360061350144',
    projectId: 'com.nut.ecom-app-d4de6',
    storageBucket: 'com.nut.ecom-app-d4de6.firebasestorage.app',
    iosBundleId: 'com.nut.ecom-app',
  );
}
