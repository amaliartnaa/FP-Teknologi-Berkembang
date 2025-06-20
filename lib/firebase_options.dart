// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyCFSZlzT16MTUKuNsoo-MtzKCZejb4tNiQ',
    appId: '1:281712028885:web:c9b99722ae01e69681c65c',
    messagingSenderId: '281712028885',
    projectId: 'sicatat-bc5d5',
    authDomain: 'sicatat-bc5d5.firebaseapp.com',
    storageBucket: 'sicatat-bc5d5.firebasestorage.app',
    measurementId: 'G-0B8794P5SH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0EI9gMiL6k067Phc1kE47jGWiTVfn4jY',
    appId: '1:281712028885:android:cc73bfd36f2b04ed81c65c',
    messagingSenderId: '281712028885',
    projectId: 'sicatat-bc5d5',
    storageBucket: 'sicatat-bc5d5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDhJI30RB3T-IvS9TtImJIoPb0EjcSXFiE',
    appId: '1:281712028885:ios:17b26f5312d607b781c65c',
    messagingSenderId: '281712028885',
    projectId: 'sicatat-bc5d5',
    storageBucket: 'sicatat-bc5d5.firebasestorage.app',
    iosBundleId: 'com.example.notesCrudApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDhJI30RB3T-IvS9TtImJIoPb0EjcSXFiE',
    appId: '1:281712028885:ios:17b26f5312d607b781c65c',
    messagingSenderId: '281712028885',
    projectId: 'sicatat-bc5d5',
    storageBucket: 'sicatat-bc5d5.firebasestorage.app',
    iosBundleId: 'com.example.notesCrudApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCFSZlzT16MTUKuNsoo-MtzKCZejb4tNiQ',
    appId: '1:281712028885:web:ebafe370da2522cf81c65c',
    messagingSenderId: '281712028885',
    projectId: 'sicatat-bc5d5',
    authDomain: 'sicatat-bc5d5.firebaseapp.com',
    storageBucket: 'sicatat-bc5d5.firebasestorage.app',
    measurementId: 'G-BH0ZFWFHG6',
  );
}
