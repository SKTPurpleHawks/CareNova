import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'user_type_selection_screen.dart';
import 'package:app/protector_home_screen.dart';
import 'package:app/foreign_home_screen.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // 패스워드 보기 토글 상태
  bool _isLoading = false; // 로그인 버튼 로딩 상태
  bool _isCancelled = false;


  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _isCancelled = false; // 취소 플래그 초기화
    });

    final String baseUrl = "http://172.23.250.30:8000";
    final String url = "$baseUrl/login";

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': _emailController.text,
              'password': _passwordController.text,
            }),
          )
          .timeout(Duration(seconds: 5));
      if (_isCancelled) return; // 취소된 경우 결과 무시

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['access_token'];
        final userType = responseData['user_type'];

        // 사용자 유형에 따라 다른 화면으로 이동
        if (userType == 'foreign') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ForeignHomeScreen(token: token)),
          );
        } else if (userType == 'protector') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProtectorUserHomeScreen(token: token)),
          );
        }
      } else if (response.statusCode == 404) {
        // 예를 들어 404 응답이면 없는 아이디라고 가정
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('존재하지 않는 아이디입니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인에 실패하였습니다. 다시 입력해 주세요.')),
        );
      }
    } on TimeoutException catch (_) {
      if (!_isCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해 주세요.')),
        );
      }
    } catch (error) {
      if (!_isCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('예기치 않은 오류가 발생했습니다.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF43C098); // 고급스러운 색상 유지
    final Color accentColor = Color(0xFF43C098);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // ✅ 타이틀 가운데 정렬
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Image.asset(
          'assets/images/textlogo.png',
          height: 25,
          fit: BoxFit.contain,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 140),

            // 로그인 제목
            Text(
              '로그인',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKr(
                fontSize: 26,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 40),

            // 이메일 입력 필드
            _buildInputField(
              label: '이메일',
              isPassword: false,
              icon: Icons.email_outlined,
              controller: _emailController,
            ),

            const SizedBox(height: 16),

            // 비밀번호 입력 필드
            _buildInputField(
              label: '비밀번호',
              isPassword: true,
              icon: Icons.lock_outline,
              controller: _passwordController,
            ),

            const SizedBox(height: 40),

            // 로그인 버튼
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      '로그인',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // 회원가입 버튼
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserTypeSelectionScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[500], // ElevatedButton과 같은 배경색
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                '회원가입',
                style: GoogleFonts.notoSansKr(
                  fontSize: 18, // ElevatedButton과 동일한 폰트 크기
                  fontWeight: FontWeight.w500,
                  color: Colors.white, // 텍스트 색상을 ElevatedButton과 동일하게 설정
                ),
              ),
            ),

            const SizedBox(height: 30),
            TextButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => UserTypeSelectionScreen()),
                // );
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '아이디/비밀번호 찾기 >',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.grey[500],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **입력 필드 위젯 (아이콘 포함 & 패스워드 보기 추가)**
  Widget _buildInputField({
    required String label,
    required bool isPassword,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black54), // 아이콘 추가
        labelText: label,
        labelStyle: GoogleFonts.notoSansKr(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black87),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.black54),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }
}
