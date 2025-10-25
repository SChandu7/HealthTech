# 🏥 HealthTech – QR-Based Medical History Application

## 📖 Overview
**HealthTech** is a digital platform that allows **patients and doctors** to access, update, and share **medical history securely** using **QR codes**. The system ensures **secure, fast, and paperless medical record management**, enabling doctors to quickly retrieve patient information and patients to maintain a personal digital health record.

---

## 🎯 Problem Statement
Traditional medical record systems face several challenges:  
- Patients often **lose physical medical documents**.  
- Doctors spend time **manually retrieving records**.  
- Medical histories are **fragmented across multiple clinics**.  
- Privacy and security concerns are high with paper records.

**HealthTech** solves these problems by:  
- Centralizing medical history digitally.  
- Using **QR codes** for instant access.  
- Providing secure and authenticated access for doctors.  
- Allowing patients to **manage their own health records**.

---

## ⚙️ Tech Stack

| Component | Technology Used |
|------------|-----------------|
| **Frontend** | Flutter |
| **Backend** | Django REST Framework |
| **Database** | MySQL |
| **Hosting** | AWS |
| **APIs** | REST APIs |
| **Authentication** | JWT-based login/signup |
| **QR Code Generation** | Python `qrcode` library / Flutter QR package |

---

## 💡 Key Features

### 🧑‍⚕️ Doctor Features
- Secure login and access to patient records.  
- Scan patient QR codes to instantly retrieve **medical history**.  
- Update patient history with prescriptions, test results, and notes.  
- View **appointment history** and notifications.  

### 🧑‍🤝‍🧑 Patient Features
- Register and maintain personal medical history.  
- Generate a **QR code** representing their health record.  
- Share QR code securely with doctors.  
- Receive notifications for appointments and test results.  

### 🧑‍💼 Admin Panel
- Manage doctors and patient accounts.  
- Monitor system usage and data integrity.  
- Generate reports for hospital or clinic use.

---

## 🧩 System Architecture
```
Patient App (Flutter)
        │
        ▼
QR Code Generation / Scanner
        │
        ▼
Django REST API (Backend)
        │
        ▼
MySQL Database (Data Storage)
        │
        ▼
AWS Cloud Server (Hosting)
```

---

## 🧠 Working Procedure

### 1. Patient Registration
- Patient signs up via Flutter app.  
- Profile includes personal details, medical history, and emergency contacts.  
- Patient generates a unique **QR code** linking to their medical history.

### 2. Doctor Access
- Doctor logs in via Flutter app.  
- Scans the patient QR code using camera/QR scanner widget.  
- Backend validates QR and retrieves **medical records securely**.

### 3. Record Updates
- Doctors can update patient history:  
  - Test results  
  - Prescriptions  
  - Observations  
- Updates are saved in **MySQL database** and reflected in patient records.

### 4. Notifications
- Patients receive notifications for new updates, test results, or appointments.  
- Doctors receive alerts for new patient QR scans or upcoming appointments.

---

## 📲 QR Code Workflow
```
Patient Generates QR → Doctor Scans QR → Backend Validates → Retrieves Medical Data → Display on App
```
- QR codes contain **encrypted patient ID** to ensure privacy.  
- Only authorized doctors can access full medical history.

---

## 📸 Screenshots
Homepage
<img width="1122" height="700" alt="image" src="https://github.com/user-attachments/assets/ba3fb281-16af-4c9e-9c22-0fec99e4cd43" />

Doctor dashbaord 
<img width="1026" height="691" alt="image" src="https://github.com/user-attachments/assets/80271798-e955-4342-93e6-fdba108d1da3" />

Patient Dashboard
<img width="1237" height="683" alt="image" src="https://github.com/user-attachments/assets/1ec38053-5842-4b5c-a3fb-453afedaa676" />






## 💻 Setup Instructions

### 🧱 Backend (Django)
**Clone the repository:**
```bash
git clone https://github.com/<your-username>/healthtech-qr.git
cd healthtech-qr/backend
```

**Create virtual environment:**
```bash
python -m venv env
source env/bin/activate   # On Windows: env\Scripts\activate
```

**Install dependencies:**
```bash
pip install -r requirements.txt
```

**Run migrations:**
```bash
python manage.py migrate
```

**Start server:**
```bash
python manage.py runserver
```

---

### 📱 Frontend (Flutter)
**Go to the Flutter directory:**
```bash
cd healthtech-qr/flutter_app
```

**Install dependencies:**
```bash
flutter pub get
```

**Update API base URL in config file:**
```dart
const String baseUrl = "http://your-aws-server-ip/api/";
```

**Run the app:**
```bash
flutter run
```

---

## 🧾 Example Data Format

| Patient ID | Name | Age | Blood Group | Medical History | QR Code URL |
|------------|------|-----|------------|----------------|------------|
| P001 | John Doe | 30 | B+ | Allergy: Penicillin, Previous Surgery: Appendix | https://cloudserver.com/qr/P001 |
| P002 | Mary Jane | 25 | O- | Diabetes Type 2, Medication: Insulin | https://cloudserver.com/qr/P002 |

---

## 🚀 Future Enhancements
- AI-based health risk prediction from history.  
- Integration with wearable health devices.  
- Offline QR scanning with local encrypted storage.  
- Multilingual support for global accessibility.  
- Integration with government health databases.

---

## 👨‍💻 Contributors
| Name | Role | Description |
|------|------|-------------|
| **S. Chandu** | Developer & Project Lead | Designed and developed Flutter + Django app, implemented QR code system, and handled AWS deployment. |

---

## 📄 License
This project is licensed under the **MIT License** – see [LICENSE](LICENSE) file for details.

---

## 🧠 Keywords
Flutter, Django, QR Code, HealthTech, Medical History, Doctor, Patient, Cloud Database, Secure Records, IoT, Mobile App

