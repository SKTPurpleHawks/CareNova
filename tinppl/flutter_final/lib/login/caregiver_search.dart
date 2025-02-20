import 'package:flutter/material.dart';

class CaregiverSearchScreen extends StatelessWidget {
  const CaregiverSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch, // 버튼 전체 너비 사용

          children: [
            // 간병 일감을 찾으시나요? 버튼

            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/login_caregiver'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16), // 높이 조정
                side: const BorderSide(color: Colors.black), // 테두리 추가
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 버튼 모서리 둥글게
                ),
              ),
              child: const Text(
                '간병 일감을 찾으시나요?',
                style: TextStyle(color: Colors.black),
              ),
            ),


            const SizedBox(height: 16), // 버튼 간격 추가

            // 간병인을 찾고 계신가요? 버튼
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/login_guardian'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '간병인을 찾고 계신가요?',
                style: TextStyle(color: Colors.black),
              ),
            ),


            const SizedBox(height: 64), // 버튼과 "되돌아가기" 간격 추가

            // 되돌아가기 버튼 (하단 배치)
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/language'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // 버튼 색상 검정
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '되돌아가기',
                style: TextStyle(color: Colors.white), // 글자색 흰색
              ),
            ),
          ],
        ),
      ),
    );
  }
}
