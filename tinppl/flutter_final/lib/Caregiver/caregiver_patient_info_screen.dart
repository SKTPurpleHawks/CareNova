import 'package:flutter/material.dart';

class CaregiverPatientInfoScreen extends StatelessWidget {
  final Map<String, dynamic> patientData;

  const CaregiverPatientInfoScreen({super.key, required this.patientData});

  @override
  Widget build(BuildContext context) {
    List<String> symptoms = patientData['symptoms'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "환자 정보",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard([
              _buildRow("이름", patientData['name']),
              _buildRow("성별", patientData['gender']),
              _buildRow("키", "${patientData['height']} cm"),
              _buildRow("몸무게", "${patientData['weight']} kg"),
            ]),

            const SizedBox(height: 20),

            _buildInfoCard([
              _buildRow("간병 지역", patientData['care_region']),
              _buildRow("간병 가능 장소", patientData['care_place']),
            ]),

            const SizedBox(height: 20),

            const Text(
              "진단명",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                patientData['diagnosis'] ?? "정보 없음",
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "증상",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            symptoms.isNotEmpty
                ? Column(
              children: symptoms.map((symptom) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.teal),
                      const SizedBox(width: 10),
                      Expanded(child: Text(symptom, style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                );
              }).toList(),
            )
                : const Text("등록된 증상이 없습니다.", style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value ?? "정보 없음", style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
