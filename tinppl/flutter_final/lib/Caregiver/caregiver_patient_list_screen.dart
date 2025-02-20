import 'package:flutter/material.dart';

class CaregiverPatientListScreen extends StatelessWidget {
  const CaregiverPatientListScreen({super.key});

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
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 1, // "환자 관리" 활성화
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

  // 🔹 환자 카드 위젯
  Widget _buildPatientCard(BuildContext context, String patientName) {
    return GestureDetector(
      onTap: () {
        print("Clicked on: $patientName"); // ✅ 디버깅 로그 추가

        Navigator.pushNamed(
          context,
          '/caregiver_patient_detail', // ✅ 상세 화면으로 이동
          arguments: patientName, // ✅ 선택한 환자의 이름 전달
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_outline, size: 24, color: Colors.black),
            const SizedBox(width: 10),
            Text(
              patientName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
