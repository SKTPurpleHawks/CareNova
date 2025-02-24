import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CaregiverPatientLogCreateScreen extends StatefulWidget {
  final String patientName;
  final String caregiverId;
  final String protectorId;
  final String patientId;
  final String token;
  final Map<String, dynamic>? initialLogData;
  final bool isReadOnly; // 읽기 전용 모드 여부

  const CaregiverPatientLogCreateScreen({
    super.key,
    required this.patientName,
    required this.caregiverId,
    required this.protectorId,
    required this.patientId,
    required this.token,
    this.initialLogData,
    this.isReadOnly = false, // 기본값 false (수정 가능)
  });

  @override
  _CaregiverPatientLogCreateScreenState createState() =>
      _CaregiverPatientLogCreateScreenState();
}

class _CaregiverPatientLogCreateScreenState
    extends State<CaregiverPatientLogCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _location;
  String? _mood;
  String? _sleepQuality;
  String? _urineColor;
  String? _urineSmell;
  bool _urineFoam = false;
  String? _stool;

  bool _positionChange = false;
  bool _wheelchairTransfer = false;
  bool _walkingAssistance = false;
  bool _outdoorWalk = false;

  String? _breakfastType;
  String? _lunchType;
  String? _dinnerType;
  String? _breakfastAmount;
  String? _lunchAmount;
  String? _dinnerAmount;

  final TextEditingController _urineAmountController = TextEditingController();
  final TextEditingController _stoolTimesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialLogData != null) {
      Map<String, dynamic> log = widget.initialLogData!;
      _location = log["location"];
      _mood = log["mood"];
      _sleepQuality = log["sleep_quality"];
      _breakfastType = log["breakfast_type"];
      _breakfastAmount = log["breakfast_amount"];
      _lunchType = log["lunch_type"];
      _lunchAmount = log["lunch_amount"];
      _dinnerType = log["dinner_type"];
      _dinnerAmount = log["dinner_amount"];
      _urineAmountController.text = log["urine_amount"] ?? "";
      _urineColor = log["urine_color"];
      _urineSmell = log["urine_smell"];
      _urineFoam = log["urine_foam"] ?? false;
      _stoolTimesController.text = log["stool_amount"] ?? "";
      _stool = log["stool_condition"];
      _positionChange = log["position_change"] ?? false;
      _wheelchairTransfer = log["wheelchair_transfer"] ?? false;
      _walkingAssistance = log["walking_assistance"] ?? false;
      _outdoorWalk = log["outdoor_walk"] ?? false;
      _notesController.text = log["notes"] ?? "";
    } else {
      _location = "병원";
      _mood = "보통";
      _sleepQuality = "보통";
      _breakfastType = "선택해주세요.";
      _breakfastAmount = "선택해주세요.";
      _lunchType = "선택해주세요.";
      _lunchAmount = "선택해주세요.";
      _dinnerType = "선택해주세요.";
      _dinnerAmount = "선택해주세요.";
      _stool = "보통";
    }
  }

  Future<void> saveCareLog() async {
    final isEditing = widget.initialLogData != null;
    final url = isEditing
        ? Uri.parse(
            'http://192.168.232.218:8000/dailyrecord/${widget.initialLogData!["id"]}') // 수정
        : Uri.parse('http://192.168.232.218:8000/dailyrecord'); // 새 기록

    final method = isEditing ? "PUT" : "POST";

    final response = await (method == "POST"
        ? http.post(url, headers: _headers, body: _requestBody())
        : http.put(url, headers: _headers, body: _requestBody()));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isEditing ? "간병일지가 수정되었습니다." : "간병일지가 저장되었습니다.")),
      );
      Navigator.pop(context, true); // true 반환하여 이전 화면에서 새로고침 가능하게 설정
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("간병일지 저장 실패")),
      );
    }
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      };

  String _requestBody() {
    return jsonEncode({
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isReadOnly ? "간병일지 상세 보기" : "간병일지 작성")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _sectionTitle("기본 정보"),
              _buildField("장소", _location, ["병원", "요양원", "자택"]),
              _buildField("기분", _mood, ["좋음", "보통", "안좋음"]),
              _buildField("수면 상태", _sleepQuality, ["좋음", "보통", "나쁨"]),
              _sectionTitle("식사 정보"),
              _buildMealSection(
                  "아침",
                  _breakfastType,
                  _breakfastAmount,
                  (type, amount) => setState(() {
                        _breakfastType = type;
                        _breakfastAmount = amount;
                      })),
              _buildMealSection(
                  "점심",
                  _lunchType,
                  _lunchAmount,
                  (type, amount) => setState(() {
                        _lunchType = type;
                        _lunchAmount = amount;
                      })),
              _buildMealSection(
                  "저녁",
                  _dinnerType,
                  _dinnerAmount,
                  (type, amount) => setState(() {
                        _dinnerType = type;
                        _dinnerAmount = amount;
                      })),
              _sectionTitle("소변 정보"),
              _buildTextField("소변 횟수", _urineAmountController),
              _buildField("소변 색", _urineColor, ["붉은색", "정상"]),
              _buildField("소변 냄새", _urineSmell, ["있음", "없음"]),
              _buildCheckbox("거품 있음", _urineFoam, (val) => _urineFoam = val),
              _sectionTitle("대변 정보"),
              _buildTextField("대변 횟수", _stoolTimesController),
              _buildField("대변 상태", _stool, ["설사", "보통", "변비"]),
              _sectionTitle("이동 및 활동"),
              _buildCheckbox(
                  "체위 변경", _positionChange, (val) => _positionChange = val),
              _buildCheckbox("침대 → 휠체어 이동", _wheelchairTransfer,
                  (val) => _wheelchairTransfer = val),
              _buildCheckbox("보행 도움", _walkingAssistance,
                  (val) => _walkingAssistance = val),
              _buildCheckbox("산책", _outdoorWalk, (val) => _outdoorWalk = val),
              _sectionTitle("요청/특이사항"),
              _buildTextField("요청/특이사항", _notesController, maxLines: 3),
              widget.isReadOnly
                  ? ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("뒤로 가기"),
                    )
                  : ElevatedButton(
                      onPressed: saveCareLog, // 저장 함수 연결 필요
                      child: Text("간병일지 저장"),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealSection(String meal, String? type, String? amount,
      Function(String, String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(meal),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                  "$meal 식사", type, ["선택해주세요.", "일반식", "죽", "유동식(경관식)"],
                  (value) {
                if (value != null) {
                  setState(() {
                    onChanged(value, amount ?? "선택해주세요.");
                  });
                }
              }),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDropdown("$meal 식사량", amount, [
                "선택해주세요.",
                "완식 (100%)",
                "반식 (50%)",
                "소식 (25%)",
                "거부 (0%)"
              ], (value) {
                if (value != null) {
                  setState(() {
                    onChanged(type ?? "선택해주세요.", value);
                  });
                }
              }),
            ),
          ],
        ),
      ],
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

  Widget _buildField(String label, String? value, List<String> items) {
    return widget.isReadOnly
        ? _buildReadOnlyTextField(label, value ?? "데이터 없음")
        : _buildDropdown(label, value, items, (val) {
            if (val != null) {
              setState(() {
                value = val; // 변경된 값 적용
              });
            }
          });
  }

  Widget _buildReadOnlyTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        readOnly: true,
        initialValue: value,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null, // 값이 리스트에 있는지 확인 후 설정
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: widget.isReadOnly
            ? null
            : (val) {
                if (val != null) {
                  setState(() {
                    onChanged(val);
                  });
                }
              },
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        disabledHint: Text(value ?? ""),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: widget.isReadOnly,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildCheckbox(
      String label, bool currentValue, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(
        label,
        style: TextStyle(
          color: widget.isReadOnly ? Colors.black : null, // 읽기 모드에서 검정색
          fontWeight: widget.isReadOnly ? FontWeight.bold : null, // 읽기 모드에서 볼드체
        ),
      ),
      value: currentValue,
      onChanged: widget.isReadOnly
          ? null
          : (val) {
              if (val != null) {
                setState(() => onChanged(val));
              }
            },
      activeColor: widget.isReadOnly ? Colors.black : null, // 체크 색상을 검정으로 변경
      checkColor: widget.isReadOnly ? Colors.white : null, // 체크 내부 색상 (가독성 유지)
    );
  }
}
