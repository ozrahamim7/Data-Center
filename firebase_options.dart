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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAPCZc-RqZBHfPF9vJEuY5OGNgzQbmxqzg',
    appId: '1:284870880378:web:9d09e02a5133324f711fc3',
    messagingSenderId: '284870880378',
    projectId: 'srv-hub',
    authDomain: 'srv-hub.firebaseapp.com',
    storageBucket: 'srv-hub.firebasestorage.app',
    measurementId: 'G-2BKZLVPSFX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAnnUFlB6dDTMyp-E0aa1tHm51vbry6vMs',
    appId: '1:284870880378:android:add76a1c2a7c702a711fc3',
    messagingSenderId: '284870880378',
    projectId: 'srv-hub',
    storageBucket: 'srv-hub.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCIDowQKTWZvyL0lxL00po0bwB-QJTd3nk',
    appId: '1:284870880378:ios:58124a4e7d1f3f6b711fc3',
    messagingSenderId: '284870880378',
    projectId: 'srv-hub',
    storageBucket: 'srv-hub.firebasestorage.app',
    iosBundleId: 'com.example.srvHub',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCIDowQKTWZvyL0lxL00po0bwB-QJTd3nk',
    appId: '1:284870880378:ios:58124a4e7d1f3f6b711fc3',
    messagingSenderId: '284870880378',
    projectId: 'srv-hub',
    storageBucket: 'srv-hub.firebasestorage.app',
    iosBundleId: 'com.example.srvHub',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAPCZc-RqZBHfPF9vJEuY5OGNgzQbmxqzg',
    appId: '1:284870880378:web:cc475ad83ec66f22711fc3',
    messagingSenderId: '284870880378',
    projectId: 'srv-hub',
    authDomain: 'srv-hub.firebaseapp.com',
    storageBucket: 'srv-hub.firebasestorage.app',
    measurementId: 'G-0KW8H5Z601',
  );
}
