import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'caregiver_patient_log_create_screen.dart'; // 간병일지 상세 보기 화면 import

class ProtectorPatientLogListScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String token;

  const ProtectorPatientLogListScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
    required this.token,
  }) : super(key: key);

  @override
  _ProtectorPatientLogListScreenState createState() =>
      _ProtectorPatientLogListScreenState();
}

class _ProtectorPatientLogListScreenState
    extends State<ProtectorPatientLogListScreen> {
  List<dynamic> _careLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCareLogs();
  }

  /// 간병일지 리스트를 서버에서 가져오는 함수
  Future<void> _fetchCareLogs() async {
    final url =
        Uri.parse('http://172.23.250.30:8000/dailyrecord/${widget.patientId}');

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
          _careLogs = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      } else {
        _showSnackBar('간병일지 데이터를 불러오는 데 실패했습니다.');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar('서버에 연결할 수 없습니다.');
      setState(() => _isLoading = false);
    }
  }

  /// 스낵바 표시 함수
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true, // 제목을 가운데 정렬
        title: Text("${widget.patientName}의 간병일지"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildCareLogList(),
    );
  }

  /// 간병일지 리스트 UI (보호자는 수정 및 삭제 버튼 없음)
  Widget _buildCareLogList() {
    if (_careLogs.isEmpty) {
      return Center(
          child: Text("등록된 간병일지가 없습니다.", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _careLogs.length,
      itemBuilder: (context, index) {
        final log = _careLogs[index];

        return Card(
          color: Color(0xFF43C098),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.4),
          child: InkWell(
            borderRadius: BorderRadius.circular(100), // ✅ 터치 효과가 카드 모양과 일치
            onTap: () {
              _viewCareLog(log); // ✅ 간병일지 상세 보기
            },
            child: SizedBox(
              // ✅ 크기 조정 가능
              width: double.infinity, // ✅ 가로 전체 확장 (부모 컨테이너 기준)
              height: 80, // ✅ 높이 조정 가능
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ 아이템 배치
                  children: [
                    Text(
                      "간병일지 ${index + 1}", // ✅ 제목 유지
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _formatDate(log['created_at']),
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 날짜 포맷 변경 (연, 월, 일만 표시)
  String _formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String month = dateTime.month.toString().padLeft(2, '0');
    String day = dateTime.day.toString().padLeft(2, '0');
    return "${dateTime.year}-$month-$day";
  }

  /// 간병일지 상세 보기
  void _viewCareLog(Map<String, dynamic> log) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaregiverPatientLogCreateScreen(
          patientName: widget.patientName,
          caregiverId: log['caregiver_id'],
          protectorId: log['protector_id'],
          patientId: widget.patientId,
          token: widget.token,
          initialLogData: log, // 기존 데이터 전달
          isReadOnly: true, // 읽기 전용 모드 활성화
        ),
      ),
    );
  }
}
