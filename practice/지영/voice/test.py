from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

device = "cuda" if torch.cuda.is_available() else "cpu"

# 로컬 모델 다운로드 및 로드
model_name = "distilbert/distilgpt2"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name).to(device)

def refine_text(text):
    """입력된 텍스트를 GPT 모델을 사용하여 더 자연스럽게 변환"""
    prompt = f"다음 문장을 더 자연스럽게 수정해 주세요:\n{text}\n\n자연스러운 문장:"

    input_ids = tokenizer(prompt, return_tensors="pt", padding=True, truncation=True, max_length=512).input_ids.to(device)

    output = model.generate(input_ids, max_new_tokens=100, do_sample=True, temperature=0.7, top_p=0.9, pad_token_id=tokenizer.eos_token_id)

    refined_text = tokenizer.decode(output[0], skip_special_tokens=True)
    return refined_text

def read_text_from_file(file_path):
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            text = f.read().strip()  # 파일에서 텍스트 읽기
        return text
    except FileNotFoundError:
        print(f"❌ 오류: '{file_path}' 파일을 찾을 수 없습니다.")
        return None

transcription_file = "interview1.txt"
refined_file = "interview1_r.txt"


text = read_text_from_file(transcription_file)
refine_text(text)

with open(refined_file, "w", encoding="utf-8") as f:
    f.write(refined_file)