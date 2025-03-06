import 'package:flutter/material.dart';

class CaregiverPatientLogDetailScreen extends StatelessWidget {
  const CaregiverPatientLogDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String logTitle = ModalRoute.of(context)?.settings.arguments as String? ?? "간병일지";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          logTitle, // ✅ 선택한 간병일지 제목 표시
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "일지 내용",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "여기에 간병일지 내용을 표시합니다. 사용자가 입력한 내용을 불러올 수 있도록 구현합니다.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
