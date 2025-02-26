import 'package:flutter/material.dart';
import 'caregiver_detail_screen.dart';

class CaregiverRecommendListScreen extends StatelessWidget {
  final String protectorId;
  final String patientId;
  final String token;
  final List<Map<String, dynamic>> caregivers; // 보호자 화면에서 전달받는 추천 리스트

  const CaregiverRecommendListScreen({
    Key? key,
    required this.protectorId,
    required this.patientId,
    required this.token,
    required this.caregivers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Text(
                '*조건에 맞춘 간병인 추천 순위 리스트입니다*',
                style: const TextStyle(
                    color: Color.fromARGB(195, 0, 0, 0), fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: caregivers.isEmpty
                  ? const Center(child: Text("추천된 간병인이 없습니다."))
                  : ListView.builder(
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
        selectedIndex: 0,
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

  /// ✅ 간병인 카드 UI
  Widget _buildCaregiverCard(BuildContext context, Map caregiver) {
    // ✅ Null 값 처리
    final String name = caregiver['name'] ?? "이름 없음";
    final int age = (caregiver['age'] ?? 0).toInt();
    final String sex = caregiver['sex'] ?? "정보 없음";
    final double matchingRate = (caregiver['matchingRate'] ?? 0.0).toDouble();
    final double rating = (caregiver['rating'] ?? 0.0).toDouble();

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
                      caregiver: Map<String, dynamic>.from(caregiver),
                      token: token,
                      protectorId: protectorId,
                    ),
                  ),
                );
              },
              contentPadding:
                  const EdgeInsets.only(right: 80, left: 16, bottom: 8),
              leading: const Icon(Icons.account_circle,
                  size: 40, color: Colors.teal),
              title: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('나이: ${age}세\n성별: ${sex}'),
            ),
            Positioned(
              top: 10,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Text('매칭률:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                      const SizedBox(width: 4),
                      Text('${matchingRate.toStringAsFixed(1)}%',
                          style: const TextStyle(
                              fontSize: 22,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(5, (index) {
                        if (index < rating.floor()) {
                          return const Icon(Icons.star,
                              size: 25, color: Colors.amber);
                        } else if (index < rating) {
                          return const Icon(Icons.star_half,
                              size: 25, color: Colors.amber);
                        } else {
                          return const Icon(Icons.star_border,
                              size: 25, color: Colors.amber);
                        }
                      }),
                      const SizedBox(width: 10),
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
