from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# SQLALCHEMY_DATABASE_URL = "sqlite:///./sql_app.db"
# PostgreSQL을 사용하려면 아래 줄의 주석을 해제하고 위의 줄을 주석 처리하세요
DATABASE_URL = "postgresql://hoit:passion2@0.0.0.0:5432/carenova"

#sqlite 쓸때때
# engine = create_engine(
#     SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
# )

# postgresql 쓸때
engine = create_engine(DATABASE_URL) # SQLite를 사용하지 않는 경우 connect_args={"check_same_thread": False}를 제거하세요

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
