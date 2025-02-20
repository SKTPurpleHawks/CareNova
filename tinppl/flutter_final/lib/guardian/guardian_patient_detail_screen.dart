import 'package:flutter/material.dart';

class GuardianPatientDetailScreen extends StatefulWidget {
  const GuardianPatientDetailScreen({super.key});

  @override
  State<GuardianPatientDetailScreen> createState() => _GuardianPatientDetailScreenState();
}

class _GuardianPatientDetailScreenState extends State<GuardianPatientDetailScreen> {
  late TextEditingController _nameController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(); // ✅ 초기화만 먼저
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String patientName = ModalRoute.of(context)?.settings.arguments as String? ?? '환자'; // ✅ 여기서 호출
    _nameController.text = patientName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });

    if (!isEditing) {
      Navigator.pop(context, _nameController.text); // ✅ 수정된 이름을 이전 화면으로 전달
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _nameController.text), // ✅ 수정된 이름 반환
        ),
        title: isEditing
            ? TextField(
          controller: _nameController,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(border: InputBorder.none),
          onSubmitted: (_) => _toggleEditing(),
        )
            : GestureDetector(
          onTap: _toggleEditing,
          child: Text(
            _nameController.text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            _buildButton(context, '간병인과의 대화', Icons.chat, '/chat'),
            _buildButton(context, '간병일지 확인', Icons.lock, '/caregiver_log'), // ✅ 간병일지 화면 연결
            _buildButton(context, '환자 정보 수정', Icons.edit, '/guardian_patient_register'),
          ],
        ),
      ),

      // ✅ 하단 네비게이션 바 유지
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '간병인 찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: '내 환자 정보'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '마이페이지'),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 1) {
            Navigator.pop(context, _nameController.text);
          }
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, route),
        icon: Icon(icon, color: Colors.black),
        label: Text(text, style: const TextStyle(color: Colors.black)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.black),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}
