import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Namaskar! I am Prithvi Fix AI Assistant. How can I help you today with cooperative bookings, artisan verification, or society bylaws?',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];
  bool _isSending = false;

  List<ChatMessage> get messages => _messages;
  bool get isSending => _isSending;

  final List<String> promptChips = [
    'How does the 93-2-5 escrow model work?',
    'I need an emergency electrician in Bhubaneswar',
    'How do I track my society registration timeline?',
    'What welfare benefits do verified artisans receive?',
  ];

  Future<void> sendMessage(String text, String language) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(text: text.trim(), isUser: true, timestamp: DateTime.now());
    _messages.add(userMsg);
    _isSending = true;
    notifyListeners();

    try {
      final historyPayload = _messages.map((m) => {
        'role': m.isUser ? 'user' : 'assistant',
        'content': m.text,
      }).toList();

      final res = await ApiClient().post(
        ApiEndpoints.aiChat,
        data: {
          'message': text.trim(),
          'history': historyPayload,
          'language': language,
        },
      );

      String reply = 'Thank you for contacting Prithvi Fix. Our cooperative helpline is also available at 1800-345-6789.';
      if (res is Map && res['reply'] != null) {
        reply = res['reply'].toString();
      } else if (res is Map && res['response'] != null) {
        reply = res['response'].toString();
      }

      _messages.add(ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()));
    } catch (e) {
      _messages.add(
        ChatMessage(
          text: 'We are experiencing high server volume. For immediate assistance, please call the Odisha State Cooperative Helpline at 1800-345-6789.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _messages.add(
      ChatMessage(
        text: 'Namaskar! How may I assist you today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
