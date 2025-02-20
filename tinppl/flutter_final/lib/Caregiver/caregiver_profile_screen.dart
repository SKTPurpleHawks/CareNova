import 'package:flutter/material.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  _CaregiverProfileScreenState createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  bool isJobInfoEnabled = false; // ✅ 스위치 상태 저장  const CaregiverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

        title: Center(
          child: Container(
            width: 100, // 🔥 로고 박스 너비
            height: 40, // 🔥 로고 박스 높이
            decoration: BoxDecoration(
              color: Colors.grey[300], // 🔥 회색 박스
              borderRadius: BorderRadius.circular(8), // 🔥 모서리 둥글게
            ),
            alignment: Alignment.center,
            child: Text(
              "LOGO",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [


            SizedBox(height: 50), // 🔥 프로필 카드 위쪽에 여백 추가
            // 프로필 카드
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "나이: 52   성별: 여성   키: 192",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "홍길동",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 80,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "간병인 정보를 입력하세요.",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 100),

            // 프로필 수정 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/caregiver_edit_profile');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("프로필 수정", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            SizedBox(height: 30),

            // 구인 정보 띄우기 버튼 (스위치 포함)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isJobInfoEnabled = !isJobInfoEnabled; // 버튼 클릭 시 스위치 토글
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 둥글게
                ),
                padding: EdgeInsets.symmetric(horizontal: 16), // 좌우 패딩 추가
              ),
              child: Stack(
                alignment: Alignment.center, // 🔥 텍스트를 중앙에 배치
                children: [
                  Align(
                    alignment: Alignment.center, // 텍스트 중앙 정렬
                    child: Text(
                      "구인 정보 띄우기",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight, // 스위치를 오른쪽 정렬
                    child: Switch(
                      value: isJobInfoEnabled,
                      activeColor: Colors.teal,
                      onChanged: (value) {
                        setState(() {
                          isJobInfoEnabled = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // 구인 관리 버튼
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 둥글게
                ),
              ),
              child: Text("구인 관리", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),

      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/caregiver_patient_list'); // ✅ 네비게이션 바에서 "환자 관리" 클릭 시 이동
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
}