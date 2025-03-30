import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swlab_sllm_app/providers/chat_provider.dart';
import 'package:swlab_sllm_app/screens/chat_screen.dart';
import 'package:swlab_sllm_app/services/auth_service.dart';
import 'package:swlab_sllm_app/theme/colors.dart';
import 'package:swlab_sllm_app/utils/profile_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final TextEditingController _textController = TextEditingController();
  OverlayEntry? _overlayEntry;
  final GlobalKey _profileButtonKey = GlobalKey();

  final double minHeight = 600;

  // 사이드바 관련 변수
  bool _isSidebarExpanded = true;
  late AnimationController _sidebarAnimationController;
  late Animation<double> _sidebarAnimation;

  // 오버레이 제거 함수
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // 사이드바 토글 함수
  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
      if (_isSidebarExpanded) {
        _sidebarAnimationController.reverse();
      } else {
        _sidebarAnimationController.forward();
      }
    });
  }

  void _showProfileMenu() {
    // 현재 오버레이가 표시 중이면 제거
    _removeOverlay();

    // ProfileMenuUtil 사용 - 사용자 정보를 전달할 필요 없음
    ProfileMenuUtil.showProfileMenu(
      context,
      buttonKey: _profileButtonKey,
      onRemove: _removeOverlay,
      onOverlayCreated: (entry) {
        _overlayEntry = entry;
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // 사이드바 애니메이션 컨트롤러 초기화
    _sidebarAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // 사이드바 너비 애니메이션 (200 <-> 0)
    _sidebarAnimation = Tween<double>(
      begin: 200.0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _sidebarAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _removeOverlay();
    _textController.dispose();
    _sidebarAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final user = _authService.currentUser;

    // 화면 크기 가져오기
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;

    // 최소 높이 적용
    final containerHeight = screenHeight > minHeight ? screenHeight : minHeight;

    return Scaffold(
      body: Stack(
        children: [
          // 사이드바
          AnimatedBuilder(
              animation: _sidebarAnimation,
              builder: (context, child) {
                // 사이드바가 일정 너비 이하로 줄어들면 내부 콘텐츠를 숨김
                final bool showContent =
                    _sidebarAnimation.value > 120; // 임계값 설정

                return Container(
                  width: _sidebarAnimation.value,
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      // 로고 자리 공간 확보 (투명)
                      SizedBox(height: 60),
                      if (_isSidebarExpanded && showContent) ...[
                        SizedBox(
                          height: 25,
                        ),
                        // 새 채팅 버튼
                        Material(
                          color: Colors.transparent, // 배경색 투명하게 설정
                          child: InkWell(
                            onTap: () {
                              print('새 채팅 버튼이 클릭되었습니다');
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: SKKUColors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "새 채팅",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        // 최근 항목 텍스트
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "최근 항목",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // 채팅 목록
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3, // 실제 데이터 길이로 변경 예정
                            itemBuilder: (context, index) {
                              // 샘플 데이터 (실제로는 데이터 모델에서 가져옴)
                              final chatItems = [
                                {"text": "세 번째 대화"},
                                {"text": "두 번째 대화"},
                                {"text": "첫 번째 대화"},
                              ];
                              return Material(
                                color: Colors.grey[100],
                                child: InkWell(
                                  onTap: () {
                                    print(
                                        '채팅 "${chatItems[index]["text"]}"이 클릭되었습니다');
                                  },
                                  child: Container(
                                    width: double.infinity, // 가로 전체 너비 사용
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    child: Text(
                                      chatItems[index]["text"] as String,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ]
                    ],
                  ),
                );
              }),

          // 메인 컨텐츠 영역
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(
                left: _isSidebarExpanded ? 200 : 0), // 왼쪽 마진으로 위치 조정
            child: SizedBox(
              // 최소 높이 설정
              height: containerHeight,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 상단 헤더 영역 (로고와 프로필 버튼)
                    Container(
                      height:
                          kToolbarHeight + MediaQuery.of(context).padding.top,
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top),
                      color: null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: Tooltip(
                              message: "사용자 프로필",
                              child: Material(
                                key: _profileButtonKey,
                                color: Colors.transparent,
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    shape: BoxShape.circle,
                                  ),
                                  child: InkWell(
                                    customBorder: CircleBorder(),
                                    onTap: _showProfileMenu,
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 본문 영역
                    SizedBox(
                      // 전체 높이에서 헤더 높이를 뺀 값
                      height: containerHeight -
                          (kToolbarHeight + MediaQuery.of(context).padding.top),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "안녕하세요, ${user?.displayName} 님",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 40),
                          // 채팅 입력 영역
                          Center(
                            child: Container(
                              width: 1000,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 2,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    maxLines: null,
                                                    textInputAction:
                                                        TextInputAction.send,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    controller: _textController,
                                                    decoration: InputDecoration(
                                                      hintText: '무엇을 도와드릴까요?',
                                                      hintStyle: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 20,
                                                              horizontal: 20.0),
                                                    ),
                                                    onSubmitted: (text) {
                                                      if (!chatProvider
                                                              .isLoading &&
                                                          _textController.text
                                                              .isNotEmpty) {
                                                        chatProvider
                                                            .sendMessage(text);
                                                        _textController.clear();

                                                        // ChatScreen으로 이동
                                                        Navigator.pushNamed(
                                                            context, '/chat');
                                                      }
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10, top: 10),
                                                  decoration: BoxDecoration(
                                                    color: SKKUColors.green,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: IconButton(
                                                    icon: Icon(
                                                        Icons.arrow_upward,
                                                        color: Colors.white),
                                                    onPressed: () {
                                                      if (!chatProvider
                                                              .isLoading &&
                                                          _textController.text
                                                              .isNotEmpty) {
                                                        chatProvider
                                                            .sendMessage(
                                                                _textController
                                                                    .text);
                                                        _textController.clear();

                                                        // ChatScreen으로 이동
                                                        Navigator.pushNamed(
                                                            context, '/chat');
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // 추가 입력 옵션 (+ 버튼)
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.only(
                                                  left: 10.0, bottom: 10.0),
                                              child: Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.grey[300]!),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.add,
                                                      size: 20,
                                                      color: Colors.grey),
                                                  onPressed: () {
                                                    // 추가 버튼 클릭 시
                                                    // 파일 추가 등의 로직 설정
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 로고 및 토글 버튼 (위 레이어)
          Positioned(
            top: 0,
            left: 0,
            height: 60,
            width: 200,
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 13, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/images/SKKULLM.png",
                      width: 120,
                    ),
                    IconButton(
                      onPressed: _toggleSidebar,
                      icon: Icon(_isSidebarExpanded
                          ? Icons.keyboard_double_arrow_left_rounded
                          : Icons.keyboard_double_arrow_right_rounded),
                      tooltip: _isSidebarExpanded ? "사이드바 접기" : "사이드바 펼치기",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
