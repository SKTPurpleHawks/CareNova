import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const CustomBottomNavigationBar({super.key, required this.currentIndex, required this.context});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: '간병인 찾기'),
        BottomNavigationBarItem(icon: Icon(Icons.edit), label: '내 환자 정보'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '마이페이지'),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamed(context, '/guardian_patient_selection_screen');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/guardian_patient_list');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/mypage'); // ✅ 마이페이지 추가 가능
        }
      },
    );
  }
}
