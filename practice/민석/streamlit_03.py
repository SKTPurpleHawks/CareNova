import openai
import streamlit as st
from dotenv import load_dotenv
import os

load_dotenv()

openai.api_key = os.getenv("OPENAI_API_KEY")
openai.api_type = os.getenv("OPENAI_API_TYPE")
openai.api_version = os.getenv("OPENAI_API_VERSION")
openai.azure_endpoint = os.getenv("OPENAI_ENDPOINT")

MODEL_NAME = os.getenv("MODEL_NAME")

subject = st.text_input("시의 주제를 입력하세요 : ")
content = st.text_area('시의 내용을 입력하세요: ')

button_click = st.button("작문")

if(button_click):
    with st.spinner('wait for it...'):
        response = openai.chat.completions.create(
                    model = MODEL_NAME,
                    temperature= 1,
                    messages = [
                        {"role":"system", "content":"너는 이제부터 감성적인 시인이야."},
                        {"role": "user", "content": "시의 제목은 " + subject},
                        {"role": "user", "content": "시의 내용은 " + content},
                        {"role": "user", "content": "시의 지어줘 "}
                    ]
                )

        st.write(response.choices[0].message.content)

        st.success("Done!5")