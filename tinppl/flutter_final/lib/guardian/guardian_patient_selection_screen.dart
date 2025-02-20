import 'package:flutter/material.dart';

class GuardianPatientSelectionScreen extends StatefulWidget {
  const GuardianPatientSelectionScreen({super.key});

  @override
  State<GuardianPatientSelectionScreen> createState() => _GuardianPatientSelectionScreenState();
}

class _GuardianPatientSelectionScreenState extends State<GuardianPatientSelectionScreen> {
  List<String> patients = ['환자 1', '환자 2']; // 등록된 환자 목록
  String? selectedPatient; // 선택된 환자

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('환자 선택'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 220),

          // 박스 스타일의 선택 UI
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[300], // 배경 색상
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '검색을 위해 불러올 환자 정보',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // 환자 선택 버튼 리스트
                for (var patient in patients)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedPatient = patient;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedPatient == patient ? Colors.grey[600] : Colors.white,
                        foregroundColor: selectedPatient == patient ? Colors.white : Colors.black,
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(patient),
                    ),
                  ),

                const SizedBox(height: 16),

                // 검색하기 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: selectedPatient == null
                        ? null
                        : () {
                      Navigator.pushNamed(
                        context,
                        '/caregiver_list', // ✅ 설정된 라우트 사용
                        arguments: selectedPatient, // ✅ 선택한 환자 정보 전달
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('검색하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),

      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '간병인 찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: '내 환자 정보'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '마이페이지'),
        ],
        currentIndex: 0, // 현재 선택된 탭 (간병인 찾기)
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/guardian_patient_list'); // ✅ "내 환자 정보" 화면으로 이동
          }
        },
      ),
    );
  }
}

































// import 'package:flutter/material.dart';
//
// class GuardianPatientSelectionScreen extends StatefulWidget {
//   const GuardianPatientSelectionScreen({super.key});
//
//   @override
//   State<GuardianPatientSelectionScreen> createState() => _GuardianPatientSelectionScreenState();
// }
//
// class _GuardianPatientSelectionScreenState extends State<GuardianPatientSelectionScreen> {
//   List<String> patients = ['환자 1', '환자 2']; // 등록된 환자 목록
//   String? selectedPatient; // 선택된 환자
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('환자 선택'),
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 220),
//
//           // 박스 스타일의 선택 UI
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey[300], // 배경 색상
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//
//                 const Text(
//                   '검색을 위해 불러올 환자 정보',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//
//                 // 환자 선택 버튼 리스트
//                 for (var patient in patients)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 10),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           selectedPatient = patient;
//                         });
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: selectedPatient == patient ? Colors.grey[600] : Colors.white,
//                         foregroundColor: selectedPatient == patient ? Colors.white : Colors.black,
//                         side: const BorderSide(color: Colors.black),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       child: Text(patient),
//                     ),
//                   ),
//
//                 const SizedBox(height: 16),
//
//                 // 검색하기 버튼
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: selectedPatient == null
//                         ? null
//                         : () {
//                       Navigator.pushNamed(
//                         context,
//                         '/caregiver_list',
//                         arguments: selectedPatient,
//                       );
//                     },
//                     icon: const Icon(Icons.search),
//                     label: const Text('검색하기'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//
//       // 하단 네비게이션 바
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: '간병인 찾기'),
//           BottomNavigationBarItem(icon: Icon(Icons.edit), label: '내 환자 정보'),
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: '마이페이지'),
//         ],
//         currentIndex: 0, // 현재 선택된 탭 (간병인 찾기)
//         selectedItemColor: Colors.black,
//         unselectedItemColor: Colors.grey,
//         showUnselectedLabels: true,
//         onTap: (index) {
//           if (index == 1) {
//             Navigator.pushNamed(context, '/guardian_patient_list'); // ✅ "내 환자 정보" 화면으로 이동
//           }
//         },
//       ),
//     );
//   }
// }
