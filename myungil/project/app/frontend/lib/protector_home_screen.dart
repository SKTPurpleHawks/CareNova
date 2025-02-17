import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'patient_manage_screen.dart';

class ProtectorUserHomeScreen extends StatefulWidget {
  final String token;

  const ProtectorUserHomeScreen({Key? key, required this.token}) : super(key: key);

  @override
  _ProtectorUserHomeScreenState createState() => _ProtectorUserHomeScreenState();
}

class _ProtectorUserHomeScreenState extends State<ProtectorUserHomeScreen> {
  int _selectedIndex = 0;
  List<dynamic> _caregivers = [];

  @override
  void initState() {
    super.initState();
    _fetchCaregivers();
  }

  Future<void> _fetchCaregivers() async {
    final response = await http.get(
      Uri.parse('http://172.23.250.30:8000/caregivers'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _caregivers = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('간병인 목록을 불러오는 데 실패했습니다.')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _screens = [
      _buildCaregiverList(),
      PatientManageScreen(token: widget.token), 
    ];

    List<String> _titles = ["간병인 찾기", "환자 관리"];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              _showSnackBar('알림 기능은 준비 중입니다.');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 로그아웃 → 로그인 화면으로 이동
              Navigator.pushReplacementNamed(context, "/");
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '간병인 찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '환자 관리'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCaregiverList() {
    return _caregivers.isEmpty
        ? Center(child: Text("등록된 간병인이 없습니다."))
        : ListView.builder(
            itemCount: _caregivers.length,
            itemBuilder: (context, index) {
              final caregiver = _caregivers[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(caregiver['name'][0], style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(caregiver['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("나이: ${caregiver['age']}세"),
                      // Text("경력: ${caregiver['experience']}년"),
                      Text("근무 지역: ${caregiver['region']}"),
                      // Text("급여: ${caregiver['salary']}만원"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      // Text(caregiver['rating'].toString()),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CaregiverDetailScreen(caregiver: caregiver)),
                    );
                  },
                ),
              );
            },
          );
  }
}

/// 🔹 간병인 상세 정보 화면
class CaregiverDetailScreen extends StatelessWidget {
  final Map<String, dynamic> caregiver;

  const CaregiverDetailScreen({Key? key, required this.caregiver}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(caregiver['name'])),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("이름: ${caregiver['name']}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("나이: ${caregiver['age']}세"),
            Text("성별: ${caregiver['sex']}"),
            // Text("경력: ${caregiver['experience']}년"),
            Text("근무 가능 지역: ${caregiver['region']}"),
            // Text("급여: ${caregiver['salary']}만원"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text("상세 정보 보기"),
            ),
          ],
        ),
      ),
    );
  }
}
