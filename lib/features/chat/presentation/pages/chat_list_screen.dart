import 'package:flutter/material.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/features/chat/data/models/chat_room.dart';
import 'package:tutor_finder_app/features/chat/data/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:tutor_finder_app/core/utils/image_helper.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatRoom>>(
      stream: _chatService.getUserChatRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final chatRooms = snapshot.data ?? [];

        if (chatRooms.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No messages yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final room = chatRooms[index];
              
              // Identify the "other" user ID
              final otherUserId = room.participants.firstWhere(
                (id) => id != _currentUserId,
                orElse: () => '',
              );

              if (otherUserId.isEmpty) return const SizedBox.shrink();

              // OPTIMIZATION: Use cached data ONLY if it matches the other user
              // (fixes bug where shared cache shows "Self" to the receiver)
              if (room.otherUserData != null && room.otherUserData!['uid'] == otherUserId) {
                final name = room.otherUserData!['name'] ?? 'Chat';
                final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    backgroundImage: ImageHelper.getUserImageProvider(room.otherUserData?['profileImageUrl']),
                    child: room.otherUserData?['profileImageUrl'] == null
                        ? Text(
                            initial,
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          )
                        : null,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    room.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                       fontWeight: _isMessageUnread(room) ? FontWeight.bold : FontWeight.normal,
                       color: _isMessageUnread(room) ? Colors.black : Colors.grey[600],
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(room.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12, 
                          color: _getUnreadCount(room) > 0 ? Theme.of(context).primaryColor : Colors.grey
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_getUnreadCount(room) > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${_getUnreadCount(room)}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  onTap: () async {
                    // Mark as read immediately when tapping
                    await _chatService.markChatAsRead(room.id);

                    // Fetch user and navigate
                    final user = await _authService.getUserById(otherUserId);
                    if (user != null && context.mounted) {
                       Navigator.pushNamed(
                        context,
                        AppRoutes.chatScreen,
                        arguments: {
                          'roomId': room.id,
                          'otherUser': user,
                        },
                      );
                    }
                  },
                );
              }

              // Fallback for old rooms without cache
              return FutureBuilder<UserModel?>(
                future: _authService.getUserById(otherUserId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text('Loading...'),
                    );
                  }

                  final otherUser = userSnapshot.data!;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      backgroundImage: ImageHelper.getUserImageProvider(otherUser.profileImageUrl),
                      child: otherUser.profileImageUrl == null
                          ? Text(
                              (otherUser.firstName ?? '').isNotEmpty ? otherUser.firstName![0].toUpperCase() : '?',
                              style: TextStyle(color: Theme.of(context).primaryColor),
                            )
                          : null,
                    ),
                    title: Text(
                      '${otherUser.firstName ?? ''} ${otherUser.lastName ?? ''}'.trim(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      room.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatDate(room.lastMessageTime),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.chatScreen,
                        arguments: {
                          'roomId': room.id,
                          'otherUser': otherUser,
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
    );
  }

  int _getUnreadCount(ChatRoom room) {
    if (_currentUserId.isEmpty) return 0;
    return room.unreadCounts[_currentUserId] ?? 0;
  }

  bool _isMessageUnread(ChatRoom room) {
    return _getUnreadCount(room) > 0;
  }

  String _formatDate(DateTime date) {
    // Simple date formatting helper
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(date); // Today: 5:30 PM
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(date); // This week: Mon, Tue
    } else {
      return DateFormat.yMd().format(date); // Older: 1/1/2025
    }
  }
}
