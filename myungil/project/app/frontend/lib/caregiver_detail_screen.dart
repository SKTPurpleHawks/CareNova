import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CaregiverDetailScreen extends StatefulWidget {
  final Map<String, dynamic> caregiver;
  final String token;
  final String protectorId; // 보호자 ID 추가

  const CaregiverDetailScreen({
    Key? key,
    required this.caregiver,
    required this.token,
    required this.protectorId, // 보호자 ID를 필수 매개변수로 추가
  }) : super(key: key);

  @override
  _CaregiverDetailScreenState createState() => _CaregiverDetailScreenState();
}

class _CaregiverDetailScreenState extends State<CaregiverDetailScreen> {
  List<dynamic> _patients = [];
  String? _selectedPatientId;
  String? _selectedPatientName;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  /// 보호자가 등록한 환자 리스트 가져오기
  Future<void> fetchPatients() async {
    final url = Uri.parse('http://192.168.232.218:8000/patients');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _patients = jsonDecode(utf8.decode(response.bodyBytes));
        });
      } else {
        _showSnackBar('환자 정보를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      _showSnackBar('서버에 연결할 수 없습니다.');
    }
  }

  /// 간병 신청 보내기 (보호자 ID와 환자 ID 포함)
  Future<void> _sendCareRequest(BuildContext context) async {
    if (_selectedPatientId == null) {
      _showSnackBar("환자를 선택하세요.");
      return;
    }

    final url = Uri.parse("http://192.168.232.218:8000/care-request");
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'caregiver_id': widget.caregiver['id'] ?? "", // Null 방지
        'patient_id': _selectedPatientId,
        'protector_id': widget.protectorId, // 🔹 보호자 ID 추가
      }),
    );

    if (response.statusCode == 200) {
      _showSnackBar("간병 신청이 성공적으로 전송되었습니다.");
    } else {
      _showSnackBar("간병 신청에 실패했습니다.");
    }
  }

  /// 환자 선택 다이얼로그 표시
  void _showPatientSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("환자 선택"),
          content: SingleChildScrollView(
            child: Column(
              children: _patients.map((patient) {
                return RadioListTile<String>(
                  title: Text(patient['name'] ?? "이름 없음"), // Null 방지
                  subtitle: Text("나이: ${patient['age']?.toString() ?? '알 수 없음'}세"), // Null 방지
                  value: patient['id'].toString(), // Null 방지
                  groupValue: _selectedPatientId,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedPatientId = value;
                      _selectedPatientName = patient['name'] ?? "이름 없음"; // Null 방지
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Null 값 기본 처리
    final String caregiverName = widget.caregiver['name'] ?? "이름 없음";
    final String caregiverAge = widget.caregiver['age']?.toString() ?? "정보 없음";
    final String caregiverSex = widget.caregiver['sex'] ?? "정보 없음";
    final String caregiverRegion = widget.caregiver['region'] ?? "지역 없음";

    return Scaffold(
      appBar: AppBar(title: Text(caregiverName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("이름: $caregiverName",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("나이: $caregiverAge세"),
            Text("성별: $caregiverSex"),
            Text("근무 가능 지역: $caregiverRegion"),
            const SizedBox(height: 20),

            /// 환자 선택 버튼
            ElevatedButton(
              onPressed: () => _showPatientSelectionDialog(context),
              child: Text(_selectedPatientId == null
                  ? "환자 선택하기"
                  : "선택된 환자: $_selectedPatientName"),
            ),
            const SizedBox(height: 10),

            /// 간병 신청 버튼
            ElevatedButton(
              onPressed: () => _sendCareRequest(context),
              child: const Text("간병 신청 보내기"),
            ),
          ],
        ),
      ),
    );
  }
}
