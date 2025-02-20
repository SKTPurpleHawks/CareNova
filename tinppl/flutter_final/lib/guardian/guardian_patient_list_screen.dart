import 'package:flutter/material.dart';

class GuardianPatientListScreen extends StatefulWidget {
  const GuardianPatientListScreen({super.key});

  @override
  State<GuardianPatientListScreen> createState() => _GuardianPatientListScreenState();
}

class _GuardianPatientListScreenState extends State<GuardianPatientListScreen> {
  List<String> patients = ['환자 1', '환자 2'];

  // ✅ 환자 추가 화면으로 이동하고 결과 받기
  Future<void> _navigateAndAddPatient() async {
    final newPatient = await Navigator.pushNamed(context, '/guardian_patient_register');

    if (newPatient != null && newPatient is String) {
      setState(() {
        patients.add(newPatient); // ✅ 새 환자 추가
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 환자 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(patients[index]),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/guardian_patient_detail',
                          arguments: patients[index], // ✅ 환자 이름 전달
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _navigateAndAddPatient, // ✅ 새로운 환자 추가 화면으로 이동
              icon: const Icon(Icons.add),
              label: const Text('환자 추가하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // ✅ 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '간병인 찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: '내 환자 정보'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '마이페이지'),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/guardian_patient_selection');
          }
        },
      ),
    );
  }
}
