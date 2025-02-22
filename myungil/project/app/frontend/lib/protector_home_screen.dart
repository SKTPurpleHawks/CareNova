import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'patient_manage_screen.dart';

class ProtectorUserHomeScreen extends StatefulWidget {
  final String token;

  const ProtectorUserHomeScreen({Key? key, required this.token})
      : super(key: key);

  @override
  _ProtectorUserHomeScreenState createState() =>
      _ProtectorUserHomeScreenState();
}

class _ProtectorUserHomeScreenState extends State<ProtectorUserHomeScreen> {
  int _selectedIndex = 0;
  List<dynamic> _caregivers = [];

  @override
  void initState() {
    super.initState();
    _fetchCaregivers();
  }

  Future<void> _fetchCaregivers() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.10:8000/caregivers'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _caregivers = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('간병인 목록을 불러오는 데 실패했습니다.')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _screens = [
      _buildCaregiverList(),
      PatientManageScreen(token: widget.token),
    ];

    List<String> _titles = ["간병인 찾기", "환자 관리"];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              _showSnackBar('알림 기능은 준비 중입니다.');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 로그아웃 → 로그인 화면으로 이동
              Navigator.pushReplacementNamed(context, "/");
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '간병인 찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '환자 관리'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCaregiverList() {
    return _caregivers.isEmpty
        ? Center(child: Text("등록된 간병인이 없습니다."))
        : ListView.builder(
            itemCount: _caregivers.length,
            itemBuilder: (context, index) {
              final caregiver = _caregivers[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(caregiver['name'][0],
                        style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(caregiver['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("나이: ${caregiver['age']}세"),
                      // Text("경력: ${caregiver['experience']}년"),
                      Text("근무 지역: ${caregiver['region']}"),
                      // Text("급여: ${caregiver['salary']}만원"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      // Text(caregiver['rating'].toString()),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CaregiverDetailScreen(
                                caregiver: caregiver,
                                token: widget.token,
                              )),
                    );
                  },
                ),
              );
            },
          );
  }
}

class CaregiverDetailScreen extends StatefulWidget {
  final Map<String, dynamic> caregiver;
  final String token; // 로그인 토큰 추가

  const CaregiverDetailScreen({Key? key, required this.caregiver, required this.token})
      : super(key: key);

  @override
  _CaregiverDetailScreenState createState() => _CaregiverDetailScreenState();
}

class _CaregiverDetailScreenState extends State<CaregiverDetailScreen> {
  List<dynamic> _patients = [];
  String? _selectedPatientId; // 선택된 환자의 ID
  String? _selectedPatientName; // 선택된 환자의 이름

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  /// 보호자가 등록한 환자 리스트 가져오기
  Future<void> fetchPatients() async {
    final url = Uri.parse('http://192.168.0.10:8000/patients');

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

  /// 간병 신청 보내기 (환자 선택 후)
  Future<void> _sendCareRequest(BuildContext context) async {
    if (_selectedPatientId == null) {
      _showSnackBar("환자를 선택하세요.");
      return;
    }

    final url = Uri.parse("http://192.168.0.10:8000/care-request");
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'caregiver_id': widget.caregiver['id'],
        'patient_id': _selectedPatientId, // 선택한 환자의 ID 포함
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
          title: Text("환자 선택"),
          content: SingleChildScrollView(
            child: Column(
              children: _patients.map((patient) {
                return RadioListTile<String>(
                  title: Text(patient['name']),
                  subtitle: Text("나이: ${patient['age']}세"),
                  value: patient['id'],
                  groupValue: _selectedPatientId,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedPatientId = value;
                      _selectedPatientName = patient['name']; // 환자 이름 저장
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.caregiver['name'])),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("이름: ${widget.caregiver['name']}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("나이: ${widget.caregiver['age']}세"),
            Text("성별: ${widget.caregiver['sex']}"),
            Text("근무 가능 지역: ${widget.caregiver['region']}"),
            SizedBox(height: 20),

            /// 환자 선택 버튼
            ElevatedButton(
              onPressed: () => _showPatientSelectionDialog(context),
              child: Text(_selectedPatientId == null
                  ? "환자 선택하기"
                  : "선택된 환자: $_selectedPatientName"), // 환자 이름 표시
            ),
            SizedBox(height: 10),

            /// 간병 신청 버튼
            ElevatedButton(
              onPressed: () => _sendCareRequest(context),
              child: Text("간병 신청 보내기"),
            ),
          ],
        ),
      ),
    );
  }
}