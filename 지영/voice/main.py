import torch
import os
import librosa
import numpy as np
import soundfile as sf
from faster_whisper import WhisperModel
import ctranslate2
from transformers import AutoTokenizer, AutoModelForCausalLM

os.environ["CUDA_LAUNCH_BLOCKING"] = "1"

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

# huggingface-cli login
# GPT 기반 문장 다듬기 모델 불러오기
gpt_model_name = "distilbert/distilgpt2" 
gpt_tokenizer = AutoTokenizer.from_pretrained(gpt_model_name)
gpt_model = AutoModelForCausalLM.from_pretrained(gpt_model_name, max_memory={0: "3GB"}).to(device)



def refine_text(text):
    """입력된 텍스트를 GPT 모델을 사용하여 더 자연스럽게 변환"""
    if not text:
        print("❌ 오류: 입력된 텍스트가 없습니다.")
        return None

    prompt = f"다음 문장을 더 자연스럽게 수정해 주세요:\n{text}\n\n자연스러운 문장:"

    # 🔹 패딩 토큰이 없으면 설정 (GPT-2는 기본적으로 pad_token이 없음)
    if gpt_tokenizer.pad_token is None:
        gpt_tokenizer.add_special_tokens({'pad_token': '[PAD]'})  # '[PAD]' 토큰 추가
        gpt_tokenizer.pad_token = gpt_tokenizer.eos_token  # 패딩을 EOS 토큰으로 설정

    if gpt_tokenizer.pad_token_id is None:
        gpt_tokenizer.pad_token_id = gpt_tokenizer.eos_token_id  # 패딩을 EOS 토큰으로 설정

    # 🔹 padding을 활성화하여 input_ids를 얻음
    encoded_inputs = gpt_tokenizer(prompt, return_tensors="pt", padding=True, truncation=True, max_length=512)
    input_ids = encoded_inputs.input_ids.to(device)
    attention_mask = encoded_inputs.attention_mask.to(device)

    output = gpt_model.generate(
        input_ids,
        attention_mask=attention_mask,
        max_new_tokens=100,  # 🔹 새로 생성할 최대 토큰 개수 설정
        do_sample=True,
        temperature=0.7,
        top_p=0.9,
        pad_token_id=gpt_tokenizer.pad_token_id  # 패딩 토큰 명확히 지정
    )

    refined_text = gpt_tokenizer.decode(output[0], skip_special_tokens=True)
    return refined_text



'''
def refine_text(text):
    prompt = f"다음 문장을 더 자연스럽게 수정해 주세요:\n{text}\n\n자연스러운 문장:"  
    input_ids = gpt_tokenizer(prompt, return_tensors="pt").input_ids.to(device)
    if gpt_tokenizer.pad_token_id is None:
        gpt_tokenizer.pad_token_id = gpt_tokenizer.eos_token_id
    attention_mask = (input_ids != gpt_tokenizer.pad_token_id).long().to(device)
    output = gpt_model.generate(input_ids, max_length=1024, temperature=0.7, pad_token_id=gpt_tokenizer)
    refined_text = gpt_tokenizer.decode(output[0], skip_special_tokens=True)
    return refined_text
'''

input_audio = "interview1.wav"  # 원본 오디오 파일
output_audio = "interview1.wav"  # 무음 제거 후 저장될 파일
transcription_file = "interview1.txt"
refined_file = "interview1_r.txt"


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

def read_text_from_file(file_path):
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            text = f.read().strip()  # 파일에서 텍스트 읽기
        return text
    except FileNotFoundError:
        print(f"❌ 오류: '{file_path}' 파일을 찾을 수 없습니다.")
        return None

text = read_text_from_file(transcription_file)
refine_text(text)

with open(refined_file, "w", encoding="utf-8") as f:
    f.write(refined_file)