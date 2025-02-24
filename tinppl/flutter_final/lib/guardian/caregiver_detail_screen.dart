import 'package:flutter/material.dart';

class CaregiverDetailScreen extends StatelessWidget {
  final Map<String, dynamic> caregiver;

  const CaregiverDetailScreen({super.key, required this.caregiver});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // ✅ 타이틀 가운데 정렬
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/textlogo.png',
          height: 25,
          fit: BoxFit.contain,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1), // 그림자 색상 조정 가능
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        child: Icon(Icons.person,
                            size: 80, color: Color(0xFF43C098)),
                      ),
                      SizedBox(height: 10),
                      Text(
                        caregiver['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite, color: Colors.teal, size: 20),
                          SizedBox(width: 4),
                          Text('${caregiver['matchingRate']}%',
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          double rating = caregiver['rating'];
                          if (index < rating.floor()) {
                            return Icon(Icons.star,
                                size: 30, color: Colors.amber);
                          } else if (index < rating) {
                            return Icon(Icons.star_half,
                                size: 30, color: Colors.amber);
                          } else {
                            return Icon(Icons.star_border,
                                size: 30, color: Colors.amber);
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2), // 그림자 색상 조정 가능
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('나이', '${caregiver['age']}세'),
                      SizedBox(height: 12),
                      _buildDetailRow('성별', caregiver['gender']),
                      SizedBox(height: 12),
                      _buildDetailRow('키', '${caregiver['height']} cm'),
                      SizedBox(height: 12),
                      _buildDetailRow('몸무게', '${caregiver['weight']} kg'),
                      SizedBox(height: 12),
                      _buildDetailRow('경력', '${caregiver['experience']}년'),
                      SizedBox(height: 12),
                      _buildDetailRow('간병 장소', caregiver['spot']),
                      SizedBox(height: 12),
                      _buildChipDetailRow(
                          '가능 지역', List<String>.from(caregiver['regions'])),
                      SizedBox(height: 12),
                      _buildChipDetailRow(
                          '가능 질환', List<String>.from(caregiver['symptoms'])),
                      SizedBox(height: 12),
                      _buildDetailRow('보행 지원', caregiver['canWalkPatient']),
                      SizedBox(height: 12),
                      _buildDetailRow('선호 성별', caregiver['preferSex']),
                      SizedBox(height: 12),
                      _buildDetailRow('흡연 여부', caregiver['smoking']),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 90), // 버튼 높이만큼 여유공간 확보
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF43C098),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
            child: Text('매칭하기',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildChipDetailRow(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items
              .map((item) => Chip(
                    label: Text(item,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black)),
                    backgroundColor: Color.fromARGB(76, 67, 192, 152),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: const Color.fromARGB(255, 0, 133, 122)),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
