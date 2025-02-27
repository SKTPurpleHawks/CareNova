import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'caregiver_patient_log_create_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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

  Future<void> _deleteCareLog(int recordId) async {
    final url = Uri.parse('http://172.23.250.30:8000/dailyrecord/$recordId');

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
      } else if (response.statusCode == 404) {
        _showSnackBar("간병일지를 찾을 수 없습니다.");
      } else {
        _showSnackBar("간병일지 삭제 실패: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("서버에 연결할 수 없습니다: $e");
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // 제목 중앙 정렬
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // 여백 추가
          child: Text(
            "${widget.patientName}의 간병일지",
            style: GoogleFonts.notoSansKr(
              fontSize: 22, // 가독성을 위해 살짝 키움
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5, // 자간 추가로 가독성 향상
              color: Colors.black,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(child: _buildCareLogList()), // 리스트가 화면을 채우도록 설정
            _buildCreateLogButton(), // 하단 버튼
          ],
        ),
      ),
    );
  }

  Widget _buildCareLogList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _fetchCareLogs,
      color: const Color(0xFF43C098),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0), // 여백 추가
        child: ListView.builder(
          itemCount: _careLogs.length,
          itemBuilder: (context, index) {
            final log = _careLogs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0), // 리스트 아이템 간 여백 추가
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/caregiver_patient_log_detail',
                    arguments: log, // 선택한 간병일지 데이터 전달
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(100), // 버튼형 디자인
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // 연한 그림자 효과
                        blurRadius: 5,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white, // 아이콘 배경 흰색
                              shape: BoxShape.circle, // 원형 모양
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.edit,
                                size: 24, color: Color(0xFF43C098)),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "간병일지 ${index + 1}", // 제목 유지
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            _formatDate(log['created_at']), // 날짜 유지
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(width: 10),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == "edit") {
                                _editCareLog(log);
                              } else if (value == "delete") {
                                _deleteCareLog(log['id']);
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            elevation: 8,
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                value: "edit",
                                child: Text("수정",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              ),
                              PopupMenuItem(
                                value: "delete",
                                child: Text("삭제",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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

  /// 하단에 간병일지 작성 버튼 배치
  Widget _buildCreateLogButton(
      {double width = double.infinity, double height = 70}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0), // 여백 추가
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: width, 
            height: height, 
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
                backgroundColor: const Color(0xFF43C098),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0, // 기본 elevation 제거 (그림자 중복 방지)
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "간병일지 작성",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 25,
                    weight: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
