import 'package:flutter/foundation.dart';
import '../services/llm_service.dart';

class Message {
  final String content;
  final bool isUser;

  Message({required this.content, required this.isUser});
}

class ChatProvider with ChangeNotifier {
  final LlmService _llmService;
  final List<Message> _messages = [];
  bool _isLoading = false;

  ChatProvider({required LlmService llmService}) : _llmService = llmService;

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 사용자 메시지 추가
    _messages.add(Message(content: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      // AI 응답 요청
      final response = await _llmService.askLlama(text);

      // AI 메시지 추가
      _messages.add(Message(content: response, isUser: false));
    } catch (e) {
      _messages.add(Message(content: '오류 발생: $e', isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
