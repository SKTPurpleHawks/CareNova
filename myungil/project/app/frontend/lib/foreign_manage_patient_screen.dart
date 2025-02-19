import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'patient_detail_screen.dart';

class ForeignManagePatientScreen extends StatefulWidget {
  final String token;

  const ForeignManagePatientScreen({Key? key, required this.token}) : super(key: key);

  @override
  _ForeignManagePatientScreenState createState() => _ForeignManagePatientScreenState();
}

class _ForeignManagePatientScreenState extends State<ForeignManagePatientScreen> {
  List<dynamic> _patients = [];

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    final url = Uri.parse('http://192.168.91.218:8000/caregiver/patients');

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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("환자 관리")),
      body: _patients.isEmpty
          ? Center(child: Text("연결된 환자가 없습니다."))
          : ListView.builder(
              itemCount: _patients.length,
              itemBuilder: (context, index) {
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
                            isCaregiver: true
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
