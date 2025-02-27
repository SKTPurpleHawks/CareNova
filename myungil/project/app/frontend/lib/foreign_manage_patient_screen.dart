import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'patient_detail_screen.dart';
import 'foreign_home_screen.dart';

class ForeignManagePatientScreen extends StatefulWidget {
  final String token;

  const ForeignManagePatientScreen({Key? key, required this.token})
      : super(key: key);

  @override
  _ForeignManagePatientScreenState createState() =>
      _ForeignManagePatientScreenState();
}

class _ForeignManagePatientScreenState
    extends State<ForeignManagePatientScreen> {
  List<dynamic> _patients = [];
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  /// 환자 정보 불러오기
  Future<void> fetchPatients() async {
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🔹 배경색 추가
      appBar: AppBar(
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: _patients.isEmpty
            ? Center(child: Text("연결된 환자가 없습니다."))
            : ListView.builder(
                itemCount: _patients.length,
                itemBuilder: (context, index) {
                  final patient = _patients[index];
                  bool hasCaregiver = patient.containsKey('caregiver_id') &&
                      patient['caregiver_id'] != null &&
                      patient['caregiver_id'].toString().isNotEmpty;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _buildPatientCard(
                      context,
                      patient['name'],
                      patient['age'].toString(),
                      patient,
                      hasCaregiver,
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF43C098)),
            label: "프로필",
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            selectedIcon: Icon(Icons.list_alt, color: Color(0xFF43C098)),
            label: "환자 관리",
          ),
        ],
      ),
    );
  }

  /// 🔹 새로운 UI 적용된 환자 카드
  Widget _buildPatientCard(
    BuildContext context,
    String patientName,
    String age,
    dynamic patientData,
    bool hasCaregiver,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientDetailScreen(
              patient: patientData,
              token: widget.token,
              isCaregiver: true,
              hasCaregiver: hasCaregiver,
              caregiverName: '',
              caregiverId: (patientData['caregiver_id'] ?? "").toString(),
              caregiverPhone: '',
              caregiverStartDate: '',
              caregiverEndDate: '',
              protectorId: (patientData['protector_id'] ?? "").toString(),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.person,
                size: 45,
                color: Color(0xFF43C098),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
