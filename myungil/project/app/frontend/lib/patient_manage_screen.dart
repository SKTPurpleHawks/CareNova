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

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.91.218:8000/patients'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인터넷 연결을 확인해주세요.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오는 중 오류 발생: $e')),
      );
    }
  }

  void _refreshPatients() {
    _fetchPatients();
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientDetailScreen(
                            patient: _patients[index],
                            token: widget.token,
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
