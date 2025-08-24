from fastapi import FastAPI, HTTPException, BackgroundTasks, Path
import secrets
import asyncio
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from fastapi.middleware.cors import CORSMiddleware
import MySQLdb
from pydantic import BaseModel
import bcrypt
import uvicorn
import joblib
from typing import List
from datetime import datetime  # Import datetime


db_config = {
    'host': 'localhost',
    'user': 'root',
    'passwd': '',
    'db': 'ums',
}

conn = MySQLdb.connect(**db_config)

app = FastAPI()

class User(BaseModel):
    username: str
    password: str
    email: str
    role: str

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Set this to the appropriate origin or "*" to allow all origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

async def remove_otp(email: str):
    await asyncio.sleep(300)  # Remove OTP after 5 minutes
    if email in otp_map:
        del otp_map[email]

otp_map = {}

def send_email(subject, message, to_email):
    try:
        # Set up the email server
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()

         # Replace 'YOUR_EMAIL_USERNAME' and 'YOUR_EMAIL_PASSWORD' with your actual email credentials
        email_username = '1901036@iot.bdu.ac.bd'
        email_password = 'nzboartwgppeczsj'
        
        server.login(email_username, email_password)

        # Create message
        
        msg = MIMEMultipart()
        msg['From'] = email_username
        msg['To'] = to_email
        msg['Subject'] = subject
        msg.attach(MIMEText(message, 'plain'))

        # Send the email
        server.sendmail(email_username, to_email, msg.as_string())
        print("Email sent successfully!")
    except smtplib.SMTPException as e:
        print(f"Failed to send email: {e}")
    finally:
        server.quit()

@app.post("/generate_otp/")
async def generate_otp(email: str):
    print(f"Received email: {email}")
    if '@' not in email or '.' not in email:
        raise HTTPException(status_code=400, detail="Invalid email format")

    otp = str(secrets.randbelow(900000) + 100000)  # Generate a 6-digit OTP
    otp_map[email] = otp
    asyncio.create_task(remove_otp(email))
    send_email("User Verification", f"Your OTP is: {otp}", email)
    print(f"OTP for {email} is: {otp}")
    return {"message": "OTP generated successfully."}

@app.post("/validate_otp/")
async def validate_otp(email: str, entered_otp: str):
    if email not in otp_map:
        raise HTTPException(status_code=404, detail="OTP not found for the given email.")
    
    stored_otp = otp_map[email]
    if stored_otp == entered_otp:
        del otp_map[email]
        print(f"OTP for {email} validated successfully.")
        return {"message": "OTP validated successfully."}
    else:
        print(f"OTP validation failed for {email}.")
        raise HTTPException(status_code=400, detail="Invalid OTP.")


@app.post("/users/")
def create_user(user: User):
    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
    cursor = conn.cursor()
    query = "INSERT INTO users (username, password, email, role) VALUES (%s, %s, %s, %s)"
    cursor.execute(query, (user.username, hashed_password, user.email, user.role))
    conn.commit()
    #user.id = cursor.lastrowid
    cursor.close()
    return {'msg': 'create successfull'}


@app.get("/getusers/{user_identifier}")
def read_user(user_identifier: str = Path(..., title="User ID or Username")):
    cursor = conn.cursor()
    query = "SELECT id, username, password, email, role FROM users WHERE id=%s OR username=%s"
    cursor.execute(query, (user_identifier, user_identifier))
    user = cursor.fetchone()
    cursor.close()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return {"id": user[0], "username": user[1], "password": user[2], "email": user[3], "role": user[4]}

# Route to read a user
@app.get("/getusers/{user_id}")
def read_user(user_id: int):
    cursor = conn.cursor()
    query = "SELECT id, username, password, email, role FROM users WHERE id=%s"
    cursor.execute(query, (user_id,))
    user = cursor.fetchone()
    cursor.close()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return {"id": user[0], "username": user[1], "password": user[2], "email": user[3], "role": user[4]}

