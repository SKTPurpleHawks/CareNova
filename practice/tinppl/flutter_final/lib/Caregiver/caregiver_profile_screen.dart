import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  _CaregiverProfileScreenState createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  bool isJobInfoEnabled = false; // ✅ 구인 정보 띄우기 상태
  bool isJobManagementEnabled = false; // ✅ 구인 관리 상태
  int selectedIndex = 0; // ✅ 네비게이션 바 선택 상태 추가

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 80),

            // 🟢 프로필 카드
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: const Color.fromARGB(0, 0, 0, 0), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.person,
                        size: 50, color: Color(0xFF43C098)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "홍길동",
                    style: GoogleFonts.notoSansKr(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // 🟢 프로필 수정 버튼
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Color(0xFF43C098),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Color(0xFF43C098), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 3,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/caregiver_edit_profile');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        textStyle: GoogleFonts.notoSansKr(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: const Text("프로필 수정"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 🟢 구인 정보 띄우기 버튼
// 구인 정보 띄우기 버튼
            GestureDetector(
              onTap: () {
                setState(() {
                  isJobInfoEnabled = !isJobInfoEnabled;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color:
                      isJobInfoEnabled ? const Color(0xFF43C098) : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: isJobInfoEnabled
                      ? Border.all(color: const Color(0xFF43C098), width: 1.5)
                      : Border.all(color: Colors.grey[200]!, width: 1.5),
                  boxShadow: [
                    // ✅ 그림자 추가
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "구인 정보 띄우기",
                        style: GoogleFonts.notoSansKr(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: isJobInfoEnabled
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : Colors.black,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
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
            ),

            const SizedBox(height: 10),

// 구인 관리 버튼
            GestureDetector(
              onTap: () {
                setState(() {
                  isJobManagementEnabled = !isJobManagementEnabled;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                constraints: const BoxConstraints(minHeight: 80),
                decoration: BoxDecoration(
                  color: isJobManagementEnabled
                      ? const Color(0xFF43C098)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: isJobManagementEnabled
                      ? Border.all(color: const Color(0xFF43C098), width: 1.5)
                      : Border.all(color: Colors.grey[200]!, width: 1.5),
                  boxShadow: [
                    // ✅ 그림자 추가
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "구인 관리",
                    style: GoogleFonts.notoSansKr(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color:
                          isJobManagementEnabled ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ], // ✅ 이 괄호를 추가해서 Column의 children 리스트를 닫아줘야 함
        ), // ✅ Column 위젯을 닫는 괄호 추가
      ), // ✅ SingleChildScrollView를 닫는 괄호 추가

      // 🟢 하단 네비게이션 바
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });

          if (index == 1) {
            Navigator.pushNamed(context, '/caregiver_patient_list');
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
}
