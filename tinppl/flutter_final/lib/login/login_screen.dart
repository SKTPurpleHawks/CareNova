import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  final String userType; // 'caregiver' 또는 'guardian'

  const LoginScreen({super.key, required this.userType});

  void _goToSignup(BuildContext context) {
    if (userType == 'caregiver') {
      Navigator.pushNamed(context, '/caregiver_signup');
    } else if (userType == 'guardian') {
      Navigator.pushNamed(context, '/guardian_signup');
    } else {
      print('Error: Invalid userType -> $userType'); // 디버깅 로그
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF43C098); // 메인 컬러 (초록)

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // 그림자 제거
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // 제목
            Text(
              userType == 'caregiver' ? '간병인 로그인' : '보호자 로그인',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKr(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 150),

            // 이메일 입력 필드
            _buildInputField(label: '이메일', isPassword: false),

            const SizedBox(height: 16),

            // 비밀번호 입력 필드
            _buildInputField(label: '비밀번호', isPassword: true),

            const SizedBox(height: 24),

            // 로그인 버튼
            ElevatedButton(
              onPressed: () {
                if (userType == 'caregiver') {
                  Navigator.pushNamed(context, '/caregiver_profile');
                } else if (userType == 'guardian') {
                  Navigator.pushNamed(context, '/guardian_patient_selection');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '로그인',
                style: GoogleFonts.notoSansKr(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 회원가입 버튼 (하단 고정)
            const Spacer(), // 화면의 하단으로 이동
            TextButton(
              onPressed: () => _goToSignup(context),
              child: Text(
                '회원가입',
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// **공통 입력 필드 위젯**
  Widget _buildInputField({required String label, required bool isPassword}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.notoSansKr(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black87),
        ),
      ),
    );
  }
}
