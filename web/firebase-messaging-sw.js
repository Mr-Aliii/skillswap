importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDbkCbeANZzjYhLRo6r7UfTq-hHrRRfPtE',
  authDomain: 'skillswap-3e33f.firebaseapp.com',
  projectId: 'skillswap-3e33f',
  storageBucket: 'skillswap-3e33f.firebasestorage.app',
  messagingSenderId: '2081006226',
  appId: '1:2081006226:web:2dda5dceaf8efb1d2cbc4b',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Background message:', payload);
});
