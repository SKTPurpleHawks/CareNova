import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextField(
              decoration: InputDecoration(labelText: '이메일', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),

            // 간병인 로그인 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (userType == 'caregiver') {
                    Navigator.pushNamed(context, '/caregiver_profile'); // ✅ 로그인 후 간병인 프로필로 이동
                  } else {
                    print('Error: userType is not caregiver -> $userType'); // 디버깅 로그
                  }
                },
                child: const Text('간병인 로그인'),
              ),

            ),

            // 보호자 로그인 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  print("로그인 시 userType: $userType"); // 디버깅용 로그 출력
                  if (userType == 'guardian') {
                    Navigator.pushNamed(context, '/guardian_patient_selection'); // 보호자 로그인 시 이동
                  } else {
                    print('Error: userType is not guardian -> $userType'); // 디버깅 로그
                  }
                },
                child: const Text('보호자 로그인'),
              ),
            ),

            // 회원가입 버튼
            TextButton(
              onPressed: () => _goToSignup(context),
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
