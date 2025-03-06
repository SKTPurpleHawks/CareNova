import 'package:flutter/material.dart';

class GuardianPatientListScreen extends StatefulWidget {
  const GuardianPatientListScreen({super.key});

  @override
  _GuardianPatientListScreenState createState() =>
      _GuardianPatientListScreenState();
}

class _GuardianPatientListScreenState extends State<GuardianPatientListScreen> {
  int selectedIndex = 1; // ✅ 기본 선택 값 설정
  List<String> patients = ['환자 1', '환자 2'];

  Future<void> _navigateAndAddPatient() async {
    final newPatient =
        await Navigator.pushNamed(context, '/guardian_patient_register');

    if (newPatient != null && newPatient is String) {
      setState(() {
        patients.add(newPatient);
      });
    }
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  return _buildPatientCard(context, patients[index]);
                },
              ),
            ),
            const SizedBox(height: 20),
            Container(
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
                  onPressed: _navigateAndAddPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43C098),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("환자 추가하기",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(width: 8),
                      Icon(Icons.add, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);

          if (index == 0) {
            Navigator.pushReplacementNamed(
                context, '/guardian_patient_selection');
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

  Widget _buildPatientCard(BuildContext context, String patientName) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/guardian_patient_detail',
          arguments: patientName,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.person_outline,
                size: 24,
                color: Color(0xFF43C098),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              patientName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