# Route to update a user
@app.put("/updateusers/")
def update_user(user_id: int, user: User):
    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
    cursor = conn.cursor()
    query = "UPDATE users SET username=%s, password=%s, email=%s, role=%s WHERE id=%s"
    cursor.execute(query, (user.username, hashed_password, user.email, user.role, user_id))
    conn.commit()
    cursor.close()
    user.id = user_id
    return user

# Route to delete a user
@app.delete("/delusers/")
def delete_user(username: str):
    cursor = conn.cursor()
    query = "DELETE FROM users WHERE username=%s"
    cursor.execute(query, (username,))
    conn.commit()
    cursor.close()
    return {"deleted_username": username}

@app.post("/login/")
async def login(username: str, password: str):
    cursor = conn.cursor()
    query = "SELECT password FROM users WHERE username=%s"
    cursor.execute(query, (username,))
    result = cursor.fetchone()
    cursor.close()
    if result is None:
        raise HTTPException(status_code=401, detail="Invalid username or password")
    hashed_password = result[0]
    if bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8')):
        return {"message": "Login successful"}
    else:
        raise HTTPException(status_code=401, detail="Invalid username or password")


@app.get("/selectusers/")
def get_all_users():
    cursor = conn.cursor()
    cursor.execute("SELECT id,username, email,role FROM users")
    users = cursor.fetchall()
    cursor.close()
    return users

# Load the machine learning model
model = joblib.load("naive_bayes_classifier.pkl")
# Pydantic model for sensor data
class SensorData(BaseModel):
    Id: int
    N: float
    P: float
    K: float
    temp: float
    hum: float
    ph: float
    rain: float
    datetime: datetime

# Pydantic model for crop prediction request
class CropRequest(BaseModel):
    N: float
    P: float
    K: float
    temp: float
    hum: float
    ph: float
    rain: float

# Route to fetch latest sensor data
@app.get("/latest_sensor_data/", response_model=SensorData)
def get_latest_sensor_data():
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    query = "SELECT Id, N, P, K, temp, hum, ph, rain, datetime FROM crop ORDER BY Id DESC LIMIT 1"
    cursor.execute(query)
    sensor_data = cursor.fetchone()
    cursor.close()
    conn.close()
    if sensor_data is None:
        raise HTTPException(status_code=404, detail="No sensor data found")
    return {
        "Id": sensor_data[0],
        "N": sensor_data[1],
        "P": sensor_data[2],
        "K": sensor_data[3],
        "temp": sensor_data[4],
        "hum": sensor_data[5],
        "ph": sensor_data[6],
        "rain": sensor_data[7],
        "datetime": sensor_data[8]
    }

# Route to predict crop
@app.post('/predict_crop')
def predict_crop(data: CropRequest):
    # Extract input values
    N = data.N
    P = data.P
    K = data.K
    temp = data.temp
    hum = data.hum
    ph = data.ph
    rain = data.rain
    
    # Predict using the loaded machine learning model
    input_data = [[N, P, K, temp, hum, ph, rain]]
    prediction = model.predict(input_data)[0]
    
    return {'predicted_crop': prediction}

# Route to fetch real-time data
@app.get("/realtime_data/")
def get_realtime_data():
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()

    try:
        # Execute the query to fetch last 20 data points
        query = "SELECT N, P, K, temp, hum, ph, rain, datetime FROM crop ORDER BY Id DESC LIMIT 20"
        cursor.execute(query)
        
        # Fetch the data
        data = cursor.fetchall()
        
        if not data:
            raise HTTPException(status_code=404, detail="No monitoring data available")
        
        # Extract values from the fetched data
        fetched_data = []
        for row in data:
            N, P, K, temp, hum, ph, rain, timestamp = row
            fetched_data.append({
                "N": N,
                "P": P,
                "K": K,
                "temp": temp,
                "hum": hum,
                "ph": ph,
                "rain": rain,
                "datetime": timestamp
            })
        
        # Return the fetched data
        return fetched_data
    
    except Exception as e:
        # Handle any exceptions that occur during database access
        raise HTTPException(status_code=500, detail="Failed to fetch monitoring data") from e
    
    finally:
        # Close the database connection and cursor
        cursor.close()
        conn.close()


if __name__=="__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)