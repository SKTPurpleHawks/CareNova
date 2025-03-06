import 'package:flutter/material.dart';

class CaregiverLogScreen extends StatefulWidget {
  const CaregiverLogScreen({super.key});

  @override
  State<CaregiverLogScreen> createState() => _CaregiverLogScreenState();
}

class _CaregiverLogScreenState extends State<CaregiverLogScreen> {
  int selectedIndex = 1; // ✅ 기본 선택 값 설정

  final List<Map<String, String>> logs = [
    {"title": "간병일지 1", "date": "2025.02.19"},
    {"title": "간병일지 2", "date": "2025.02.20"},
    {"title": "간병일지 3", "date": "2025.02.21"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('환자 1'),
        centerTitle: true,
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
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.edit),
                      title: Text(log["title"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(log["date"]!),
                      onTap: () {
                        Navigator.pushNamed(context, '/caregiver_log_detail',
                            arguments: log);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
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
}
