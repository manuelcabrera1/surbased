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
    apiKey: 'AIzaSyDdV23IFHD4wl-MkGeP-9EOIur_557Ly9E',
    appId: '1:816712233769:web:af7b8761927aea8d7efd38',
    messagingSenderId: '816712233769',
    projectId: 'surbased-9d626',
    authDomain: 'surbased-9d626.firebaseapp.com',
    storageBucket: 'surbased-9d626.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCEYqlV6dx7XbxaGX1tnH5z1aJWsjsMZO4',
    appId: '1:816712233769:android:090a1978dcb9260a7efd38',
    messagingSenderId: '816712233769',
    projectId: 'surbased-9d626',
    storageBucket: 'surbased-9d626.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA67WBh5FFkck9tc5swsVPPKhZOFYZT2dY',
    appId: '1:816712233769:ios:5475f2b8ff01d92c7efd38',
    messagingSenderId: '816712233769',
    projectId: 'surbased-9d626',
    storageBucket: 'surbased-9d626.firebasestorage.app',
    iosBundleId: 'com.example.surbased',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA67WBh5FFkck9tc5swsVPPKhZOFYZT2dY',
    appId: '1:816712233769:ios:5475f2b8ff01d92c7efd38',
    messagingSenderId: '816712233769',
    projectId: 'surbased-9d626',
    storageBucket: 'surbased-9d626.firebasestorage.app',
    iosBundleId: 'com.example.surbased',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDdV23IFHD4wl-MkGeP-9EOIur_557Ly9E',
    appId: '1:816712233769:web:67ffc9a234d20d397efd38',
    messagingSenderId: '816712233769',
    projectId: 'surbased-9d626',
    authDomain: 'surbased-9d626.firebaseapp.com',
    storageBucket: 'surbased-9d626.firebasestorage.app',
  );
}
