from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from database import Base
from sqlalchemy.orm import Session, relationship

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
    showyn = Column(Integer)

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

    patients = relationship("PatientUserInfo", back_populates="protector")
    
    @classmethod
    def protector_generate_custom_id(cls, db: Session):
        last_entry = db.query(ProtectorUserInfo).order_by(ProtectorUserInfo.id.desc()).first()
        if last_entry:
            last_number = int(last_entry.id.split("_")[1])
            new_id = f"g_{last_number + 1}"
        else:
            new_id = "g_1"

        return new_id
    

class PatientUserInfo(Base):
    __tablename__ = "patient_user_info"

    id = Column(String, primary_key=True, index=True, unique=True)
    protector_id = Column(String, ForeignKey("protector_user_info.id"))  # Foreign Key 추가
    name = Column(String)
    birthday = Column(DateTime)
    age = Column(String)
    sex = Column(String)
    height = Column(String)
    weight = Column(String)
    symptoms = Column(String)
    canwalk = Column(String)
    prefersex = Column(String)
    smoking = Column(String)

    protector = relationship("ProtectorUserInfo", back_populates="patients")
    
    @classmethod
    def patient_generate_custom_id(cls, db: Session):
        last_entry = db.query(PatientUserInfo).order_by(PatientUserInfo.id.desc()).first()
        if last_entry:
            last_number = int(last_entry.id.split("_")[1])
            new_id = f"p_{last_number + 1}"
        else:
            new_id = "p_1"

        return new_id

        