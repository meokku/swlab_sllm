import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swlab_sllm_app/screens/home_screen.dart';
import 'package:swlab_sllm_app/screens/login_screen.dart';
import 'package:swlab_sllm_app/screens/select_auth_screen.dart';
import 'package:swlab_sllm_app/screens/chat_screen.dart';
import 'package:swlab_sllm_app/providers/chat_provider.dart';
import 'package:swlab_sllm_app/screens/signup_screen.dart';
import 'package:swlab_sllm_app/services/llm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swlab_sllm_app/wrapper.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(
        llmService:
            // 학교 서버라 다른 port가 안 열리는 이슈가 있어서 일단 port 8000에서 ngrok 사용
            // 무료 계정이라 서버 새로 열 때마다 아래 주소 바꿔야 함
            LlmService(baseUrl: 'https://9b77-115-145-67-222.ngrok-free.app'),
      ),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'SKKU LLM',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.white,
        ),
        // home: ChatScreen(),
        // home: Wrapper(),
        // home: LoginScreen(),
        initialRoute: '/',
        routes: {
          '/': (context) => Wrapper(),
          '/home': (context) => HomeScreen(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignUpScreen(),
          '/chat': (context) => ChatScreen(),
        },
      ),
    );
  }
}
