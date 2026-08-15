import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChftMRC8aC_lLqXx-QHdbgx4VvREJnEhk',
    appId: '1:997229042036:android:e4a56cd9149fa077773421',
    messagingSenderId: '997229042036',
    projectId: 'vitalguard-c1b6f',
    storageBucket: 'vitalguard-c1b6f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TODO_IOS_API_KEY',
    appId: 'TODO_IOS_APP_ID',
    messagingSenderId: '997229042036',
    projectId: 'vitalguard-c1b6f',
    storageBucket: 'vitalguard-c1b6f.firebasestorage.app',
    iosBundleId: 'com.vitalguard.mobile',
  );
}
