import 'package:flutter/material.dart';
import 'caregiver_patient_log_list.dart';
import 'protector_patient_log_list.dart'; // ✅ 보호자 간병일지 리스트 화면 import
import 'review_edit_screen.dart'; // 리뷰 화면 import

class PatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patient;
  final String token;
  final bool isCaregiver;
  final bool hasCaregiver;
  final String caregiverName;
  final String caregiverId;
  final String? protectorId;

  const PatientDetailScreen({
    Key? key,
    required this.patient,
    required this.token,
    required this.isCaregiver,
    required this.hasCaregiver,
    required this.caregiverName,
    required this.caregiverId,
    this.protectorId,
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

            // ✅ 보호자 또는 간병인이 간병일지 확인/작성 가능
            if (isCaregiver)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CaregiverPatientLogListScreen(
                        patientName: patient['name'],
                        caregiverId: caregiverId,
                        protectorId: protectorId ?? "0",
                        patientId: patient['id'],
                        token: token,
                      ),
                    ),
                  );
                },
                child: Text("간병일지 작성하기"),
              )
            else
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProtectorPatientLogListScreen(
                        patientName: patient['name'],
                        patientId: patient['id'],
                        token: token,
                      ),
                    ),
                  );
                },
                child: Text("간병일지 확인하기"), // ✅ 보호자는 간병일지 조회만 가능
              ),

            SizedBox(height: 10),

            // ✅ 보호자가 간병인과 연결된 경우 "간병인 계약 취소" 버튼 표시
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
                              protectorId: protectorId ?? ""),
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
