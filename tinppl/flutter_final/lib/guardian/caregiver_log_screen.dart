import 'package:flutter/material.dart';

class CaregiverLogScreen extends StatefulWidget {
  const CaregiverLogScreen({super.key});

  @override
  State<CaregiverLogScreen> createState() => _CaregiverLogScreenState();
}

class _CaregiverLogScreenState extends State<CaregiverLogScreen> {
  List<String> logs = ['간병일지 1', '간병일지 2', '간병일지 3']; // 예시 데이터

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.edit),
                      title: Text(logs[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ✅ 하단 네비게이션 바 유지
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
          if (index == 1) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
