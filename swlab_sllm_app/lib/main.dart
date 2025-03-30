import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swlab_sllm_app/providers/active_chat_provider.dart';
import 'package:swlab_sllm_app/providers/chat_session_provider.dart';
import 'package:swlab_sllm_app/screens/home_screen.dart';
import 'package:swlab_sllm_app/screens/login_screen.dart';
import 'package:swlab_sllm_app/screens/select_auth_screen.dart';
import 'package:swlab_sllm_app/screens/chat_screen.dart';
import 'package:swlab_sllm_app/screens/signup_screen.dart';
import 'package:swlab_sllm_app/services/firebase_service.dart';
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
    return MultiProvider(
      providers: [
        // Firebase 서비스
        Provider<FirebaseService>(
          create: (context) => FirebaseService(),
        ),

        // LLM 서비스
        Provider<LlmService>(
          create: (context) => LlmService(
            baseUrl: 'https://9b77-115-145-67-222.ngrok-free.app',
          ),
        ),

        // 채팅 세션 Provider
        ChangeNotifierProxyProvider<FirebaseService, ChatSessionProvider>(
          create: (context) => ChatSessionProvider(
            firebaseService: context.read<FirebaseService>(),
          ),
          update: (context, firebaseService, previous) =>
              previous ?? ChatSessionProvider(firebaseService: firebaseService),
        ),

        // 활성 채팅 Provider
        ChangeNotifierProxyProvider3<LlmService, ChatSessionProvider,
            FirebaseService, ActiveChatProvider>(
          create: (context) => ActiveChatProvider(
            llmService: context.read<LlmService>(),
            chatSessionProvider: context.read<ChatSessionProvider>(),
            firebaseService: context.read<FirebaseService>(),
          ),
          update: (context, llmService, chatSessionProvider, firebaseService,
                  previous) =>
              previous ??
              ActiveChatProvider(
                llmService: llmService,
                chatSessionProvider: chatSessionProvider,
                firebaseService: firebaseService,
              ),
        ),
      ],
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
