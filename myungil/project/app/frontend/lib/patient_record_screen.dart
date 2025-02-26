import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class PatientRecordScreen extends StatefulWidget {
  
  final String patientId;


  const PatientRecordScreen({
    required this.patientId,
    super.key});

  @override
  State<PatientRecordScreen> createState() => _PatientRecordScreenState();
}

class _PatientRecordScreenState extends State<PatientRecordScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;
  List<String> _messages = [];
  List<BarDefinition> _bars = [];
  Timer? _timer;
  int _remainingTime = 30;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initPlayer();
    _generateInitialWaveform();
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
    print(path);

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV,
      sampleRate: 16000,
      numChannels: 1,
    );

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

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    await _recorder.stopRecorder();
    _timer?.cancel();

    setState(() {
      _isRecording = false;
      _generateInitialWaveform();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('녹음 완료')),
    );

    if (_filePath != null) {
      String? processedFilePath = await _uploadAudio(_filePath!);
      if (processedFilePath != null) {
        await _playProcessedAudio(processedFilePath);
      }
    }
  }

  Future<String?> _uploadAudio(String filePath) async {
    var uri = Uri.parse("http://172.23.250.30:8000/process_audio/${widget.patientId}");
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    var response = await request.send();

    if (response.statusCode == 200) {
      Directory tempDir = await getApplicationDocumentsDirectory();
      String path = '${tempDir.path}/processed_audio.wav';
      File file = File(path);

      await file.writeAsBytes(await response.stream.toBytes());

      // ✅ 다운로드된 파일 존재 여부 확인
      if (!file.existsSync()) {
        debugPrint("❌ 서버 응답이 있었지만 파일이 저장되지 않음");
        return null;
      }

      debugPrint("✅ 변환된 음성 다운로드 완료: $path");

      return path;
    } else {
      debugPrint("❌ 업로드 실패: ${response.reasonPhrase}");
      return null;
    }
  }

  Future<void> _playProcessedAudio(String filePath) async {
    if (_isPlaying) {
      await _player.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
    }

    // 🔍 파일이 존재하는지 확인
    File audioFile = File(filePath);
    if (!audioFile.existsSync()) {
      debugPrint("❌ 변환된 음성 파일이 존재하지 않음: $filePath");
      return;
    }

    try {
      await _player.startPlayer(
        fromURI: filePath,
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

      debugPrint("▶ 음성 재생 시작: $filePath");
    } catch (e) {
      debugPrint("❌ 재생 오류: $e");
    }
  }

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
    double screenWidth = MediaQuery.of(context).size.width;
    double waveWidth = screenWidth * 0.9;

    return Scaffold(
      appBar: AppBar(title: const Text('환자 녹음 및 변환')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43C098),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _messages[index],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: waveWidth,
              height: 100,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: LiveAudioWave(
                      bars: _bars,
                      width: waveWidth,
                      height: 100,
                      spacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isRecording ? Colors.grey : const Color(0xFF43C098),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(28),
                elevation: 8,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
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
