import 'package:flutter/material.dart';
import 'patient_detail_screen.dart';
import 'patient_edit_profile_screen.dart'; // 환자 정보 수정 화면 추가
import 'protector_home_screen.dart'; // 환자 정보 수정 화면 추가

import 'patient_add_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class PatientManageScreen extends StatefulWidget {
  final String token;

  const PatientManageScreen({Key? key, required this.token}) : super(key: key);

  @override
  _PatientManageScreenState createState() => _PatientManageScreenState();
}

class _PatientManageScreenState extends State<PatientManageScreen> {
  List<dynamic> _patients = [];
  List<dynamic> _caregiverpatients = [];
  int _selectedIndex = 1; // 현재 선택된 네비게이션 바 인덱스

  @override
  void initState() {
    super.initState();
    _fetchProtectorPatients();
    _fetchCaregiverPatients();
  }

  Future<void> _fetchCaregiverPatients() async {
    final url = Uri.parse('http://172.23.250.30:8000/caregiver/patients');
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
          _caregiverpatients = jsonDecode(utf8.decode(response.bodyBytes));
        });
      } else {
        _showSnackBar('간병인과 연결된 환자 정보를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      _showSnackBar('서버에 연결할 수 없습니다.');
    }
  }

  Future<void> _fetchProtectorPatients() async {
    try {
      final response = await http.get(
        Uri.parse('http://172.23.250.30:8000/patients'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _patients = jsonDecode(utf8.decode(response.bodyBytes));
        });
      }
    } on SocketException {
      _showSnackBar('인터넷 연결을 확인해주세요.');
    } catch (e) {
      _showSnackBar('데이터를 불러오는 중 오류 발생: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _refreshPatients() {
    _fetchProtectorPatients();
  }

  void _onNavItemTapped(int index) {
    if (_selectedIndex == index) return; // 현재 선택된 페이지라면 다시 로드하지 않음
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, "/find_caregiver");
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, "/patient_manage");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '환자 관리',
          style: TextStyle(
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          itemCount: _patients.length,
          itemBuilder: (context, index) {
            final patient = _patients[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: () {
                  // 보호자가 맞는지 확인
                  bool isProtector =
                      patient['protector_id'].toString() == widget.token;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientDetailScreen(
                        patient: patient,
                        token: widget.token,
                        isCaregiver: false, // 보호자로 들어가야 하므로 false 유지
                        hasCaregiver:
                            patient['caregiver_id'] != null, // 간병인이 있는지 여부 확인
                        caregiverName: patient['caregiver_name'] ?? "정보 없음",
                        caregiverId: patient['caregiver_id']?.toString() ?? "",
                        caregiverPhone: patient['caregiver_phone'] ?? "정보 없음",
                        caregiverStartDate:
                            patient['caregiver_start_date'] ?? "정보 없음",
                        caregiverEndDate:
                            patient['caregiver_end_date'] ?? "정보 없음",
                        protectorId:
                            isProtector ? widget.token : null, // 보호자 ID를 전달
                      ),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(5),
                            child: const Icon(Icons.person,
                                size: 40, color: Color(0xFF43C098)),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            patient['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == "edit") {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientEditProfileScreen(
                                  token: widget.token,
                                  patientData: patient,
                                ),
                              ),
                            );

                            if (result == true) {
                              _refreshPatients();
                            }
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
                            child: Text("환자 정보 수정하기",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43C098),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PatientAddScreen(token: widget.token),
                    ),
                  );
                  if (result == true) {
                    _refreshPatients();
                  }
                },
                child: const Text(
                  "환자 추가하기 +",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          NavigationBar(
            backgroundColor: Colors.white,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });

              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProtectorUserHomeScreen(token: widget.token),
                  ),
                );
              } else if (index == 1) {
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
