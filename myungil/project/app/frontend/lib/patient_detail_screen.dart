import 'package:flutter/material.dart';
import 'review_edit_screen.dart'; // 리뷰 화면 import

class PatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patient;
  final String token;
  final bool isCaregiver;
  final bool hasCaregiver;
  final String caregiverName;
  final String caregiverId;

  const PatientDetailScreen({
    Key? key,
    required this.patient,
    required this.token,
    required this.isCaregiver,
    required this.hasCaregiver,
    required this.caregiverName,
    required this.caregiverId,
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

            if (!isCaregiver)
              ElevatedButton(
                onPressed: () {},
                child: Text("환자 정보 수정"),
              ),

            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isCaregiver ? "환자와의 대화" : "간병인과의 대화"),
                ],
              ),
            ),

            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isCaregiver ? "간병일지 작성하기" : "간병일지 확인하기"),
                ],
              ),
            ),

            SizedBox(height: 10),

            // 보호자가 간병인과 연결된 경우 "간병인 계약 취소" 버튼 표시
            if (!isCaregiver && hasCaregiver)
              Column(
                children: [
                  Text('연결된 간병인 : $caregiverName',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      print("Caregiver ID 전달됨: $caregiverId");
                      // 리뷰 작성 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewScreen(
                              token: token,
                              caregiverId: caregiverId,
                              protectorId: patient['protector_id'] ?? ""),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("간병인 계약 취소"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
