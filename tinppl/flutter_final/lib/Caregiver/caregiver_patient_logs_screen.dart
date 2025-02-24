import 'package:flutter/material.dart';

class CaregiverPatientLogsScreen extends StatelessWidget {
  final String patientName; // 환자 이름
  const CaregiverPatientLogsScreen({super.key, required this.patientName});

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
        title: Text(
          patientName, // ✅ 선택한 환자 이름 표시
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true, // ✅ 중앙 정렬
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {}, // 🔔 알림 기능 (추후 추가 가능)
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildLogCard(context, "간병일지 1", "2025.02.19"),
            const SizedBox(height: 10),
            _buildLogCard(context, "간병일지 2", "2025.02.20"),
            const SizedBox(height: 10),
            _buildLogCard(context, "간병일지 3", "2025.02.21"),
            const Spacer(), // 🔹 하단 버튼을 위해 빈 공간 추가
            _buildAddLogButton(context), // 🔹 간병일지 작성 버튼 추가
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 1, // ✅ "환자 관리" 활성화
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(
                context, '/caregiver_profile'); // ✅ "프로필" 클릭 시 이동
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

  // 🔹 간병일지 카드 위젯 (날짜 및 수정/삭제 기능 포함)
  Widget _buildLogCard(BuildContext context, String logTitle, String date) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/caregiver_patient_log_detail', // ✅ 간병일지 상세 페이지로 이동
          arguments: logTitle, // ✅ 선택한 일지 제목 전달
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            // ✅ 그림자 추가
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // 그림자 색 (연한 검은색)
              blurRadius: 5, // 흐림 정도
              // spreadRadius: 8, // 퍼지는 정도
              offset: const Offset(0, 4), // 그림자 위치 (아래쪽)
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // 배경색 흰색
                    shape: BoxShape.circle, // 원형 모양
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.edit, size: 24, color: Color(0xFF43C098)),
                ),
                const SizedBox(width: 10),
                Text(
                  logTitle,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  date, // ✅ 날짜 표시
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(width: 10),
                _buildMoreOptionsButton(
                    context, logTitle), // 🔹 ⋮ 버튼 추가 (수정/삭제)
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 점 세 개 (⋮) 버튼 추가 (수정/삭제 기능)
  Widget _buildMoreOptionsButton(BuildContext context, String logTitle) {
    return PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.black), // ⋮ 아이콘 추가
        onSelected: (value) {
          if (value == 'edit') {
            _editLog(context, logTitle);
          } else if (value == 'delete') {
            _deleteLog(context, logTitle);
          }
        },
        itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text("수정")),
              const PopupMenuItem(value: 'delete', child: Text("삭제")),
            ],
        color: Colors.white);
  }

  // 🔹 간병일지 수정 함수 (수정 화면으로 이동)
  void _editLog(BuildContext context, String logTitle) {
    Navigator.pushNamed(
      context,
      '/caregiver_patient_log_edit', // ✅ 수정 페이지로 이동
      arguments: logTitle,
    );
  }

  // 🔹 간병일지 삭제 함수 (삭제 확인 다이얼로그 표시)
  void _deleteLog(BuildContext context, String logTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("간병일지 삭제"),
          content: Text("'$logTitle'을 삭제하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("간병일지가 삭제되었습니다.")),
                );
              },
              child: const Text("삭제", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // 🔹 간병일지 작성 버튼
// 🔹 간병일지 작성 버튼
  Widget _buildAddLogButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/caregiver_patient_log_create');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF43C098),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 0, // 기본 elevation 제거 (그림자 중복 방지)
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("간병일지 작성",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(width: 8),
              Icon(Icons.add, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
