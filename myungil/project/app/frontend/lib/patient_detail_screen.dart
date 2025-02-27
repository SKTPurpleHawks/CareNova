import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'caregiver_patient_log_list.dart';
import 'protector_patient_log_list.dart';
import 'review_edit_screen.dart';
import 'recorder_screen.dart';
import 'patient_record_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patient;
  final String token;
  final bool isCaregiver;
  final bool hasCaregiver;
  final String caregiverName;
  final String caregiverId;
  final String caregiverPhone;
  final String caregiverStartDate;
  final String caregiverEndDate;

  // final String protectorName;
  // final String protectorPhone;
  final String? protectorId;

  const PatientDetailScreen({
    Key? key,
    required this.patient,
    required this.token,
    required this.isCaregiver,
    required this.hasCaregiver,
    required this.caregiverName,
    required this.caregiverId,
    required this.caregiverPhone,
    required this.caregiverStartDate,
    required this.caregiverEndDate,
    this.protectorId,
  }) : super(key: key);

  String _formatDate(String dateString) {
    if (dateString == "정보 없음" || dateString.isEmpty) return "정보 없음";
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return "정보 없음";
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> symptoms = [];
    if (patient['symptoms'] != null) {
      if (patient['symptoms'] is String) {
        symptoms = (patient['symptoms'] as String)
            .split(",")
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      } else if (patient['symptoms'] is List) {
        symptoms = (patient['symptoms'] as List)
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
    }

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
          "환자 정보",
          style: GoogleFonts.notoSansKr(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard([
                    _buildRow("이름", patient['name']),
                    SizedBox(height: 10),
                    _buildRow("성별", patient['sex']),
                    SizedBox(height: 10),
                    _buildRow("키", "${patient['height']} cm"),
                    SizedBox(height: 10),
                    _buildRow("몸무게", "${patient['weight']} kg"),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoCard([
                    _buildRow("간병 지역", patient['region'] ?? "정보 없음"),
                    SizedBox(height: 10),
                    _buildRow("간병 장소", patient['spot'] ?? "정보 없음"),
                    SizedBox(height: 10),
                    _buildChipDetailRow(
                        "증상", symptoms.isNotEmpty ? symptoms : ["정보 없음"]),
                    SizedBox(height: 10),
                    _buildRow("보행 가능 여부", patient['canwalk'] ?? "정보 없음"),
                  ]),
                  const SizedBox(height: 10),
                  if (!isCaregiver && hasCaregiver)
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: _buildInfoCard([
                        _buildRow("간병인 이름", caregiverName),
                        _buildRow("간병인 전화번호", caregiverPhone),
                        _buildRow("간병 시작일", _formatDate(caregiverStartDate)),
                        _buildRow("간병 종료일", _formatDate(caregiverEndDate)),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReviewScreen(
                                    token: token,
                                    caregiverId: caregiverId,
                                    protectorId: protectorId ?? "",
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("간병인 계약 취소",
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ]),
                    ),
                  const SizedBox(height: 20),
                  if (isCaregiver)
                    Padding(
                      padding: const EdgeInsets.all(1),
                      child: _buildInfoCard([
                        _buildRow("보호자 이름", patient['protector_name']),
                        SizedBox(height: 10),
                        _buildRow("보호자 전화번호", patient['protector_phonenumber']),
                        SizedBox(height: 10),
                      ]),
                    ),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          if (!isCaregiver) ...[
            // 보호자 로그인 시: "환자와 대화하기" 버튼 표시
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PatientRecordScreen(patientId: patient['id'] ?? ""), // 수현 ver 음성 AI
                          // RecorderScreen(), // 지영 ver 음성 AI
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black12),
                  ),
                ),
                child: Text(
                  "간병인과 대화하기",
                  style: GoogleFonts.notoSansKr(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => isCaregiver
                        ? CaregiverPatientLogListScreen(
                            patientName: patient['name'],
                            caregiverId: caregiverId,
                            protectorId: protectorId ?? "0",
                            patientId: patient['id'],
                            token: token,
                          )
                        : ProtectorPatientLogListScreen(
                            patientName: patient['name'],
                            patientId: patient['id'],
                            token: token,
                          ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF43C098),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isCaregiver ? "간병일지 작성" : "간병일지 확인",
                style: GoogleFonts.notoSansKr(
                    fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
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
          Text(
            title,
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value ?? "정보 없음",
            style: GoogleFonts.notoSansKr(
                fontSize: 18, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}

Widget _buildChipDetailRow(String title, List<String> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 0),
      Text(
        title,
        style: GoogleFonts.notoSansKr(
            fontWeight: FontWeight.w500, fontSize: 18, color: Colors.black87),
      ),
      SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft, // 🔹 Chip들을 왼쪽 정렬
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 6,
          runSpacing: 6,
          children: items.map((item) {
            return Chip(
              label: Text(
                item,
                style: GoogleFonts.notoSansKr(
                    fontSize: 18, fontWeight: FontWeight.w300),
              ),
              backgroundColor: Colors.grey.shade200,
            );
          }).toList(),
        ),
      ),
    ],
  );
}
