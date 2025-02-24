// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'package:prac11/guardian/guardian_patient_selection_screen.dart';

// class ReviewEditScreen extends StatefulWidget {
//   final String token;
//   final String caregiverId;
//   final String protectorId;

//   const ReviewEditScreen({
//     Key? key,
//     required this.token,
//     required this.caregiverId,
//     required this.protectorId,
//   }) : super(key: key);

//   @override
//   _ReviewEditScreenState createState() => _ReviewEditScreenState();
// }

// class _ReviewEditScreenState extends State<ReviewEditScreen> {
//   double diaryWriting = 0;
//   double workAttitude = 0;
//   double patientHygiene = 0;
//   double personalHygiene = 0;
//   double understandingRequests = 0;
//   double responseAccuracy = 0;
//   TextEditingController reviewController = TextEditingController();

//   /// 별점 업데이트 함수 (드래그하여 변경 가능)
//   void updateRating(Function(double) updateFunc, double value) {
//     setState(() {
//       updateFunc(value);
//     });
//   }

//   /// 리뷰 제출 함수
//   Future<void> submitReview() async {
//     // 임시로 API 호출을 주석 처리
//     /*
//   double sincerity = (diaryWriting + workAttitude) / 2;
//   double hygiene = (patientHygiene + personalHygiene) / 2;
//   double communication = (understandingRequests + responseAccuracy) / 2;
//   double totalScore = (sincerity + hygiene + communication) / 3;

//   final url = Uri.parse('http://192.168.232.218:8000/reviews');

//   final response = await http.post(
//     url,
//     headers: {
//       'Authorization': 'Bearer ${widget.token}',
//       'Content-Type': 'application/json',
//     },
//     body: jsonEncode({
//       'caregiver_id': widget.caregiverId,
//       'protector_id': widget.protectorId,
//       'sincerity': sincerity,
//       'hygiene': hygiene,
//       'communication': communication,
//       'total_score': totalScore,
//       'review_content': reviewController.text,
//     }),
//   );

//   if (response.statusCode == 200) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('리뷰가 저장되었습니다.')),
//     );

//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             GuardianPatientSelectionScreen(token: widget.token),
//       ),
//       (route) => false,
//     );
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('리뷰 저장 실패!')),
//     );
//   }
//   */

//     // 임시로 성공 메시지와 화면 이동만 구현 (API 없이)
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('임시: 리뷰가 저장되었습니다.')),
//     );

//     // Navigator.pushAndRemoveUntil(
//     //   context,
//     //   MaterialPageRoute(
//     //     builder: (context) =>
//     //         GuardianPatientSelectionScreen(token: widget.token),
//     //   ),
//     //   (route) => false,
//     // );
//   }

//   Widget buildStarRating(
//       String label, double currentRating, Function(double) onRatingUpdate) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         SizedBox(height: 8),
//         GestureDetector(
//           onHorizontalDragUpdate: (details) {
//             // 슬라이드 거리 기반으로 별점 조정 (0~5 사이)
//             double dx = details.localPosition.dx;
//             double newRating = (dx / 40).clamp(0, 5); // 40px 당 1점
//             updateRating(onRatingUpdate, newRating);
//           },
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(5, (index) {
//               double starValue = index + 1.0;
//               bool isHalfFilled =
//                   currentRating >= starValue - 0.5 && currentRating < starValue;
//               return GestureDetector(
//                 onTap: () => updateRating(
//                     onRatingUpdate, isHalfFilled ? starValue - 0.5 : starValue),
//                 child: Icon(
//                   isHalfFilled
//                       ? Icons.star_half
//                       : (currentRating >= starValue
//                           ? Icons.star
//                           : Icons.star_border),
//                   color: Colors.amber,
//                   size: 40,
//                 ),
//               );
//             }),
//           ),
//         ),
//         SizedBox(height: 10),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true, // ✅ 타이틀 가운데 정렬
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Image.asset(
//           'assets/images/textlogo.png',
//           height: 25,
//           fit: BoxFit.contain,
//         ),
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),




//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 10),
//               Text(
//                 "간병인 리뷰",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ), 
            
//         EdgeInsets.all(16),
//         child: Column(
//           children: [
//             buildStarRating("간병일지 작성", diaryWriting,
//                 (rating) => setState(() => diaryWriting = rating)),
//             buildStarRating("근무 태도", workAttitude,
//                 (rating) => setState(() => workAttitude = rating)),
//             buildStarRating("환자 위생 관리", patientHygiene,
//                 (rating) => setState(() => patientHygiene = rating)),
//             buildStarRating("개인 위생 관리", personalHygiene,
//                 (rating) => setState(() => personalHygiene = rating)),
//             buildStarRating("요청 이해도", understandingRequests,
//                 (rating) => setState(() => understandingRequests = rating)),
//             buildStarRating("반응 정확도", responseAccuracy,
//                 (rating) => setState(() => responseAccuracy = rating)),

//             SizedBox(height: 10),

//             // 리뷰 입력 필드
//             TextField(
//               controller: reviewController,
//               decoration: InputDecoration(
//                 labelText: "리뷰 작성",
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//             ),

//             SizedBox(height: 20),

//             // 버튼 그룹 (확인 / 취소)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 TextButton(
//                   onPressed: submitReview,
//                   child: Text("확인"),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     // 이전 화면으로 돌아가기
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
//                   child: Text("취소"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
