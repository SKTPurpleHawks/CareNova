import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaregiverSignupScreen extends StatefulWidget {
  const CaregiverSignupScreen({super.key});

  @override
  State<CaregiverSignupScreen> createState() => _CaregiverSignupScreenState();
}

class _CaregiverSignupScreenState extends State<CaregiverSignupScreen> {
  bool _canWalk = false; // 못 걷는 사람 간병 가능 여부
  String? _selectedSpot = '집'; // 간병 가능 장소 기본값
  String? _selectedSex;
  String? _preferredSex;

  // 생년월일 관련 변수
  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedDay;

  final List<String> years =
      List.generate(100, (index) => (2024 - index).toString());
  final List<String> months =
      List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  final List<String> days =
      List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF43C098); // 메인 컬러 (초록)

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // 그림자 제거
        title: Text(
          '간병인 회원가입',
          style: GoogleFonts.notoSansKr(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('이메일', hintText: '0000@flyai.com'),
            const SizedBox(height: 25),
            _buildTextField('비밀번호', obscureText: true),
            _buildTextField('비밀번호 확인', obscureText: true),
            const SizedBox(height: 25),

            _buildTextField('이름'),
            _buildTextField('나이'),
            _buildTextField('키'),
            _buildTextField('몸무게'),
            _buildTextField('전화번호', hintText: '010-0000-0000'),
            const SizedBox(height: 25),

            _buildDropdownField('성별',
                options: ['남성', '여성'],
                onChanged: (value) => setState(() => _selectedSex = value)),
            const SizedBox(height: 25),

            // 생년월일 필드 적용
            _buildBirthdateSelector(),
            const SizedBox(height: 25),

            _buildTextField('간병 가능 지역'),
            _buildTextField('간병 가능한 질환'),

            _buildDropdownField('간병 가능 장소',
                options: ['집', '병원', '둘다'],
                onChanged: (value) => setState(() => _selectedSpot = value)),
            const SizedBox(height: 15),

            _buildTextField('간병해본 진단명(경력)'),
            _buildTextField('간병 가능한 증상'),

            // 못 걷는 사람 간병 가능 여부 체크박스
            Row(
              children: [
                Checkbox(
                  value: _canWalk,
                  onChanged: (bool? value) {
                    setState(() {
                      _canWalk = value!;
                    });
                  },
                ),
                Text(
                  '못 걷는 사람도 간병 가능',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            _buildDropdownField(
              '선호하는 환자 성별',
              options: ['남성', '여성'],
              onChanged: (value) => setState(() => _preferredSex = value),
            ),

            const SizedBox(height: 32),

            // 가입하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '가입하기',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '생년월일',
          style: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4), // 제목과 드롭다운 사이 간격 최소화
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 2.0), // **년도 라벨과 드롭다운 간격 최소화**
                    child: Text(
                      '년도',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  _buildDropdownField2(
                    '',
                    options: years,
                    onChanged: (value) => setState(() => _selectedYear = value),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6), // 간격 최소화
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 2.0), // **월 라벨과 드롭다운 간격 최소화**
                    child: Text(
                      '월',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  _buildDropdownField2(
                    '',
                    options: months,
                    onChanged: (value) =>
                        setState(() => _selectedMonth = value),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6), // 간격 최소화
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 2.0), // **일 라벨과 드롭다운 간격 최소화**
                    child: Text(
                      '일',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  _buildDropdownField2(
                    '',
                    options: days,
                    onChanged: (value) => setState(() => _selectedDay = value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label,
      {String hintText = '', bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 1.0), // 설명 텍스트 간격 추가
          child: Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.notoSansKr(
              // 💡 힌트 텍스트 흐리게 적용
              fontSize: 14,
              fontWeight: FontWeight.w400, // Regular로 설정하여 가볍게
              color: Colors.black45, // 흐리게 보이도록 회색 톤 적용
            ),
            labelStyle: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(height: 10), // 필드 간 간격 추가
      ],
    );
  }

  Widget _buildDropdownField2(String label,
      {List<String>? options, ValueChanged<String?>? onChanged}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // 박스 둥글기 줄임
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 2, horizontal: 8), // 내부 패딩 최대한 줄이기
      ),
      value: null,
      items: options?.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownField(String label,
      {List<String>? options, ValueChanged<String?>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0), // 설명 텍스트 간격 추가
          child: Text(
            label, // 💡 라벨 표시 유지
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label, // 💡 라벨이 드롭다운 내부에도 유지되도록 추가
            labelStyle: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
          value: null,
          items: options?.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16), // 필드 간 간격 추가
      ],
    );
  }
}
