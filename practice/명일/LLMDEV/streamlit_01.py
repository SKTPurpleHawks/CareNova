import streamlit as st

st.header("GPT Demo")

st.write("에스파의 리더는 누구인가")

name = st.text_input("리더의 이름은?","카리나")

if(name):
    st.write("빚이 10억있는 카리나 vs 100억 자산가 박나래")
    wife = st.text_input("내 배우자","박나래?")

    button_click = st.button("결과보기")
    if button_click:
        if(wife == "카리나"):
            st.write("몸은 힘들어도 행복한 길을 선택하셨네요.")
        else:
            st.write("마음은 힘들어도 편한 길을 선택하셨네요.")

data = [10, 20, 30]

st.write("Bar Chart")
st.bar_chart(data)