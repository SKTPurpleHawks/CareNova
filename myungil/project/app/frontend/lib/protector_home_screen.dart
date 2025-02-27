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
      } else {}
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 모서리 둥글게
          ),
          contentPadding: const EdgeInsets.all(24), // 내부 패딩 추가
          content: Column(
            mainAxisSize: MainAxisSize.min, // 다이얼로그 크기를 내용에 맞게 조정
            children: const [
              CircularProgressIndicator(color: Color(0xFF43C098)),
              SizedBox(height: 20),
              Text(
                "추천 리스트를 생성 중입니다.\n잠시만 기다려 주세요! 🚀",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
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
            'rating': item['star'],
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


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          'assets/images/logo_ver2.png',
          height: 35,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // 스크롤 가능하도록 추가
        child: Column(
          children: [
            const SizedBox(height: 100),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 330,
                    child: _patients.isEmpty
                        ? Center(
                            child: Text(
                              "등록된 환자가 없습니다.\n환자 관리 탭에서 환자를 추가해주세요.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                          )
                        : Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 1),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 5),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                alignment: Alignment.center,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "간병인 검색하기",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 16,
                                      child: Icon(
                                        Icons.search,
                                        size: 30,
                                        color: Colors.black,
                                        weight: 3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                "< 환자 선택 >",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 30),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _patients.length,
                                  itemBuilder: (context, index) {
                                    final patient = _patients[index];
                                    final bool isSelected =
                                        _selectedPatientId == patient['id'];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedPatientId = patient['id'];
                                            _selectedPatientName =
                                                patient['name'];
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isSelected
                                              ? const Color(0xFF43C098)
                                              : Colors.white,
                                          foregroundColor: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            side: BorderSide(
                                              color: isSelected
                                                  ? const Color(0xFF43C098)
                                                  : Colors.grey.shade300,
                                              width: 1.5,
                                            ),
                                          ),
                                          elevation: isSelected ? 4 : 0,
                                        ),
                                        child: Text(
                                          patient['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 10),

                  // 검색 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _selectedPatientId == null ? null : _searchCaregivers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43C098),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                        children: [
                          const Text(
                            "검색하기",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8), // 텍스트와 아이콘 사이 간격 조정
                          const Icon(
                            Icons.search,
                            color: Colors.white, // 아이콘 색상 변경
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
