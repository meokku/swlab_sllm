import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:swlab_sllm_app/models/chat_models.dart';
import 'package:swlab_sllm_app/services/firebase_service.dart';
import 'package:swlab_sllm_app/services/llm_service.dart';
import 'chat_session_provider.dart';

class ActiveChatProvider with ChangeNotifier {
  final LlmService _llmService;
  final ChatSessionProvider _chatSessionProvider;
  final FirebaseService _firebaseService;

  List<Message> _messages = [];
  bool _isLoading = false;
  Stream<QuerySnapshot>? _messagesStream;

  ActiveChatProvider({
    required LlmService llmService,
    required ChatSessionProvider chatSessionProvider,
    required FirebaseService firebaseService,
  })  : _llmService = llmService,
        _chatSessionProvider = chatSessionProvider,
        _firebaseService = firebaseService {
    // 채팅 세션 변경 감지
    _chatSessionProvider.addListener(_onActiveChatChanged);
    _onActiveChatChanged();
  }

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  void _onActiveChatChanged() {
    final activeChat = _chatSessionProvider.activeChat;
    if (activeChat != null) {
      _loadMessages(activeChat.id);
    } else {
      _messages = [];
      notifyListeners();
    }
  }

  void _loadMessages(String chatId) {
    // 이전 스트림 구독 취소
    _messagesStream = null;

    // 새 스트림 구독
    _messagesStream = _firebaseService.getChatMessages(chatId);
    _messagesStream?.listen((snapshot) {
      _messages = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Message(
          content: data['content'] ?? '',
          isUser: data['isUser'] ?? true,
          timestamp: data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();

      notifyListeners();
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 활성화된 채팅이 없으면 새로 만듦
    if (_chatSessionProvider.activeChat == null) {
      await _chatSessionProvider.createNewChat();
    }

    final activeChat = _chatSessionProvider.activeChat!;
    final userMessage = Message(
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _isLoading = true;
    notifyListeners();

    try {
      // 사용자 메시지 저장
      await _firebaseService.saveMessage(activeChat.id, userMessage);

      // AI 응답 요청
      final response = await _llmService.askLlama(text);

      // AI 메시지 저장
      final aiMessage = Message(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      await _firebaseService.saveMessage(activeChat.id, aiMessage);
    } catch (e) {
      // 오류 메시지 저장
      final errorMessage = Message(
        content: '오류 발생: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );

      await _firebaseService.saveMessage(activeChat.id, errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCurrentChat() {
    // Firebase에서는 실제 메시지를 삭제하는 대신 새 채팅을 만드는 것이 좋음
    _chatSessionProvider.createNewChat();
  }

  @override
  void dispose() {
    _chatSessionProvider.removeListener(_onActiveChatChanged);
    super.dispose();
  }
}
