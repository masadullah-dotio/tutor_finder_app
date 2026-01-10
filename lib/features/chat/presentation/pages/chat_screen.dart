import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tutor_finder_app/core/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:tutor_finder_app/core/theme/theme_provider.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/features/chat/data/models/chat_message.dart';
import 'package:tutor_finder_app/features/chat/data/models/chat_room.dart';
import 'package:tutor_finder_app/features/chat/data/services/chat_service.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final UserModel otherUser;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _typingTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_messageController.text.isNotEmpty && !_isTyping) {
      setState(() {
        _isTyping = true;
      });
      _chatService.setTypingStatus(widget.roomId, true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        setState(() {
          _isTyping = false;
        });
        _chatService.setTypingStatus(widget.roomId, false);
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _chatService.sendMessage(widget.roomId, text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: StreamBuilder<UserModel?>(
          stream: AuthService().getUserStream(widget.otherUser.uid),
          initialData: widget.otherUser,
          builder: (context, snapshot) {
            final otherUser = snapshot.data ?? widget.otherUser;
            final isOnline = otherUser.isActive; 

            return InkWell(
              onTap: () {
                // Navigate to Tutor Details (or generic Profile Page)
                // Note: 'TutorDetailsPage' is designed for Tutors, but can likely display any user info
                // or we might need a generic 'UserProfilePage'. For now, assuming standard Tutor profile.
                Navigator.pushNamed(
                  context, 
                  AppRoutes.tutorDetails,
                  arguments: {'tutor': otherUser, 'distanceKm': null},
                );
              },
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: CircleAvatar(
                          radius: 18,
                           backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Text(
                            (otherUser.firstName ?? '').isNotEmpty ? otherUser.firstName![0].toUpperCase() : '?',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      if (isOnline) 
                         Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${otherUser.firstName ?? ''} ${otherUser.lastName ?? ''}'.trim(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (isOnline)
                        Text(
                          'Online',
                          style: TextStyle(fontSize: 12, color: Colors.green[400]),
                        )
                      else 
                        const Text(
                          'Offline',
                           style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
           // Theme Toggle
           Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                onPressed: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(widget.roomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mark_chat_unread_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Say hi to ${widget.otherUser.firstName ?? 'User'}!',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUserId;

                    // Message Grouping Logic
                    final bool isFirstInGroup = index == messages.length - 1 || 
                        messages[index + 1].senderId != message.senderId;
                    
                    final bool isLastInGroup = index == 0 || 
                        messages[index - 1].senderId != message.senderId;

                    // Date Header Logic
                    bool showDateHeader = false;
                    if (index == messages.length - 1) {
                      showDateHeader = true; // Always show for oldest message
                    } else {
                      final nextMessage = messages[index + 1]; // "Next" here is actually older because reverse=true
                      if (!_isSameDay(message.timestamp, nextMessage.timestamp)) {
                        showDateHeader = true;
                      }
                    }
                    
                    // Mark as read if it's from existing user and not read
                    if (!isMe && !message.isRead) {
                       _chatService.markMessageAsRead(widget.roomId, message.id);
                    }

                    return Column(
                      children: [
                         if (showDateHeader) _buildDateHeader(message.timestamp),
                        _buildMessageBubble(message, isMe, isFirstInGroup, isLastInGroup),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildTypingIndicator(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Widget _buildDateHeader(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[800] 
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _formatDateHeader(date),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
     final now = DateTime.now();
     final today = DateTime(now.year, now.month, now.day);
     final yesterday = today.subtract(const Duration(days: 1));
     final dateToCheck = DateTime(date.year, date.month, date.day);

     if (dateToCheck == today) return 'Today';
     if (dateToCheck == yesterday) return 'Yesterday';
     return DateFormat.yMMMd().format(date);
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe, bool isFirst, bool isLast) {
    const double r = 20;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 2, 
          bottom: isLast ? 4 : 2,
          left: isMe ? 64 : 0, 
          right: isMe ? 0 : 64
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isMe 
              ? Theme.of(context).primaryColor 
              : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200]),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(r),
            topRight: Radius.circular(r),
            bottomLeft: !isMe && isLast ? Radius.zero : Radius.circular(r),
            bottomRight: isMe && isLast ? Radius.zero : Radius.circular(r),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe 
                    ? Colors.white 
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat.jm().format(message.timestamp), // 10:30 AM
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                   const SizedBox(width: 4),
                   Icon(
                     message.isRead ? Icons.done_all : Icons.done,
                     size: 14,
                     color: message.isRead ? Colors.white : Colors.white70,
                   )
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea( 
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[800] 
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 24,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTypingIndicator() {
    return StreamBuilder<ChatRoom>(
      stream: _chatService.getChatRoomStream(widget.roomId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final room = snapshot.data!;
        // Check if ANYONE else is typing (exclude me)
        final otherTypingUsers = room.typingUsers.where((uid) => uid != _currentUserId).toList();
        
        if (otherTypingUsers.isEmpty) return const SizedBox.shrink();

        // Assuming 1-on-1 for now, but scalable
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
               Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
               ),
               const SizedBox(width: 4),
               Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
               ),
               const SizedBox(width: 4),
               Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
               ),
               const SizedBox(width: 8),
              Text(
                'Typing...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
