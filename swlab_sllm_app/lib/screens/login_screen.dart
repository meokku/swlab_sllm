import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swlab_sllm_app/screens/chat_screen.dart';
import 'package:swlab_sllm_app/screens/home_screen.dart';
import 'package:swlab_sllm_app/screens/signup_screen.dart';
import 'package:swlab_sllm_app/services/auth_service.dart';
import 'package:swlab_sllm_app/theme/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String _errorMessage = '';

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        await _authService.signInWithEmailAndPassword(_email, _password);

        // mounted 체크 추가
        if (mounted) {
          // 로그인 성공 후 home 화면으로 이동
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } on FirebaseAuthException catch (e) {
        // mounted 체크 (안전을 위해)
        if (mounted) {
          setState(() {
            _errorMessage = e.message ?? '로그인에 실패했습니다.';
          });
        }
      } finally {
        // mounted 체크
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/images/SKKULLM.png",
          width: 120,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: max(450,
                      MediaQuery.of(context).size.width * 0.4), // 두 값 중 큰 값 사용
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: '이메일',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력하세요';
                      }
                      return null;
                    },
                    onChanged: (value) => _email = value.trim(),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: max(450,
                      MediaQuery.of(context).size.width * 0.4), // 두 값 중 큰 값 사용
                  child: TextFormField(
                    decoration: InputDecoration(labelText: '비밀번호'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력하세요';
                      }
                      return null;
                    },
                    onChanged: (value) => _password = value.trim(),
                  ),
                ),
                SizedBox(height: 24),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('로그인'),
                ),
                SizedBox(
                  height: 10,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text('계정이 없으신가요? 회원가입'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
