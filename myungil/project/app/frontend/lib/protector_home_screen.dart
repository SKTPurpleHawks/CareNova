import 'package:flutter/material.dart';
import 'patient_manage_screen.dart';

class ProtectorUserHomeScreen extends StatefulWidget {
  final String token;

  const ProtectorUserHomeScreen({Key? key, required this.token}) : super(key: key);

  @override
  _ProtectorUserHomeScreenState createState() => _ProtectorUserHomeScreenState();
}

class _ProtectorUserHomeScreenState extends State<ProtectorUserHomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;
  late final List<String> _titles;

  @override
  void initState() {
    super.initState();
    _screens = [
      Center(child: Text("간병인 찾기 화면 구현 예정")),
      PatientManageScreen(token: widget.token), 
      Center(child: Text("마이 페이지 화면 구현 예정")),
    ];

    _titles = ["간병인 찾기", "환자 관리", "마이 페이지"]; 
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
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
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '마이 페이지'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
