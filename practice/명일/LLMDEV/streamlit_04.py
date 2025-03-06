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

name = st.text_input("이름을 입력하세요 : ")
academy = st.text_area("최종학력을 입력하세요 : ")
career = st.text_area("경력을 입력하세요 : ")
license = st.text_area("자격증 및 수상경력을 입력하세요 : ")


button_click = st.button("이력서 생성")

if(button_click):
    with st.spinner('Wait for it...'):
        response = openai.chat.completions.create(
                        model=MODEL_NAME,
                        temperature = 0.2,
                        messages = [
                            {"role":"system", "content": "너는 이제부터 이력서를 써주는 전문가야"},
                            {"role":"user", "content": "이름은 " + name},
                            {"role":"user", "content": "최종학력은 " + academy},
                            {"role":"user", "content": "경력은" + career},
                            {"role":"user", "content": "자격증 및 수상경력은" + license},
                            {"role":"user", "content": "이력서를 작성해줘"},
                        ]
                    )

        st.write(response.choices[0].message.content)

        st.success("Done!")