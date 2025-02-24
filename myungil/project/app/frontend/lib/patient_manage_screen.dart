import 'package:flutter/material.dart';
import 'patient_detail_screen.dart';
import 'patient_add_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class PatientManageScreen extends StatefulWidget {
  final String token; // 보호자 로그인 정보

  const PatientManageScreen({Key? key, required this.token}) : super(key: key);

  @override
  _PatientManageScreenState createState() => _PatientManageScreenState();
}

class _PatientManageScreenState extends State<PatientManageScreen> {
  List<dynamic> _patients = []; // 환자 리스트
  List<dynamic> _caregiverpatients = []; // 환자 리스트

  @override
  void initState() {
    super.initState();
    _fetchProtectorPatients();
    _fetchCaregiverPatients();
  }

  Future<void> _fetchCaregiverPatients() async {
    final url = Uri.parse('http://192.168.232.218:8000/caregiver/patients');

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
        Uri.parse('http://192.168.232.218:8000/patients'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _patients.isEmpty
          ? Center(child: Text("등록된 환자가 없습니다."))
          : ListView.builder(
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(_patients[index]['name']),
                    subtitle: Text("나이: ${_patients[index]['age']}세"),
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
                                  orElse: () =>
                                      {'caregiver_id': null})['caregiver_id'] ??
                              "")
                          .toString(); // Null 방지 : String으로 받는데 null값이 들어오면 처리를 못함

                      String caregiverName = (_caregiverpatients.firstWhere(
                                  (caregiverPatient) =>
                                      caregiverPatient['id'] == patientId &&
                                      caregiverPatient
                                          .containsKey('caregiver_name'),
                                  orElse: () => {
                                        'caregiver_name': null
                                      })['caregiver_name'] ??
                              "정보 없음")
                          .toString(); // Null 방지 : String으로 받는데 null값이 들어오면 처리를 못함

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
                            protectorId: (_patients[index]['protector_id'] ?? "").toString(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientAddScreen(token: widget.token),
            ),
          );
          if (result == true) {
            _refreshPatients();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
