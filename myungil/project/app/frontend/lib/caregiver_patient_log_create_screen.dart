import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CaregiverPatientLogCreateScreen extends StatefulWidget {
  final String patientName;
  final String caregiverId;
  final String protectorId;
  final String patientId;
  final String token;

  const CaregiverPatientLogCreateScreen({
    super.key,
    required this.patientName,
    required this.caregiverId,
    required this.protectorId,
    required this.patientId,
    required this.token,
  });

  @override
  _CaregiverPatientLogCreateScreenState createState() =>
      _CaregiverPatientLogCreateScreenState();
}

class _CaregiverPatientLogCreateScreenState
    extends State<CaregiverPatientLogCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  // 입력값 저장 변수
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

  // ✅ API 호출 - 간병일지 저장 함수
  Future<void> saveCareLog() async {
    final url = Uri.parse('http://10.0.2.2:8000/dailyrecord');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "caregiver_id": widget.caregiverId,
        "protector_id": widget.protectorId,
        "patient_id": widget.patientId,
        "location": _location,
        "mood": _mood,
        "sleep_quality": _sleepQuality,
        "breakfast_type": _breakfastType,
        "breakfast_amount": _breakfastAmount,
        "lunch_type": _lunchType,
        "lunch_amount": _lunchAmount,
        "dinner_type": _dinnerType,
        "dinner_amount": _dinnerAmount,
        "urine_amount": _urineAmountController.text,
        "urine_color": _urineColor,
        "urine_smell": _urineSmell,
        "urine_foam": _urineFoam,
        "stool_amount": _stoolTimesController.text,
        "stool_condition": _stool,
        "position_change": _positionChange,
        "wheelchair_transfer": _wheelchairTransfer,
        "walking_assistance": _walkingAssistance,
        "outdoor_walk": _outdoorWalk,
        "notes": _notesController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("간병일지가 저장되었습니다.")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("간병일지 저장 실패")),
      );
    }
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

              _sectionTitle("요청/특이사항"),
              _buildTextField("요청/특이사항", _notesController, maxLines: 3),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: saveCareLog, // API 저장 함수 호출
                child: const Text("간병일지 저장"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      Function(String?) onChanged) {
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
}
