import openai
import streamlit as st



OPENAI_API_KEY = ""
OPENAI_API_VERSION = ""
OPENAI_API_TYPE = ""
OPENAI_ENDPOINT = ""

MODEL_NAME = ""

openai.api_key = OPENAI_API_KEY
openai.api_type = OPENAI_API_TYPE
openai.api_version = OPENAI_API_VERSION
openai.azure_endpoint = OPENAI_ENDPOINT

query = st.text_input("궁금한걸 물어보세요!: ")

button_click = st.button("질문")
if(button_click):
    response = openai.chat.completions.create(
                    model=MODEL_NAME,
                    messages = [
                        {"role":"system", "content": "Your are a helpful assistant"},
                        {"role":"user", "content": query},
                    ]
                )

    st.write(response.choices[0].message.content)