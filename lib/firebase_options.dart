// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  // إعدادات الويب اللي إنت لسه جايبها
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDslJmFmuqKzzTw8L8hj24ysiVnXSr2ezM',
    appId: '1:602286841824:web:94b06332b6e7384ab31585',
    messagingSenderId: '602286841824',
    projectId: 'elgarage-beyond',
    authDomain: 'elgarage-beyond.firebaseapp.com',
    storageBucket: 'elgarage-beyond.firebasestorage.app',
  );

  // إعدادات الأندرويد من ملف google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBPtf4rBwVh6DaCAotzraPBk81XYI6e8Mg',
    appId: '1:602286841824:android:9a1875fde2ad22aeb31585',
    messagingSenderId: '602286841824',
    projectId: 'elgarage-beyond',
    storageBucket: 'elgarage-beyond.firebasestorage.app',
  );
}