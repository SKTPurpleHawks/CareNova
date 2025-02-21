import torch
import os
import librosa
import openai
from dotenv import load_dotenv
import numpy as np
import soundfile as sf
from faster_whisper import WhisperModel
import ctranslate2



os.environ["CUDA_LAUNCH_BLOCKING"] = "1"

load_dotenv()  # .env 파일 로드
openai.api_key = os.getenv("OPENAI_API_KEY")

# GPU 확인
device = "cuda"
print(f"1. 현재 사용 중인 디바이스: {device}")

# CUDA가 지원되는지 확인
supported_types = ctranslate2.get_supported_compute_types("cuda")
print("2. CTranslate2 CUDA 지원 여부:", supported_types)

# Whisper 모델 불러오기
compute_type = "float32" #  "int8"
model = WhisperModel("medium", device=device, compute_type=compute_type)

def remove_silence(audio_path, output_path, threshold=20):
    # 오디오 파일 로드
    y, sr = librosa.load(audio_path, sr=None)

    # 음성의 에너지를 기반으로 무음 감지
    intervals = librosa.effects.split(y, top_db=threshold)

    # 무음 제거 후 오디오 합치기
    y_trimmed = np.concatenate([y[start:end] for start, end in intervals])

    # 새로운 파일 저장
    sf.write(output_path, y_trimmed, sr)
    print(f"무음 제거 완료! 새로운 파일 저장: {output_path}")

def save_transcription_to_txt(segments, transcription_file):

    full_text = " ".join(segment.text for segment in segments)
    #full_text = f"[{segment.start:.2f}s - {segment.end:.2f}s]: {segment.text}\n"

    with open(transcription_file, "w", encoding="utf-8") as f:
        f.write(full_text + "\n")
        f.flush()
        os.fsync(f.fileno())

    print(f"✅ 텍스트 변환 완료! '{transcription_file}'에 저장되었습니다.")

def read_text_from_file(file_path):
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            text = f.read().strip()  # 파일에서 텍스트 읽기
        return text
    except FileNotFoundError:
        print(f"❌ 오류: '{file_path}' 파일을 찾을 수 없습니다.")
        return None
    except Exception as e:
        print(f"❌ 파일 읽기 중 오류 발생: {e}")
        return None

def refine_text(text):
    if not text:
        print("❌ 오류: 입력된 텍스트가 없습니다.")
        return None

    print("3. GPT-4o-mini로 문장 다듬기 시작... (API 호출 5회)")

    prompt = f"{text}\n\n 문맥을 파악해 자연스럽게 바꿔줘:"

    try:
        response = openai.ChatCompletion.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.6
        )

        refined_text = response["choices"][0]["message"]["content"].strip()
        
        if not refined_text:
            print("⚠️ 경고: OpenAI API가 빈 응답을 반환했습니다.")
            return None
        
        try:
            with open(refined_file, "w", encoding="utf-8") as f:
                f.write(refined_text)
            print(f"✅ '{refined_file}' 파일로 다듬어진 텍스트 저장 완료!")

        except Exception as e:
            print(f"❌ 파일 저장 중 오류 발생: {e}")

    except Exception as e:
        print(f"❌ OpenAI API 요청 중 오류 발생: {e}")
        return None


input_audio = "interview1.wav"  # 원본 오디오 파일
output_audio = "interview1.wav"  # 무음 제거 후 저장될 파일
transcription_file = "interview1.txt"
refined_file = "interview1_4omini.txt"


# 무음 제거 실행
# remove_silence(input_audio, output_audio)


# 음성 파일 변환 실행 (파일 존재 여부 확인)
'''
if os.path.exists(output_audio):
    print("음성 변환 시작...")
    # 음성 파일 변환
    segments, _ = model.transcribe(output_audio)

    if not segments:
        print("번역된 텍스트가 없습니다.")
    else:
        # 결과 출력하는 코드 추가하기

        save_transcription_to_txt(segments, transcription_file)
else:
    print("오류: 변환된 오디오 파일이 존재하지 않아 텍스트 변환을 수행할 수 없습니다!")
'''

text = read_text_from_file(transcription_file)
refine_text(text)
    