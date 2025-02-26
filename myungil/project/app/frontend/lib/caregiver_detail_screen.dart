import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CaregiverDetailScreen extends StatefulWidget {
  final Map<String, dynamic> caregiver;
  final String token;
  final String protectorId; // 보호자 ID 추가
  final String patientId; // 환자 ID 추가

  const CaregiverDetailScreen({
    Key? key,
    required this.caregiver,
    required this.token,
    required this.protectorId,
    required this.patientId,
  }) : super(key: key);

  @override
  _CaregiverDetailScreenState createState() => _CaregiverDetailScreenState();
}

class _CaregiverDetailScreenState extends State<CaregiverDetailScreen> {
  /// ✅ 간병 신청 API 호출
  Future<void> _sendCareRequest(BuildContext context) async {
    final url = Uri.parse("http://172.23.250.30:8000/care-request");
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'caregiver_id': widget.caregiver['id'] ?? "", // Null 방지
        'patient_id': widget.patientId,
        'protector_id': widget.protectorId,
      }),
    );

    if (response.statusCode == 200) {
      _showSnackBar("✅ 간병 신청이 성공적으로 전송되었습니다.");
    } else {
      _showSnackBar("❌ 간병 신청에 실패했습니다.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final caregiver = widget.caregiver;
    final String caregiverName = caregiver['name'] ?? "이름 없음";
    final String caregiverAge = caregiver['age']?.toString() ?? "정보 없음";
    final String caregiverSex = caregiver['sex'] ?? "정보 없음";
    final String caregiverSpot = caregiver['spot'] ?? "정보 없음";

    /// ✅ 문자열로 저장된 데이터를 리스트로 변환
    List<String> regions = (caregiver['region'] is String)
        ? (caregiver['region'] as String)
            .split(",")
            .map((item) => item.trim())
            .toList()
        : (caregiver['region'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [];

    List<String> symptoms = (caregiver['symptoms'] is String)
        ? (caregiver['symptoms'] as String)
            .split(",")
            .map((item) => item.trim())
            .toList()
        : (caregiver['symptoms'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        child: Icon(Icons.person,
                            size: 80, color: Color(0xFF43C098)),
                      ),
                      SizedBox(height: 10),
                      Text(
                        caregiverName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite, color: Colors.teal, size: 20),
                          SizedBox(width: 4),
                          Text(
                            '${(caregiver['matchingRate'] ?? 0).toDouble().toStringAsFixed(2)}%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          double rating = (caregiver['rating'] ?? 0).toDouble();
                          if (index < rating.floor()) {
                            return Icon(Icons.star,
                                size: 30, color: Colors.amber);
                          } else if (index < rating) {
                            return Icon(Icons.star_half,
                                size: 30, color: Colors.amber);
                          } else {
                            return Icon(Icons.star_border,
                                size: 30, color: Colors.amber);
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('나이', '$caregiverAge세'),
                      _buildDetailRow('성별', caregiverSex),
                      _buildDetailRow('근무 가능 장소', caregiverSpot),
                      _buildChipDetailRow('간병 가능 지역', regions),
                      _buildChipDetailRow('간병 가능 질환', symptoms),
                      _buildDetailRow('보행 지원', caregiver['canwalk'] ?? "정보 없음"),
                      _buildDetailRow(
                          '선호 성별', caregiver['preferSex'] ?? "정보 없음"),
                      _buildDetailRow('흡연 여부', caregiver['smoking'] ?? "정보 없음"),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 90),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF43C098),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _sendCareRequest(context),
            child: Text('간병 신청 보내기',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ),
      ),
    );
  }
}

Widget _buildDetailRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

Widget _buildChipDetailRow(String title, List<String> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 8),
      Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
      ),
      SizedBox(height: 8),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: items.map((item) {
          return Chip(
            label: Text(item),
            backgroundColor: Colors.teal.shade50,
          );
        }).toList(),
      ),
    ],
  );
}
