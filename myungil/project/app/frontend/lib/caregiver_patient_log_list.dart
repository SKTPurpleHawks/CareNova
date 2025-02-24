import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'caregiver_patient_log_create_screen.dart';

class CaregiverPatientLogListScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String token;
  final String caregiverId;
  final String protectorId;

  const CaregiverPatientLogListScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
    required this.token,
    required this.caregiverId,
    required this.protectorId,
  }) : super(key: key);

  @override
  _CaregiverPatientLogListScreenState createState() =>
      _CaregiverPatientLogListScreenState();
}

class _CaregiverPatientLogListScreenState
    extends State<CaregiverPatientLogListScreen> {
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
        Uri.parse('http://192.168.232.218:8000/dailyrecord/${widget.patientId}');

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

  /// 간병일지 삭제 함수 (삭제 후 UI 즉시 반영)
  Future<void> _deleteCareLog(int recordId) async {
    final url = Uri.parse('http://192.168.232.218:8000/dailyrecord/$recordId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _careLogs.removeWhere((item) => item['id'] == recordId);
        });

        _showSnackBar("간병일지가 삭제되었습니다.");
      } else {
        _showSnackBar("간병일지 삭제 실패");
      }
    } catch (e) {
      _showSnackBar("서버에 연결할 수 없습니다.");
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
      appBar: AppBar(title: Text("${widget.patientName}의 간병일지")),
      body: Column(
        children: [
          Expanded(child: _buildCareLogList()), // 리스트가 화면을 채우도록 설정
          _buildCreateLogButton(), // 하단 버튼
        ],
      ),
    );
  }

  /// ✅ 간병일지 리스트 UI
  Widget _buildCareLogList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _careLogs.length,
        itemBuilder: (context, index) {
          final log = _careLogs[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
            child: ListTile(
              title: Text("간병일지 ${index + 1}"),
              subtitle: Text(_formatDate(log['created_at'])), // 날짜 포맷 변경
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == "edit") {
                    _editCareLog(log);
                  } else if (value == "delete") {
                    _deleteCareLog(log['id']);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(value: "edit", child: Text("수정")),
                  PopupMenuItem(value: "delete", child: Text("삭제")),
                ],
              ),
              
            ),
          );
        },
      ),
    );
  }

  /// 날짜 포맷 변경 (연, 월, 일만 표시)
  String _formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String month =
        dateTime.month.toString().padLeft(2, '0'); // 한 자리 수일 경우 앞에 0 추가
    String day = dateTime.day.toString().padLeft(2, '0'); // 한 자리 수일 경우 앞에 0 추가
    return "${dateTime.year}-$month-$day";
  }

  /// 간병일지 수정 기능 (기존 데이터 전달)
  void _editCareLog(Map<String, dynamic> log) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaregiverPatientLogCreateScreen(
          patientName: widget.patientName,
          caregiverId: widget.caregiverId,
          protectorId: widget.protectorId,
          patientId: widget.patientId,
          token: widget.token,
          initialLogData: log, // 기존 데이터 전달
        ),
      ),
    ).then((_) => _fetchCareLogs()); // 수정 후 목록 새로고침
  }

  /// ✅ 하단에 간병일지 작성 버튼 배치
  Widget _buildCreateLogButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0), // 여백 추가
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CaregiverPatientLogCreateScreen(
                  patientName: widget.patientName,
                  caregiverId: widget.caregiverId,
                  protectorId: widget.protectorId,
                  patientId: widget.patientId,
                  token: widget.token,
                ),
              ),
            ).then((_) => _fetchCareLogs()); // 새 기록 후 목록 새로고침
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("간병일지 작성", style: TextStyle(fontSize: 16)),
              SizedBox(width: 10),
              Icon(Icons.add),
            ],
          ),
        ),
      ),
    );
  }
}
