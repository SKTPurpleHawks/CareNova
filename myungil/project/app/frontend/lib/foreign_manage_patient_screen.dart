import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'patient_detail_screen.dart';
import 'foreign_home_screen.dart';

class ForeignManagePatientScreen extends StatefulWidget {
  final String token;

  const ForeignManagePatientScreen({Key? key, required this.token}) : super(key: key);

  @override
  _ForeignManagePatientScreenState createState() => _ForeignManagePatientScreenState();
}

class _ForeignManagePatientScreenState extends State<ForeignManagePatientScreen> {
  List<dynamic> _patients = [];
  List<dynamic> careRequests = []; 
  int _selectedIndex = 1; 

  @override
  void initState() {
    super.initState();
    fetchPatients();
    fetchCareRequests(); // 간병 요청 데이터 불러오기
  }

  /// 보호자가 요청한 간병 요청 목록 가져오기
  Future<void> fetchCareRequests() async {
    final url = Uri.parse('http://10.0.2.2:8000/care-requests');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> requests = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          careRequests = requests.where((r) => r['status'] == 'pending').toList();
        });
      } else {
        _showSnackBar('간병 요청을 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      _showSnackBar('서버에 연결할 수 없습니다.');
    }
  }

  /// 환자 정보 불러오기
  Future<void> fetchPatients() async {
    final url = Uri.parse('http://10.0.2.2:8000/caregiver/patients');

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

  /// 스낵바 표시
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// 네비게이션 바 클릭 시 화면 전환
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; 

    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ForeignHomeScreen(token: widget.token),
        ),
      );
    }
  }

  /// 간병 요청 알림 팝업
  void _showCareRequestDialog(BuildContext context, Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('간병 요청'),
          content: Text('${request['protector_name'] ?? "알 수 없는 보호자"}님이 간병을 요청했습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                _showSnackBar('요청을 거절했습니다.');
                Navigator.pop(context);
              },
              child: Text('거절'),
            ),
            ElevatedButton(
              onPressed: () {
                _showSnackBar('요청을 수락했습니다.');
                Navigator.pop(context);
              },
              child: Text('수락'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("환자 관리"),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              if (careRequests.isEmpty) {
                _showSnackBar('새로운 간병 요청이 없습니다.');
              } else {
                _showCareRequestDialog(context, careRequests[0]);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/");
            },
          ),
        ],
      ),
      body: _patients.isEmpty
          ? Center(child: Text("연결된 환자가 없습니다."))
          : ListView.builder(
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final patient = _patients[index];

                bool hasCaregiver = patient.containsKey('caregiver_id') &&
                                    patient['caregiver_id'] != null &&
                                    patient['caregiver_id'].toString().isNotEmpty;
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(_patients[index]['name']),
                    subtitle: Text("나이: ${_patients[index]['age']}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientDetailScreen(
                            patient: _patients[index],
                            token: widget.token,
                            isCaregiver: true,
                            hasCaregiver: hasCaregiver,
                            caregiverName: '',
                            caregiverId:'',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '환자 관리'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
