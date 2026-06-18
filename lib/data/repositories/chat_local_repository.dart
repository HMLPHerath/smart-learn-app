import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/sql_service.dart';

class ChatMessage {
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isSentByMe, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isSentByMe': isSentByMe,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'],
      isSentByMe: map['isSentByMe'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class ParentContact {
  final String parentId;
  final String fullName;
  final String? profilePictureUri;
  final String studentName;
  String lastMessage;
  int unreadCount;
  String time;

  ParentContact({
    required this.parentId,
    required this.fullName,
    this.profilePictureUri,
    required this.studentName,
    this.lastMessage = '',
    this.unreadCount = 0,
    this.time = '',
  });

  factory ParentContact.fromMap(Map<String, dynamic> map) {
    return ParentContact(
      parentId: map['ParentID'] ?? '',
      fullName: map['FullName'] ?? 'Unknown',
      profilePictureUri: map['ProfilePictureURI'],
      studentName: map['StudentName'] ?? '',
    );
  }
}

class ChatLocalRepository {
  final SqlService sqlService;
  
  ChatLocalRepository(this.sqlService);

  Future<List<ParentContact>> getParentsForTeacher(String teacherId) async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/teacher/$teacherId/parents');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['parents'] != null) {
          final List<dynamic> list = data['parents'];
          final parents = list.map((item) => ParentContact.fromMap(item)).toList();
          
          // Populate local last message for each parent
          final prefs = await SharedPreferences.getInstance();
          for (var p in parents) {
            final key = 'chat_${teacherId}_${p.parentId}';
            final jsonStr = prefs.getString(key);
            if (jsonStr != null) {
              final List<dynamic> decoded = jsonDecode(jsonStr);
              if (decoded.isNotEmpty) {
                final lastMsg = ChatMessage.fromMap(decoded.last);
                p.lastMessage = lastMsg.text;
                // Format time simply
                final now = DateTime.now();
                if (lastMsg.timestamp.day == now.day && lastMsg.timestamp.month == now.month) {
                  p.time = '${lastMsg.timestamp.hour.toString().padLeft(2, '0')}:${lastMsg.timestamp.minute.toString().padLeft(2, '0')}';
                } else {
                  p.time = 'Yesterday';
                }
              }
            } else {
               p.lastMessage = 'Tap to start chatting';
               p.time = '';
            }
          }
          return parents;
        }
      }
      return [];
    } catch (e) {
      print("Error fetching parents: $e");
      return [];
    }
  }

  Future<List<ChatMessage>> getMessages(String teacherId, String parentId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_${teacherId}_${parentId}';
    final jsonStr = prefs.getString(key);
    if (jsonStr != null) {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((item) => ChatMessage.fromMap(item)).toList();
    }
    return [];
  }

  Future<void> sendMessage(String teacherId, String parentId, String text) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_${teacherId}_${parentId}';
    
    List<ChatMessage> messages = await getMessages(teacherId, parentId);
    messages.add(ChatMessage(text: text, isSentByMe: true, timestamp: DateTime.now()));
    
    // Simulate an auto-reply for demo purposes
    messages.add(ChatMessage(
      text: "Thank you for the update. I will check on this.", 
      isSentByMe: false, 
      timestamp: DateTime.now().add(const Duration(seconds: 1))
    ));

    final jsonList = messages.map((m) => m.toMap()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }
}
