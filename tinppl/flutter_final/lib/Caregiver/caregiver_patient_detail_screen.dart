import 'package:flutter/material.dart';

class CaregiverPatientDetailScreen extends StatefulWidget {
  final String patientName;

  const CaregiverPatientDetailScreen({super.key, required this.patientName});

  @override
  _CaregiverPatientDetailScreenState createState() => _CaregiverPatientDetailScreenState();
}

class _CaregiverPatientDetailScreenState extends State<CaregiverPatientDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Container()), // 왼쪽 빈 공간 확보
            Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                "LOGO",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: Container()), // 오른쪽 빈 공간 확보
          ],
        ),
        centerTitle: true, // iOS에서도 중앙 정렬 유지
        actions: [Container(width: 48)], // leading 버튼과 균형 맞추기 위해 추가
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                // 이름 수정 로직 추가 가능
              },
              child: const Text(
                "이름 수정하기",
                style: TextStyle(fontSize: 14, color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.patientName, // ✅ 선택한 환자의 이름 표시
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            _buildButton("환자 정보 보기", Icons.info, () {
              Navigator.pushNamed(
                context,
                '/caregiver_patient_info',
                arguments: {
                  'name': widget.patientName, // 전달된 환자 이름
                  'care_region': "서울, 경기",
                  'care_place': "집",
                  'gender': "여성",
                  'height': 165,
                  'weight': 60,
                  'diagnosis': "고혈압, 당뇨",
                  'symptoms': ["어지러움", "만성 피로", "고혈압"],
                },
              );
            }),

            const SizedBox(height: 15),
            _buildButton("환자와의 대화", Icons.chat_bubble_outline, () {}),

            const SizedBox(height: 15),
            _buildButton("간병일지 작성하기", Icons.edit, () {
              Navigator.pushNamed(
                context,
                '/caregiver_patient_logs',
                arguments: {'patientName': widget.patientName}, // ✅ 해당 환자의 이름 전달
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/caregiver_profile'); // ✅ "프로필" 클릭 시 이동
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "프로필",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: "환자 관리",
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: const TextStyle(fontSize: 16, color: Colors.black)),
            const SizedBox(width: 5),
            Icon(icon, color: Colors.black, size: 18),
          ],
        ),
      ),
    );
  }
}
