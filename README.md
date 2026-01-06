# 🌱 IoT-based Crop Recommendation System using Machine Learning via Mobile Application for Precision Agriculture in Bangladesh

## 📌 Project Overview
This project implements an **IoT-based smart agriculture system** that collects real-time soil and environmental data and sends it to a database using WiFi. The system measures **NPK (Nitrogen, Phosphorus, Potassium)**, **temperature**, **humidity**, **soil pH**, and **rainfall**, which are critical parameters for precision agriculture and crop recommendation systems.

---

## 🎯 Objectives
- Monitor real-time soil nutrients (NPK)
- Measure environmental parameters (temperature, humidity, pH, rainfall)
- Transmit sensor data to a remote database via WiFi (HTTP POST)
- Store data for analysis and machine learning
- Support precision agriculture applications

---

## 🛠️ Hardware Components
- ESP32 Development Board  
- NPK Soil Sensor (RS485 / Modbus)  
- DHT11 / DHT22 Sensor (Temperature & Humidity)  
- Analog pH Sensor  
- Rainfall Sensor  
- RS485 to TTL Converter  
- Jumper wires & power supply  

---

## 💻 Software & Technologies
- Arduino IDE  
- ESP32 WiFi Library  
- HTTPClient  
- PHP  
- MySQL  
- XAMPP / Apache Server  

---

## 🧩 System Architecture
Soil & Environmental Sensors
(NPK, pH, DHT, Rain)
↓
ESP32
↓ (WiFi – HTTP POST)
PHP API
↓
MySQL Database
↓
Analysis / ML Model
---

## 📊 Parameters Collected
| Parameter | Unit |
|---------|------|
| Temperature | °C |
| Humidity | % |
| pH | pH scale |
| Rainfall | % |
| Nitrogen | mg/kg |
| Phosphorus | mg/kg |
| Potassium | mg/kg |

---


## 🔌 How to Run the Project

### 1️⃣ ESP32 Setup
- Open the `.ino` file in Arduino IDE  
- Select **ESP32 board**
- Update WiFi SSID & password
- Upload the code to ESP32

### 2️⃣ Server Setup
- Install **XAMPP**
- Place `test_data.php` inside:
htdocs/dht11_project/

pgsql
Copy code
- Start Apache & MySQL



flowchart LR
    subgraph Field["🌾 Agricultural Field"]
        DHT["DHT11 Sensor\n(Temp & Humidity)"]
        PH["pH Sensor"]
        Rain["Rain Sensor"]
        NPK["NPK Sensor\n(RS485 / Modbus)"]
    end

    subgraph Controller["📟 ESP32 Controller"]
        ESP["ESP32\nWiFi Enabled"]
    end

    subgraph Network["🌐 Network"]
        WiFi["WiFi Router"]
    end

    subgraph Server["🖥 Backend Server"]
        PHP["PHP API\n(test_data.php)"]
        DB["MySQL Database"]
    end

    subgraph User["👨‍🌾 User Interface"]
        Dashboard["Web Dashboard\n(Graphs & Logs)"]
    end

    DHT --> ESP
    PH --> ESP
    Rain --> ESP
    NPK --> ESP

    ESP -->|HTTP POST| WiFi
    WiFi --> PHP
    PHP --> DB
    DB --> Dashboard


humidity
ph
rainfall
nitrogen
phosphorus
potassium
