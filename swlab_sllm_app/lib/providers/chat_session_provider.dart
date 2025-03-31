import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:swlab_sllm_app/models/chat_models.dart';
import 'package:swlab_sllm_app/services/firebase_service.dart';

class ChatSessionProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  List<Chat> _chatSessions = [];
  Chat? _activeChat;
  bool _loading = true;
  StreamSubscription? _chatsSubscription;

  ChatSessionProvider({required FirebaseService firebaseService})
      : _firebaseService = firebaseService {
    // 채팅 목록 불러오기
    _loadChats();
  }

  List<Chat> get chatSessions => List.unmodifiable(_chatSessions);
  Chat? get activeChat => _activeChat;
  bool get isLoading => _loading;

  // 채팅 세션 로딩
  void _loadChats() {
    // 현재 사용자 ID 체크
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) {
      print('No current user, cannot load chats');
      _chatSessions.clear();
      _activeChat = null;
      _loading = false;
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();

    // 기존 구독 취소
    _chatsSubscription?.cancel();

    // 새로운 구독 시작
    _chatsSubscription = _firebaseService.getUserChats().listen(
      (snapshot) {
        _chatSessions = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Chat(
            id: doc.id,
            title: data['title'] ?? '제목 없음',
            lastMessage: data['lastMessage'] ?? '',
            timestamp: data['timestamp'] != null
                ? (data['timestamp'] as Timestamp).toDate()
                : DateTime.now(),
            messages: [], // 메시지는 필요할 때 로드
          );
        }).toList();

        // 초기 채팅이 있으면 첫 번째 채팅 선택
        if (_chatSessions.isNotEmpty && _activeChat == null) {
          _activeChat = _chatSessions.first;
        }

        _loading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error loading chats: $error');
        _loading = false;
        _chatSessions = [];
        _activeChat = null;
        notifyListeners();
      },
      cancelOnError: true,
    );
  }

  // 채팅 생성
  Future<void> createNewChat() async {
    try {
      final chatId = await _firebaseService.createChat();
      selectChat(chatId);
    } catch (e) {
      print('새 채팅 생성 오류: $e');
    }
  }

  // 채팅 선택
  void selectChat(String chatId) {
    final chat = _chatSessions.firstWhere(
      (chat) => chat.id == chatId,
      orElse: () =>
          _chatSessions.isNotEmpty ? _chatSessions.first : null as Chat,
    );

    _activeChat = chat;
    notifyListeners();
  }

  // 채팅 제목 업데이트
  Future<void> updateChatTitle(String chatId, String newTitle) async {
    try {
      await _firebaseService.updateChatTitle(chatId, newTitle);
      // 실시간 리스너가 변경 감지
    } catch (e) {
      print('채팅 제목 업데이트 오류: $e');
    }
  }

  // 채팅 삭제
  Future<void> deleteChat(String chatId) async {
    try {
      await _firebaseService.deleteChat(chatId);
      // 삭제된 채팅이 활성 채팅인 경우, 다른 채팅 선택
      if (_activeChat?.id == chatId) {
        _activeChat =
            _chatSessions.where((chat) => chat.id != chatId).firstOrNull;
      }
      // 실시간 리스너가 변경 감지
    } catch (e) {
      print('채팅 삭제 오류: $e');
    }
  }

  // 로그아웃 시 상태 초기화
  void resetState() {
    // 구독 취소
    _chatsSubscription?.cancel();
    _chatsSubscription = null;

    // 상태 초기화
    _chatSessions.clear();
    _activeChat = null;
    _loading = true;
    notifyListeners();

    // 현재 사용자 ID 확인
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) {
      // 사용자가 없으면 완전히 초기화
      _loading = false;
      notifyListeners();
      return;
    }

    // 작은 지연 후 다시 로드
    Future.delayed(Duration(milliseconds: 500), () {
      _loadChats();
    });
  }

  @override
  void dispose() {
    // 구독 취소
    _chatsSubscription?.cancel();
    super.dispose();
  }
}
