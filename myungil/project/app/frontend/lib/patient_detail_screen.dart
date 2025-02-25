import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'caregiver_patient_log_list.dart';
import 'protector_patient_log_list.dart';
import 'review_edit_screen.dart';

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
                    _buildRow("성별", patient['sex']),
                    _buildRow("키", "${patient['height']} cm"),
                    _buildRow("몸무게", "${patient['weight']} kg"),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoCard([
                    _buildRow("간병 지역", patient['region'] ?? "정보 없음"),
                    _buildRow("간병 가능 장소", patient['spot'] ?? "정보 없음"),
                    _buildRow("증상", patient['symptoms'] ?? "정보 없음"),
                    _buildRow("보행 가능 여부", patient['canwalk'] ?? "정보 없음"),
                  ]),
                  const SizedBox(height: 20),
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
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 대화 기능 추가
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.black12),
                      ),
                    ),
                    child: Text(
                      isCaregiver ? "환자와 대화하기" : "간병인과 대화하기",
                      style: GoogleFonts.notoSansKr(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isCaregiver ? "간병일지 작성" : "간병일지 확인",
                      style: GoogleFonts.notoSansKr(fontSize: 16),
                    ),
                  ),
                ),
              ],
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
        borderRadius: BorderRadius.circular(10),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value ?? "정보 없음",
            style: GoogleFonts.notoSansKr(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
