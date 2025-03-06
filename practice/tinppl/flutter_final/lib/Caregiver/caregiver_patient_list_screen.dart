import 'package:flutter/material.dart';

class CaregiverPatientListScreen extends StatefulWidget {
  const CaregiverPatientListScreen({super.key});

  @override
  _CaregiverPatientListScreenState createState() =>
      _CaregiverPatientListScreenState();
}

class _CaregiverPatientListScreenState
    extends State<CaregiverPatientListScreen> {
  int selectedIndex = 1; // ✅ 기본 선택 값 설정

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
            Expanded(child: Container()), // 🔹 왼쪽 빈 공간 확보
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
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: Container()), // 🔹 오른쪽 빈 공간 확보
          ],
        ),
        centerTitle: true, // ✅ iOS에서도 중앙 정렬 유지
        actions: [Container(width: 48)], // 🔹 leading 버튼과 균형 맞추기 위해 추가
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildPatientCard(context, "환자 1"),
            const SizedBox(height: 10),
            _buildPatientCard(context, "환자 2"),
            const SizedBox(height: 10),
            _buildPatientCard(context, "환자 3"),
          ],
        ),
      ),

      // ✅ 하단 네비게이션 바 수정
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });

          if (index == 0) {
            Navigator.pushReplacementNamed(context,
                '/caregiver_profile'); // ✅ pushReplacementNamed로 변경 (이전 페이지 히스토리 제거)
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF43C098)),
            label: "프로필",
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            selectedIcon: Icon(Icons.list_alt, color: Color(0xFF43C098)),
            label: "환자 관리",
          ),
        ],
      ),
    );
  }

  // 🔹 환자 카드 위젯
  Widget _buildPatientCard(BuildContext context, String patientName) {
    return GestureDetector(
      onTap: () {
        print("Clicked on: $patientName"); // ✅ 디버깅 로그 추가

        Navigator.pushNamed(
          context,
          '/caregiver_patient_info',
          arguments: {
            "name": patientName,
            "gender": "여성",
            "height": 165,
            "weight": 60,
            "care_region": "서울, 경기",
            "care_place": "집",
            "diagnosis": "고혈압, 당뇨",
            "symptoms": ["어지러움", "만성 피로", "고혈압"],
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            // ✅ 그림자 추가
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // 배경색 흰색
                shape: BoxShape.circle, // 원형 모양
              ),
              padding: EdgeInsets.all(8), // 아이콘과 배경 사이 간격
              child: Icon(
                Icons.person_outline,
                size: 24,
                color: Color(0xFF43C098),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              patientName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
