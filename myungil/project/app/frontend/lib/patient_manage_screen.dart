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
        // _showSnackBar('간병인과 연결된 환자 정보를 불러오는 데 실패했습니다.');
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
        centerTitle: true,
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // 내부 스크롤 비활성화
                itemCount: _patients.length,
                itemBuilder: (context, index) {
                  final patient = _patients[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        final patientId = _patients[index]['id'];

                        bool hasCaregiver = _caregiverpatients.any(
                            (caregiverPatient) =>
                                caregiverPatient['id'] == patientId &&
                                caregiverPatient.containsKey('caregiver_id') &&
                                caregiverPatient['caregiver_id'] != null &&
                                caregiverPatient['caregiver_id']
                                    .toString()
                                    .isNotEmpty);

                        String caregiverId = (_caregiverpatients.firstWhere(
                                    (caregiverPatient) =>
                                        caregiverPatient['id'] == patientId &&
                                        caregiverPatient
                                            .containsKey('caregiver_id'),
                                    orElse: () => {
                                          'caregiver_id': null
                                        })['caregiver_id'] ??
                                "")
                            .toString();

                        String caregiverName = (_caregiverpatients.firstWhere(
                                    (caregiverPatient) =>
                                        caregiverPatient['id'] == patientId &&
                                        caregiverPatient
                                            .containsKey('caregiver_name'),
                                    orElse: () => {
                                          'caregiver_name': null
                                        })['caregiver_name'] ??
                                "정보 없음")
                            .toString();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientDetailScreen(
                              patient: _patients[index],
                              token: widget.token,
                              isCaregiver: false,
                              hasCaregiver: hasCaregiver,
                              caregiverName: caregiverName,
                              caregiverId: caregiverId,
                              caregiverPhone: (_caregiverpatients.firstWhere(
                                          (caregiverPatient) =>
                                              caregiverPatient['id'] ==
                                                  patientId &&
                                              caregiverPatient.containsKey(
                                                  'caregiver_phonenumber'),
                                          orElse: () => {
                                                'caregiver_phonenumber': "정보 없음"
                                              })['caregiver_phonenumber'] ??
                                      "정보 없음")
                                  .toString(),
                              caregiverStartDate:
                                  (_caregiverpatients.firstWhere(
                                              (caregiverPatient) =>
                                                  caregiverPatient['id'] ==
                                                      patientId &&
                                                  caregiverPatient.containsKey(
                                                      'caregiver_startdate'),
                                              orElse: () => {
                                                    'caregiver_startdate':
                                                        "정보 없음"
                                                  })['caregiver_startdate'] ??
                                          "정보 없음")
                                      .toString(),
                              caregiverEndDate: (_caregiverpatients.firstWhere(
                                          (caregiverPatient) =>
                                              caregiverPatient['id'] ==
                                                  patientId &&
                                              caregiverPatient.containsKey(
                                                  'caregiver_enddate'),
                                          orElse: () => {
                                                'caregiver_enddate': "정보 없음"
                                              })['caregiver_enddate'] ??
                                      "정보 없음")
                                  .toString(),
                              protectorId:
                                  (_patients[index]['protector_id'] ?? "")
                                      .toString(),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
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
                                      builder: (context) =>
                                          PatientEditProfileScreen(
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
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
              const SizedBox(height: 5), // 버튼과 리스트 사이 여백
              SizedBox(
                width: double.infinity,
                height: 70,
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
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

              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProtectorUserHomeScreen(token: widget.token),
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
