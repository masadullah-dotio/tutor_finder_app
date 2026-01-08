import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_finder_app/features/chat/data/models/chat_message.dart';
import 'package:tutor_finder_app/features/chat/data/models/chat_room.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // 1. Create or Get Chat Room
  Future<String> createOrGetChatRoom(String otherUserId, UserModel? otherUser) async {
    final myId = currentUserId;
    if (myId == null) throw Exception("User not logged in");

    // Check if room exists
    // Note: Querying array-contains for multiple items is tricky in Firestore.
    // A common pattern is to store a combined ID "id1_id2" (sorted) or check 'participants' array.
    // For simplicity with small scale, we can query where 'participants' contains myId
    // and filter client side, or use a composite key approach.
    
    // Composite ID Approach: Always ID1_ID2 (alphabetical)
    final List<String> ids = [myId, otherUserId]..sort();
    final String roomId = ids.join('_');

    final docRef = _firestore.collection('chat_rooms').doc(roomId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      // Create new room
      final chatRoom = ChatRoom(
        id: roomId,
        participants: ids,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        unreadCounts: {for (var id in ids) id: 0},
        otherUserData: otherUser != null ? {
          'name': '${otherUser.firstName} ${otherUser.lastName}',
          'photoUrl': '', // Add if available
          'uid': otherUser.uid,
        } : null,
      );

      await docRef.set(chatRoom.toMap());
    }

    return roomId;
  }

  // 2. Send Message
  Future<void> sendMessage(String roomId, String text) async {
    final myId = currentUserId;
    if (myId == null) return;

    final messageId = const Uuid().v4();
    final timestamp = DateTime.now();

    final message = ChatMessage(
      id: messageId,
      senderId: myId,
      text: text,
      timestamp: timestamp,
    );

    // Batch write to ensure message is added AND room info is updated atomically
    final batch = _firestore.batch();

    // Add message
    final messageRef = _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId);
    
    batch.set(messageRef, message.toMap());

    // Identify the *other* participant to increment their unread count
    final otherUserId = roomId.split('_').firstWhere((id) => id != myId, orElse: () => '');
    
    // Update Room (last message & unread count)
    final roomUpdate = {
      'lastMessage': text,
      'lastMessageTime': Timestamp.fromDate(timestamp),
    };

    if (otherUserId.isNotEmpty) {
      roomUpdate['unreadCounts.$otherUserId'] = FieldValue.increment(1);
    }

    final roomRef = _firestore.collection('chat_rooms').doc(roomId);
    batch.update(roomRef, roomUpdate);

    await batch.commit();
  }

  // 3. Get Messages Stream
  Stream<List<ChatMessage>> getMessages(String roomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // 4. Get User Chat Rooms Stream
  Stream<List<ChatRoom>> getUserChatRooms() {
    final myId = currentUserId;
    if (myId == null) return const Stream.empty();

    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: myId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // 5. Mark Message as Read (Legacy - kept for compatibility)
  Future<void> markMessageAsRead(String roomId, String messageId) async {
    // ... implementation ...
  }
  
  // 6. Mark Chat Room as Read (Reset Unread Count)
  Future<void> markChatAsRead(String roomId) async {
    final myId = currentUserId;
    if (myId == null) return;

    try {
      await _firestore.collection('chat_rooms').doc(roomId).update({
        'unreadCounts.$myId': 0,
      });
    } catch (e) {
      print('Error marking chat as read: $e');
    }
  }
  // 7. Get Chat Room Stream (for real-time updates like typing)
  Stream<ChatRoom> getChatRoomStream(String roomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
           throw Exception("Room not found");
          }
          return ChatRoom.fromMap(doc.data()!, doc.id);
        });
  }

  // 8. Set Typing Status
  Future<void> setTypingStatus(String roomId, bool isTyping) async {
    final myId = currentUserId;
    if (myId == null) return;

    final roomRef = _firestore.collection('chat_rooms').doc(roomId);

    if (isTyping) {
      await roomRef.update({
        'typingUsers': FieldValue.arrayUnion([myId]),
      });
    } else {
      await roomRef.update({
        'typingUsers': FieldValue.arrayRemove([myId]),
      });
    }
  }
}
