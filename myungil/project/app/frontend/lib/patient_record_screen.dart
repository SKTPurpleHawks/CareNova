import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PatientRecordScreen extends StatefulWidget {
  final String patientId;

  const PatientRecordScreen({required this.patientId, super.key});

  @override
  State<PatientRecordScreen> createState() => _PatientRecordScreenState();
}

class _PatientRecordScreenState extends State<PatientRecordScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;
  String? _processedAudioPath;
  List<String> _messages = [];
  List<BarDefinition> _bars = [];
  Timer? _timer;
  int _remainingTime = 30;

  double _currentDecibel = -50.0;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initPlayer();
    _generateInitialWaveform(); // 초기 웨이브폼 생성
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _initPlayer() async {
    await _player.openPlayer();
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;

    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/recording.wav';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV,
      sampleRate: 16000,
      numChannels: 1,
    );

    _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
    _recorder.onProgress?.listen((RecordingDisposition d) {
      setState(() {
        _currentDecibel = d.decibels ?? -50.0;
        _updateWaveform(_currentDecibel); // ✅ 실시간 웨이브 업데이트
      });
    });

    setState(() {
      _isRecording = true;
      _filePath = path;
      _remainingTime = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0) {
        _stopRecording();
      }
    });
  }

  /// 웨이브폼을 업데이트하는 함수 (데시벨 값 기반)
  void _updateWaveform(double decibel) {
    double base = ((decibel + 60) / 60).clamp(0.1, 1.0);
    final time = DateTime.now().millisecondsSinceEpoch;

    setState(() {
      _bars = List.generate(18, (index) {
        double phase = index / 18 * 2 * pi;
        double variation = 0.2 * sin(2 * pi * (time % 1000) / 1000 + phase);
        double newHeight = (base + variation).clamp(0.1, 1.0);
        return BarDefinition(
          heightFactor: newHeight,
          color: Colors.green.shade700.withOpacity(0.8),
        );
      });
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    await _recorder.stopRecorder();
    _timer?.cancel();

    setState(() {
      _isRecording = false;
      _generateInitialWaveform(); // 녹음 종료 후 기본 웨이브폼 설정
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('녹음 완료')),
    );

    if (_filePath != null) {
      String? processedFilePath = await _uploadAudio(_filePath!);
      if (processedFilePath != null) {
        setState(() {
          _processedAudioPath = processedFilePath;
        });

        _playProcessedAudio(); // 자동 음성 재생

        String? convertedText = await _convertSpeechToText(processedFilePath);
        if (convertedText != null) {
          setState(() {
            _messages.insert(0, convertedText);
          });
        }
      }
    }
  }

  Future<String?> _uploadAudio(String filePath) async {
    var uri = Uri.parse(
        "http://172.23.250.30:8000/process_audio/${widget.patientId}");
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    var response = await request.send();

    if (response.statusCode == 200) {
      Directory tempDir = await getApplicationDocumentsDirectory();
      String path = '${tempDir.path}/processed_audio.wav';
      File file = File(path);

      await file.writeAsBytes(await response.stream.toBytes());

      if (!file.existsSync()) {
        return null;
      }

      return path;
    } else {
      return null;
    }
  }

  Future<String?> _convertSpeechToText(String filePath) async {
    var apiUrl = "https://api.openai.com/v1/audio/transcriptions";
    String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..fields['model'] = 'whisper-1'
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> decodedResponse = jsonDecode(responseBody);
        return decodedResponse['text'] ?? "변환된 텍스트가 없습니다.";
      } else {
        debugPrint("❌ Whisper API 요청 실패: ${response.reasonPhrase}");
        return "음성 변환에 실패했습니다.";
      }
    } catch (e) {
      debugPrint("❌ Whisper API 오류: $e");
      return "음성 변환 오류 발생";
    }
  }

  Future<void> _playProcessedAudio() async {
    if (_isPlaying || _processedAudioPath == null) return;

    File audioFile = File(_processedAudioPath!);
    if (!audioFile.existsSync()) {
      return;
    }

    try {
      await _player.startPlayer(
        fromURI: _processedAudioPath!,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );

      setState(() {
        _isPlaying = true;
      });
    } catch (e) {}
  }

  /// 기본 웨이브폼을 생성하는 함수
  void _generateInitialWaveform() {
    setState(() {
      _bars = List.generate(18, (index) {
        return BarDefinition(
          heightFactor: 0.2,
          color: Colors.green.shade600.withOpacity(0.8),
        );
      });
    });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double waveWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      appBar: AppBar(title: const Text('대화하기기')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF43C098),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _messages[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: waveWidth,
            height: 100,
            child: LiveAudioWave(
              bars: _bars,
              width: waveWidth,
              height: 100,
              spacing: 4,
            ),
          ),
          FloatingActionButton.large(
                        onPressed: _isRecording ? _stopRecording : _startRecording,
            backgroundColor:
                _isRecording ? Colors.grey : const Color(0xFF43C098),
            child: const Icon(Icons.mic, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class BarDefinition {
  final double heightFactor;
  final Color? color;
  BarDefinition({required this.heightFactor, this.color});
}

class LiveAudioWave extends StatelessWidget {
  final List<BarDefinition> bars;
  final double width;
  final double height;
  final double spacing;

  const LiveAudioWave({
    super.key,
    required this.bars,
    required this.width,
    required this.height,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: bars.map((bar) {
          return Container(
            width: (width / bars.length).clamp(6.0, 15.0),
            height: height * bar.heightFactor,
            margin: EdgeInsets.only(right: spacing),
            decoration: BoxDecoration(
              color: bar.color,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }).toList(),
      ),
    );
  }
}
