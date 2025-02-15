from sqlalchemy import Column, Integer, String, DateTime
from database import Base
from sqlalchemy.orm import Session

class ForeignUserInfo(Base):
    __tablename__ = "foreign_user_info"

    id = Column(String, primary_key=True, index=True, unique=True)  
    email = Column(String, unique=True, index=True)
    password = Column(String)
    name = Column(String)
    phonenumber = Column(String)
    birthday = Column(DateTime)
    age = Column(Integer)
    sex = Column(String)
    startdate = Column(DateTime)
    enddate = Column(DateTime)
    region = Column(String)
    spot = Column(String)
    height = Column(Integer)
    weight = Column(Integer)
    symptoms = Column(String)
    canwalkpatient = Column(String)
    prefersex = Column(String)
    smoking = Column(String)

    @classmethod
    def foreign_generate_custom_id(cls, db: Session):
        last_entry = db.query(ForeignUserInfo).order_by(ForeignUserInfo.id.desc()).first()
        if last_entry:
            last_number = int(last_entry.id.split("_")[1])
            new_id = f"c_{last_number + 1}"
        else:
            new_id = "c_1"

        return new_id

class ProtectorUserInfo(Base):
    __tablename__ = "protector_user_info"

    id = Column(String, primary_key=True, index=True, unique=True)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    name = Column(String)
    phonenumber = Column(String)
    birthday = Column(DateTime)
    sex = Column(String)


    
    @classmethod
    def protector_generate_custom_id(cls, db: Session):
        last_entry = db.query(ProtectorUserInfo).order_by(ProtectorUserInfo.id.desc()).first()
        if last_entry:
            last_number = int(last_entry.id.split("_")[1])
            new_id = f"p_{last_number + 1}"
        else:
            new_id = "p_1"

        return new_id
    

class PatientUserInfo(Base):
    __tablename__ = "patient_user_info"

    id = Column(String, primary_key=True, index=True, unique=True)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    name = Column(String)
    phonenumber = Column(String)
    birthday = Column(DateTime)
    sex = Column(String)


    
    @classmethod
    def protector_generate_custom_id(cls, db: Session):
        last_entry = db.query(ProtectorUserInfo).order_by(ProtectorUserInfo.id.desc()).first()
        if last_entry:
            last_number = int(last_entry.id.split("_")[1])
            new_id = f"p_{last_number + 1}"
        else:
            new_id = "p_1"

        return new_id