from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List

class ForeignUserCreate(BaseModel):
    email: str
    password: str
    name: str
    phonenumber: str
    birthday: datetime
    age: int
    sex: str
    startdate: datetime
    enddate: datetime
    region: str
    spot: str
    height: int
    weight: int
    symptoms: str
    canwalkpatient: str
    prefersex: str
    smoking: str
    showyn: int

class ProtectorUserCreate(BaseModel):
    email: str
    password: str
    name: str
    phonenumber: str
    birthday: datetime
    sex: str

class UserLogin(BaseModel):
    email: str
    password: str

class UserUpdate(BaseModel):
    email: str
    new_password: Optional[str] = None
    name: str
    phonenumber: str
    birthday: datetime
    age: int
    sex: str
    startdate: datetime
    enddate: datetime
    region: str
    spot: str
    height: int
    weight: int
    symptoms: str
    canwalkpatient: str
    prefersex: str
    smoking: str

class PatientBase(BaseModel):
    name: str
    birthday: datetime
    age: int
    sex: str
    height: int
    weight: int
    symptoms: str
    canwalk: str
    prefersex: str
    smoking: str


class PatientResponse(PatientBase):
    id: str
    protector_id: str

    class Config:
        from_attributes = True


class JobInfoUpdate(BaseModel):
    showyn: int

class CareRequestCreate(BaseModel):
    caregiver_id: str 
    patient_id: str 
 

class CareRequestUpdate(BaseModel):
    status: str  

class PatientAssignmentCreate(BaseModel):
    caregiver_id: str
    patient_id: str
    
    
class ReviewCreate(BaseModel):
    caregiver_id: str
    protector_id: str
    sincerity: float
    hygiene: float
    communication: float
    total_score: float
    review_content: Optional[str] = None  # 선택적 리뷰 내용


class DailyRecordBase(BaseModel):
    caregiver_id: int
    protector_id: int
    patient_id: int
    location: str
    mood: str
    sleep_quality: str
    breakfast_type: Optional[str] = None
    breakfast_amount: Optional[float] = None
    lunch_type: Optional[str] = None
    lunch_amount: Optional[float] = None
    dinner_type: Optional[str] = None
    dinner_amount: Optional[float] = None
    urine_amount: Optional[str] = None
    urine_color: Optional[str] = None
    urine_smell: Optional[str] = None
    urine_foam: Optional[bool] = False
    stool_amount: Optional[str] = None
    stool_condition: Optional[str] = None
    position_change: Optional[bool] = False
    wheelchair_transfer: Optional[bool] = False
    walking_assistance: Optional[bool] = False
    outdoor_walk: Optional[bool] = False
    notes: Optional[str] = None

class DailyRecordCreate(DailyRecordBase):
    caregiver_id: int
    protector_id: int
    patient_id: int

class DailyRecordResponse(DailyRecordBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True