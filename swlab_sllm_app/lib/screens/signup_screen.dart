import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swlab_sllm_app/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isLoading = false;
  String _errorMessage = '';
  String _name = '';

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        await _authService.signUpWithEmailAndPassword(_email, _password, _name);
        // 회원가입 성공 시 이전 화면으로 돌아가기
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message ?? '회원가입에 실패했습니다.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
        backgroundColor: Colors.white,
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
                    decoration: InputDecoration(labelText: '이메일'),
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
                      if (value.length < 6) {
                        return '비밀번호는 6자 이상이어야 합니다';
                      }
                      return null;
                    },
                    onChanged: (value) => _password = value.trim(),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: max(450,
                      MediaQuery.of(context).size.width * 0.4), // 두 값 중 큰 값 사용
                  child: TextFormField(
                    decoration: InputDecoration(labelText: '비밀번호 확인'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 다시 입력하세요';
                      }
                      if (value != _password) {
                        return '비밀번호가 일치하지 않습니다';
                      }
                      return null;
                    },
                    onChanged: (value) => _confirmPassword = value.trim(),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: max(450, MediaQuery.of(context).size.width * 0.4),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: '이름'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이름을 입력하세요';
                      }
                      return null;
                    },
                    onChanged: (value) => _name = value.trim(),
                  ),
                ),
                SizedBox(height: 16),
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
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('회원가입'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
