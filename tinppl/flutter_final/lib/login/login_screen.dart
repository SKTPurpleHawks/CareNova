import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  final String userType; // 'caregiver' 또는 'guardian'

  const LoginScreen({super.key, required this.userType});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false; // 패스워드 보기 토글 상태
  bool _isLoading = false; // 로그인 버튼 로딩 상태

  void _goToSignup(BuildContext context) {
    if (widget.userType == 'caregiver') {
      Navigator.pushNamed(context, '/caregiver_signup');
    } else if (widget.userType == 'guardian') {
      Navigator.pushNamed(context, '/guardian_signup');
    }
  }

  void _login() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      if (widget.userType == 'caregiver') {
        Navigator.pushNamed(context, '/caregiver_profile');
      } else if (widget.userType == 'guardian') {
        Navigator.pushNamed(context, '/guardian_patient_selection');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF43C098); // 🔥 더 고급스러운 블랙 메인 컬러
    final Color accentColor = Color(0xFF43C098); // 기존 초록색 유지

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),

            // 🟢 제목
            Text(
              widget.userType == 'caregiver' ? '간병인 로그인' : '보호자 로그인',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKr(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 100),

            // 🟢 이메일 입력 필드 (아이콘 포함)
            _buildInputField(
              label: '이메일',
              isPassword: false,
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 16),

            // 🟢 비밀번호 입력 필드 (패스워드 보기 기능 추가)
            _buildInputField(
              label: '비밀번호',
              isPassword: true,
              icon: Icons.lock_outline,
            ),

            const SizedBox(height: 24),

            // 🟢 로그인 버튼 (로딩 효과 추가)
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      '로그인',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),

            const SizedBox(height: 250),

            // 🟢 회원가입 버튼 (애니메이션 적용)
            TextButton(
              onPressed: () => _goToSignup(context),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '회원가입',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: accentColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// **입력 필드 위젯 (아이콘 포함 & 패스워드 보기 추가)**
  Widget _buildInputField(
      {required String label,
      required bool isPassword,
      required IconData icon}) {
    return TextField(
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black54), // 🟢 아이콘 추가
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
