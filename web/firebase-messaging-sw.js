// Firebase Cloud Messaging service worker for SkillSwap (web).
//
// Replace the firebaseConfig object with values from your Firebase project
// (Firebase Console → Project settings → Your apps → Web app), then set
// AppConfig.useDemoMode = false and remove the kIsWeb skip in messaging_service.dart
// if you want push notifications on web.
//
// Docs: https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages

importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'YOUR_WEB_API_KEY',
  authDomain: 'skillswap-app.firebaseapp.com',
  projectId: 'skillswap-app',
  storageBucket: 'skillswap-app.appspot.com',
  messagingSenderId: 'YOUR_SENDER_ID',
  appId: 'YOUR_WEB_APP_ID',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Background message:', payload);
});
