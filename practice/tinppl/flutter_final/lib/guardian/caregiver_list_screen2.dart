import 'package:flutter/material.dart';
import 'caregiver_detail_screen.dart';

class CaregiverListScreen2 extends StatelessWidget {
  final String patientName; // ✅ 선택한 환자 이름 저장

  const CaregiverListScreen2(
      {super.key, required this.patientName}); // ✅ required 추가

  final List<Map<String, dynamic>> caregivers = const [
    {
      "name": "이수민",
      "age": 49,
      "gender": "여성",
      "experience": 5,
      "height": 160,
      "weight": 60,
      "spot": "병원",
      "regions": ["서울", "인천"],
      "symptoms": ["치매", "섬망", "피딩", "기저귀케어"],
      "canWalkPatient": "지원 가능",
      "preferSex": "상관없음",
      "smoking": "비흡연",
      "matchingRate": 95.2,
      "rating": 4.8
    },
    {
      "name": "박지훈",
      "age": 36,
      "gender": "남성",
      "experience": 3,
      "height": 175,
      "weight": 70,
      "spot": "둘 다",
      "regions": ["부산", "경남"],
      "symptoms": ["하반신마비", "전신마비", "소변줄", "장루"],
      "canWalkPatient": "지원 불가능",
      "preferSex": "남성",
      "smoking": "흡연",
      "matchingRate": 89.7,
      "rating": 4.3
    },
    {
      "name": "최미경",
      "age": 33,
      "gender": "여성",
      "experience": 4,
      "height": 158,
      "weight": 50,
      "spot": "집",
      "regions": ["경기북부", "강원영서"],
      "symptoms": ["파킨슨", "재활", "야간집중돌봄"],
      "canWalkPatient": "상관없음",
      "preferSex": "여성",
      "smoking": "비흡연",
      "matchingRate": 92.4,
      "rating": 4.6
    },
    {
      "name": "최명일",
      "age": 27,
      "gender": "여성",
      "experience": 2,
      "height": 160,
      "weight": 55,
      "spot": "둘 다",
      "regions": ["부산", "울산"],
      "symptoms": ["와상환자"],
      "canWalkPatient": "걸을 수 없음",
      "preferSex": "여성",
      "smoking": "흡연",
      "matchingRate": 98.6,
      "rating": 5.0
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // ✅ 타이틀 가운데 정렬
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/textlogo.png',
          height: 25,
          fit: BoxFit.contain,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Center(
              child: Text(
                '*조건에 맞춘 간병인 추천 순위 리스트입니다*',
                style: TextStyle(
                    color: const Color.fromARGB(195, 0, 0, 0), fontSize: 14),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: caregivers.length,
                itemBuilder: (context, index) {
                  return _buildCaregiverCard(context, caregivers[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,

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

  Widget _buildCaregiverCard(BuildContext context, Map caregiver) {
    // ✅ context 추가

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(80),
        ),
        child: Stack(
          children: [
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CaregiverDetailScreen(
                        caregiver: Map<String, dynamic>.from(caregiver)),
                  ),
                );
              },
              contentPadding: EdgeInsets.only(right: 80, left: 16, bottom: 8),
              leading: Icon(Icons.account_circle, size: 40, color: Colors.teal),
              title: Text(caregiver['name'],
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle:
                  Text('나이: ${caregiver['age']}세\n성별: ${caregiver['gender']}'),
            ),
            Positioned(
              top: 10,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text('매칭률:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                      SizedBox(width: 4),
                      Text('${caregiver['matchingRate']}%',
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(5, (index) {
                        double rating = caregiver['rating'];
                        if (index < rating.floor()) {
                          return Icon(Icons.star,
                              size: 25, color: Colors.amber);
                        } else if (index < rating) {
                          return Icon(Icons.star_half,
                              size: 25, color: Colors.amber);
                        } else {
                          return Icon(Icons.star_border,
                              size: 25, color: Colors.amber);
                        }
                      }),
                      SizedBox(width: 10), // ✅ List.generate 바깥쪽에 위치
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
