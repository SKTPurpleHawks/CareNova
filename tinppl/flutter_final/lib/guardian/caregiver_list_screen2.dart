import 'package:flutter/material.dart';

class CaregiverListScreen2 extends StatelessWidget {
  final String patientName; // ✅ 선택한 환자 이름 저장

  const CaregiverListScreen2({super.key, required this.patientName}); // ✅ required 추가

  final List<Map<String, dynamic>> caregivers = const [
    {
      "name": "서민석",
      "age": 25,
      "gender": "남성",
      "experience": 1,
      "height": 175,
      "weight": 68,
      "spot": "병원",
      "regions": ["서울", "경기"],
      "symptoms": ["치매", "중풍"],
      "canWalkPatient": "걸을 수 있음",
      "preferSex": "남성",
      "smoking": "비흡연",
      "matchingRate": 99.2,
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
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("간병인 추천 리스트"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: caregivers.length,
        itemBuilder: (context, index) {
          final caregiver = caregivers[index];
          return _buildCaregiverCard(context, caregiver);
        },
      ),
    );
  }

  Widget _buildCaregiverCard(BuildContext context, Map<String, dynamic> caregiver) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름 및 매칭률
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  caregiver["name"],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${caregiver["matchingRate"]}%",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // 나이, 성별, 경력
            Text(
              "나이: ${caregiver["age"]}세  |  성별: ${caregiver["gender"]}  |  경력: ${caregiver["experience"]}년",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 6),

            // 키, 몸무게, 간병 가능 장소
            Text(
              "키: ${caregiver["height"]}cm  |  몸무게: ${caregiver["weight"]}kg  |  간병 가능 장소: ${caregiver["spot"]}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 6),

            // 추가 정보 (필터링 관련)
            Row(
              children: [
                _infoTag("🚶‍♂ 환자 보행: ${caregiver["canWalkPatient"]}"),
                const SizedBox(width: 6),
                _infoTag("🚻 선호 성별: ${caregiver["preferSex"]}"),
                const SizedBox(width: 6),
                _infoTag("🚬 ${caregiver["smoking"]}"),
              ],
            ),

            const SizedBox(height: 10),

            // 상세보기 버튼
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/caregiver_detail', arguments: caregiver);
                },
                child: const Text("상세보기 >", style: TextStyle(fontSize: 14, color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 작은 정보 박스 디자인
  Widget _infoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black)),
    );
  }
}
