import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'caregiver_recommend_list_screen.dart';
import 'patient_manage_screen.dart';
import 'patient_add_screen.dart'; // 파일 존재 여부 확인 후 추가

class ProtectorUserHomeScreen extends StatefulWidget {
  final String token;

  const ProtectorUserHomeScreen({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  _ProtectorUserHomeScreenState createState() =>
      _ProtectorUserHomeScreenState();
}

class _ProtectorUserHomeScreenState extends State<ProtectorUserHomeScreen> {
  int _selectedIndex = 0;
  List<dynamic> _patients = [];
  String? _selectedPatientId;
  String? _selectedPatientName;
  String? _protectorId;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  void _refreshPatients() {
    fetchPatients(); // 기존 환자 목록을 다시 불러오는 역할
  }

  /// 보호자가 등록한 환자 리스트 가져오기
  Future<void> fetchPatients() async {
    final url = Uri.parse('http://172.23.250.30:8000/patients');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> patientsData =
            jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          _patients = patientsData;

          // 첫 번째 환자의 보호자 ID를 가져옴 (보호자가 동일하다는 가정)
          if (patientsData.isNotEmpty &&
              patientsData.first.containsKey('protector_id')) {
            _protectorId = patientsData.first['protector_id'].toString();
          }
        });
      } else {
        _showSnackBar('환자 정보를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      _showSnackBar('서버에 연결할 수 없습니다.');
    }
  }

  /// API 요청을 보내고 검색 결과 화면으로 이동
  Future<void> _searchCaregivers() async {
    if (_selectedPatientId == null) {
      _showSnackBar("환자를 선택하세요.");
      return;
    }

    if (_protectorId == null) {
      _showSnackBar("보호자 정보를 불러올 수 없습니다.");
      return;
    }

    // 로딩 화면 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("추천 리스트를 생성중입니다.\n 잠시만 기다려 주세요!    😎 "),
            ],
          ),
        );
      },
    );

    final url = Uri.parse(
        "http://172.23.250.30:8000/predict/$_protectorId/$_selectedPatientId");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      Navigator.pop(context); // 로딩 다이얼로그 닫기

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> caregivers = data.map((item) {
          return {
            'id': item['caregiver_id'],
            'name': item['name'],
            'age': item['age'],
            'sex': item['sex'],
            'region': item['region'],
            'spot': item['spot'],
            'symptoms': item['symptoms'],
            'canwalk': item['canwalk'],
            'prefersex': item['prefersex'],
            'smoking': item['smoking'],
            'rating': _calculateAverageRating(item),
            'matchingRate': item['matching_rate'].toDouble(),
          };
        }).toList();

        // 검색 결과 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CaregiverRecommendListScreen(
              token: widget.token,
              protectorId: _protectorId!,
              patientId: _selectedPatientId!,
              caregivers: caregivers,
            ),
          ),
        );
      } else {
        _showSnackBar("간병인 추천을 불러오는 데 실패했습니다.");
      }
    } catch (e) {
      Navigator.pop(context); // 로딩 다이얼로그 닫기
      _showSnackBar("서버에 연결할 수 없습니다.");
    }
  }

  double _calculateAverageRating(Map<String, dynamic> caregiver) {
    double total = (caregiver['sincerity'] ?? 0) +
        (caregiver['communication'] ?? 0) +
        (caregiver['hygiene'] ?? 0);
    return total / 3;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("간병인 찾기")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              "검색을 위해 불러올 환자 정보",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: _patients.map((patient) {
                  bool isSelected = _selectedPatientId == patient['id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPatientId = patient['id'];
                        _selectedPatientName = patient['name'];
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green[400] : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          patient['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _searchCaregivers,
              icon: Icon(Icons.search, color: Colors.white),
              label: Text("검색하기",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavigationBar(
            backgroundColor: Colors.white,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });

              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PatientManageScreen(token: widget.token),
                  ),
                );
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.search, color: Color(0xFF43C098)),
                label: '간병인 찾기',
              ),
              NavigationDestination(
                icon: Icon(Icons.edit),
                selectedIcon: Icon(Icons.edit, color: Color(0xFF43C098)),
                label: '내 환자 정보',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
