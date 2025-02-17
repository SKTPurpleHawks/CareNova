import 'package:flutter/material.dart';
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
  List<dynamic> _patients = []; // 환자 리스트

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

 Future<void> _fetchPatients() async {
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.message, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(patientId: _patients[index]['id']),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.book, color: Colors.green),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CareLogScreen(patientId: _patients[index]['id']),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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


class ChatScreen extends StatelessWidget {
  final String patientId;

  const ChatScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("환자와 대화하기")),
      body: Center(child: Text("환자 ID: $patientId\n여기에 채팅 UI가 들어갈 예정입니다.")),
    );
  }
}


class CareLogScreen extends StatelessWidget {
  final String patientId;

  const CareLogScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("간병일지")),
      body: Center(child: Text("환자 ID: $patientId\n여기에 간병일지가 표시될 예정입니다.")),
    );
  }
}
