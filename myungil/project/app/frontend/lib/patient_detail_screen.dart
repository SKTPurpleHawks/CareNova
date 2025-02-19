import 'package:flutter/material.dart';

class PatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patient;
  final String token;
  final bool isCaregiver; // ✅ 간병인 여부 확인 변수 추가

  const PatientDetailScreen({
    Key? key,
    required this.patient,
    required this.token,
    required this.isCaregiver, // ✅ 간병인 여부 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("환자 상세 정보"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              patient['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("나이: ${patient['age']}세"),
            Text("성별: ${patient['sex']}"),
            Text("키: ${patient['height']} cm"),
            Text("몸무게: ${patient['weight']} kg"),
            Text("증상: ${patient['symptoms']}"),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),

            // ✅ 보호자만 환자 정보 수정 가능
            if (!isCaregiver)
              ElevatedButton(
                onPressed: () {
                },
                child: Text("환자 정보 수정"),
              ),

            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isCaregiver ? "환자와의 대화" : "간병인과의 대화"), // ✅ 간병인 UI 적용
                  SizedBox(width: 5),
                ],
              ),
            ),

            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isCaregiver ? "간병일지 작성하기" : "간병일지 확인하기"), // ✅ 간병인 UI 적용
                  SizedBox(width: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
