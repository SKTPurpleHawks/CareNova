import 'package:flutter/material.dart';

class GuardianPatientSelectionScreen extends StatefulWidget {
  const GuardianPatientSelectionScreen({super.key});

  @override
  State<GuardianPatientSelectionScreen> createState() =>
      _GuardianPatientSelectionScreenState();
}

class _GuardianPatientSelectionScreenState
    extends State<GuardianPatientSelectionScreen> {
  List<String> patients = ['환자 1', '환자 2']; // 등록된 환자 목록
  String? selectedPatient; // 선택된 환자

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
      body: Column(
        children: [
          const SizedBox(height: 140),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '검색을 위해 불러올 환자 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),

                // ✅ 환자 리스트 스크롤 가능하게 처리
                SizedBox(
                  height: 200, // 높이 제한 설정 (원하는 크기로 조정 가능)
                  child: ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      final isSelected = selectedPatient == patient;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedPatient = patient;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? const Color(0xFF43C098)
                                : Colors.white,
                            foregroundColor:
                                isSelected ? Colors.white : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF43C098)
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            elevation: isSelected ? 4 : 0,
                          ),
                          child: Text(
                            patient,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 검색하기 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: selectedPatient == null
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              '/caregiver_list',
                              arguments: selectedPatient,
                            );
                          },
                    icon: const Icon(Icons.search),
                    label: const Text('검색하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF43C098),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0, // 현재 선택된 탭 (간병인 찾기)
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/guardian_patient_list');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search, color: Color(0xFF43C098)),
            label: '간병인 찾기',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit),
            selectedIcon: Icon(Icons.edit, color: Color(0xFF43C098)),
            label: '내 환자 정보',
          ),
        ],
      ),
    );
  }
}
