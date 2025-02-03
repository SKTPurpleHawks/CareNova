import openai
import streamlit as st



OPENAI_API_KEY = "61INBgCt2yzYb08p7eX6FkL6bH3A62m5Spn0CO6A3ULFeKODoJLpJQQJ99BBACfhMk5XJ3w3AAAAACOGfY3p"
OPENAI_API_VERSION = "2023-05-15"
OPENAI_API_TYPE = "azure"
OPENAI_ENDPOINT = "https://labuser25-aiservice-001.openai.azure.com"

MODEL_NAME = "gpt-4o-mini"

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