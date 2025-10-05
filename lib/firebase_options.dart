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
    apiKey: 'AIzaSyC9RS4GhkbfUtqtebzZZCoC4Hw10x7k0Ic',
    appId: '1:438230667949:web:308d7f1112f4f668fdec24',
    messagingSenderId: '438230667949',
    projectId: 'caloriewise-app',
    authDomain: 'caloriewise-app.firebaseapp.com',
    storageBucket: 'caloriewise-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBLgNUlzvusgxxgl7ixJnIWcvEiF6VKJYk',
    appId: '1:438230667949:android:cd2adaa68936a36efdec24',
    messagingSenderId: '438230667949',
    projectId: 'caloriewise-app',
    storageBucket: 'caloriewise-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDnBTwri90PWrFp0Q1yGbBQy9A8auty1Xk',
    appId: '1:438230667949:ios:eb7169bc8049572cfdec24',
    messagingSenderId: '438230667949',
    projectId: 'caloriewise-app',
    storageBucket: 'caloriewise-app.firebasestorage.app',
    iosBundleId: 'com.example.calorieWise',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDnBTwri90PWrFp0Q1yGbBQy9A8auty1Xk',
    appId: '1:438230667949:ios:eb7169bc8049572cfdec24',
    messagingSenderId: '438230667949',
    projectId: 'caloriewise-app',
    storageBucket: 'caloriewise-app.firebasestorage.app',
    iosBundleId: 'com.example.calorieWise',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC9RS4GhkbfUtqtebzZZCoC4Hw10x7k0Ic',
    appId: '1:438230667949:web:8cfd569c78b81e5ffdec24',
    messagingSenderId: '438230667949',
    projectId: 'caloriewise-app',
    authDomain: 'caloriewise-app.firebaseapp.com',
    storageBucket: 'caloriewise-app.firebasestorage.app',
  );
}
