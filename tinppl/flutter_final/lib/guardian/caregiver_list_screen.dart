// import 'package:flutter/material.dart';
//
// class CaregiverListScreen extends StatelessWidget {
//   const CaregiverListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // 선택된 환자 정보 받기
//     final String? selectedPatient = ModalRoute.of(context)?.settings.arguments as String?;
//
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('간병인 리스트'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Text(
//               '*조건에 맞춘 간병인 추천 순위 리스트입니다*',
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//           ),
//           if (selectedPatient != null)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Text(
//                 '🔍 선택된 환자: $selectedPatient',
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//           Expanded(
//             child: ListView(
//               children: [
//                 _buildCaregiverCard('서민석', 25, '남성', '1년', 5),
//                 _buildCaregiverCard('최명일', 26, '여성', '2년', 4),
//                 _buildCaregiverCard('이수현', 27, '남성', '1년', 3),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCaregiverCard(String name, int age, String gender, String experience, int rating) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Icon(Icons.person, size: 40),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildRatingStars(rating),
//                   Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   Text('나이: ${age}세'),
//                   Text('성별: $gender'),
//                   Text('경력: $experience'),
//                 ],
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.black,
//                 side: const BorderSide(color: Colors.black),
//               ),
//               child: const Text('상세보기'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRatingStars(int rating) {
//     return Row(
//       children: List.generate(5, (index) {
//         return Icon(
//           index < rating ? Icons.star : Icons.star_border,
//           color: Colors.blue,
//           size: 18,
//         );
//       }),
//     );
//   }
// }
