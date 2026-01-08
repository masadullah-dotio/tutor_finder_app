import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/core/services/notification_service.dart';
import 'package:tutor_finder_app/features/notifications/data/models/notification_model.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Stream of notifications for In-App Feed
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // The Main "Send" Logic
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      // 1. Fetch Target User Preferences
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;
      
      final user = UserModel.fromMap(userDoc.data()!);

      // 2. In-App Notification (Firestore)
      if (user.notifyInApp) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .add({
          'userId': userId,
          'title': title,
          'body': body,
          'type': type,
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // 3. Push Notification (Simulation for Client-only)
      if (user.notifyPush) {
        // In a real app, this would be a Cloud Function call or REST API call to FCM.
        // Here, we log it. 
        print("PUSH NOTIFICATION SENT TO $userId: $title - $body");
        
        // If we want to simulate it specifically for the current user (e.g. testing),
        // we can trigger a local one, but usually we send to *others*.
      }

      // 4. Email Notification (Log only)
      if (user.notifyEmail) {
        // Function/API call to SendGrid/Mailgun would go here.
        print("EMAIL SENT TO ${user.email}: $title - $body");
      }

    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}
