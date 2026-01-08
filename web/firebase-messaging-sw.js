importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyClBAs-WWG4FMGo5ZsEsNh2dvnpVSCuEJ4",
  authDomain: "tutor-finder-dotio.firebaseapp.com",
  projectId: "tutor-finder-dotio",
  storageBucket: "tutor-finder-dotio.firebasestorage.app",
  messagingSenderId: "733287524302",
  appId: "1:733287524302:web:3d4256e1e77b658b616d9f",
  measurementId: "G-J6SNR5TTR4"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  // Customize notification here
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
