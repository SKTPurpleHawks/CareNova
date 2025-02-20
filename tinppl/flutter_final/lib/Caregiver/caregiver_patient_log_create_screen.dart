import 'package:flutter/material.dart';

class CaregiverPatientLogCreateScreen extends StatefulWidget {
  final String patientName;

  const CaregiverPatientLogCreateScreen({super.key, required this.patientName});

  @override
  _CaregiverPatientLogCreateScreenState createState() =>
      _CaregiverPatientLogCreateScreenState();
}

class _CaregiverPatientLogCreateScreenState extends State<CaregiverPatientLogCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  // 모든 입력값을 저장할 변수들
  String? _location = "병원";
  String? _mood = "보통";
  String? _sleepQuality = "보통";
  String? _urineColor;
  String? _urineSmell;
  bool _urineFoam = false;
  String? _stool = "보통";

  bool _positionChange = false;
  bool _wheelchairTransfer = false;
  bool _walkingAssistance = false;
  bool _outdoorWalk = false;

  String? _breakfastType = "일반식";
  String? _lunchType = "일반식";
  String? _dinnerType = "일반식";
  double _breakfastAmount = 0.0;
  double _lunchAmount = 0.0;
  double _dinnerAmount = 0.0;

  final TextEditingController _urineAmountController = TextEditingController();
  final TextEditingController _stoolTimesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();



  // ✅ 받은 데이터 출력 (테스트용)
  void _printLog() {
    String createdAt = DateTime.now().toLocal().toString().substring(0, 19); // 현재 날짜 및 시간
    print("📌 [간병일지 입력 데이터]");
    print("📌 작성 날짜: $createdAt"); // ✅ 작성 날짜 출력
    print("📌 기본정보");
    print("- 장소: $_location");
    print("- 기분: $_mood");
    print("- 수면 상태: $_sleepQuality");

    print("📌 식사 정보");
    print("- 아침: $_breakfastType, 섭취량: $_breakfastAmount");
    print("- 점심: $_lunchType, 섭취량: $_lunchAmount");
    print("- 저녁: $_dinnerType, 섭취량: $_dinnerAmount");

    print("📌 소변 정보");
    print("- 소변 횟수: ${_urineAmountController.text}");
    print("- 소변 색: $_urineColor");
    print("- 소변 냄새: $_urineSmell");
    print("- 소변 거품 여부: $_urineFoam");

    print("📌 대변 정보");
    print("- 대변 횟수: ${_stoolTimesController.text}");
    print("- 대변 상태: $_stool");

    print("📌 이동 및 활동");
    print("- 체위 변경: $_positionChange");
    print("- 침대 → 휠체어 이동: $_wheelchairTransfer");
    print("- 보행 도움: $_walkingAssistance");
    print("- 산책: $_outdoorWalk");

    print("📌 요청/특이사항");
    print("- ${_notesController.text}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("입력된 데이터가 콘솔에 출력되었습니다.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("간병일지 작성")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _sectionTitle("기본 정보"),
              _buildDropdown("장소", _location, ["병원", "요양원", "자택"],
                      (value) => setState(() => _location = value)),
              _buildDropdown("기분", _mood, ["좋음", "보통", "안좋음"],
                      (value) => setState(() => _mood = value)),
              _buildDropdown("수면 상태", _sleepQuality, ["좋음", "보통", "나쁨"],
                      (value) => setState(() => _sleepQuality = value)),

              _sectionTitle("식사 정보"),
              _buildMealSection("아침", _breakfastType, _breakfastAmount,
                      (type, amount) => setState(() {
                    _breakfastType = type;
                    _breakfastAmount = amount;
                  })),
              _buildMealSection("점심", _lunchType, _lunchAmount,
                      (type, amount) => setState(() {
                    _lunchType = type;
                    _lunchAmount = amount;
                  })),
              _buildMealSection("저녁", _dinnerType, _dinnerAmount,
                      (type, amount) => setState(() {
                    _dinnerType = type;
                    _dinnerAmount = amount;
                  })),

              _sectionTitle("소변 정보"),
              _buildTextField("소변 횟수", _urineAmountController),
              _buildDropdown("소변 색", _urineColor, ["붉은색", "정상"],
                      (value) => setState(() => _urineColor = value)),
              _buildDropdown("소변 냄새", _urineSmell, ["있음", "없음"],
                      (value) => setState(() => _urineSmell = value)),
              _buildCheckbox("거품 있음", _urineFoam,
                      (value) => setState(() => _urineFoam = value ?? false)),

              _sectionTitle("대변 정보"),
              _buildTextField("대변 횟수", _stoolTimesController),
              _buildDropdown("대변 상태", _stool, ["설사", "보통", "변비"],
                      (value) => setState(() => _stool = value)),

              _sectionTitle("이동 및 활동"),
              _buildCheckbox("체위 변경", _positionChange,
                      (value) => setState(() => _positionChange = value ?? false)),
              _buildCheckbox("침대 → 휠체어 이동", _wheelchairTransfer,
                      (value) => setState(() => _wheelchairTransfer = value ?? false)),
              _buildCheckbox("보행 도움", _walkingAssistance,
                      (value) => setState(() => _walkingAssistance = value ?? false)),
              _buildCheckbox("산책", _outdoorWalk,
                      (value) => setState(() => _outdoorWalk = value ?? false)),

              _sectionTitle("요청/특이사항"),
              _buildTextField("요청/특이사항", _notesController, maxLines: 3),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _printLog, // ✅ 데이터 출력
                child: const Text("데이터 확인하기"),
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // UI에서 목록 화면으로 이동
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // 버튼 색상 변경
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("간병일지 저장", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),

            ],
          ),
        ),
      ),
    );
  }

  /// ✅ 섹션 제목 스타일 추가
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: CheckboxListTile(title: Text(label), value: value, onChanged: onChanged),
    );
  }

  Widget _buildMealSection(String meal, String? type, double amount, Function(String, double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(meal, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0), // 🟢 간격 추가 (텍스트와 Dropdown 사이)
          _buildDropdown("$meal 식사", type, ["일반식", "죽", "유동식(경관식)"], (value) {
            onChanged(value!, amount);
          }),
          Slider(
            value: amount,
            min: 0,
            max: 1,
            divisions: 4,
            label: "$amount",
            onChanged: (value) => onChanged(type!, value),
          ),
        ],
      ),
    );
  }
}
