#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>
#include <SoftwareSerial.h>

/* ================= WIFI CONFIG ================= */
const char* ssid = "Shahriar";
const char* password = "upolfabi";
String serverURL = "http://172.17.113.83/dht11_project/test_data.php";

/* ================= DHT SENSOR ================= */
#define DHTPIN 4
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

/* ================= pH & RAIN ================= */
#define PH_PIN 34
#define RAIN_PIN 35

/* ================= NPK SENSOR ================= */
#define RE 2
#define DE 0
SoftwareSerial mod(14, 12); // RX, TX

const byte nitro[] = {0x01,0x03,0x00,0x1e,0x00,0x01,0xe4,0x0c};
const byte phos[]  = {0x01,0x03,0x00,0x1f,0x00,0x01,0xb5,0xcc};
const byte pota[]  = {0x01,0x03,0x00,0x20,0x00,0x01,0x85,0xc0};

byte values[11];

/* ================================================= */

void setup() {
  Serial.begin(115200);
  mod.begin(4800);

  pinMode(RE, OUTPUT);
  pinMode(DE, OUTPUT);

  dht.begin();
  connectWiFi();

  Serial.println("System Ready");
}

/* ================= MAIN LOOP ================= */
void loop() {

  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi();
  }

  /* ---- READ SENSORS ---- */
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();

  int ph_adc = analogRead(PH_PIN);
  float voltage = ph_adc * (3.3 / 4095.0);
  float ph_value = 3.3 * voltage;   // simple calibration

  int rain_adc = analogRead(RAIN_PIN);
  float rainfall = map(rain_adc, 0, 4095, 100, 0);

  byte nitrogen   = readNitrogen();
  delay(200);
  byte phosphorus = readPhosphorus();
  delay(200);
  byte potassium  = readPotassium();

  /* ---- PRINT VALUES ---- */
  Serial.println("----- Sensor Data -----");
  Serial.print("Temp: "); Serial.println(temperature);
  Serial.print("Humidity: "); Serial.println(humidity);
  Serial.print("pH: "); Serial.println(ph_value);
  Serial.print("Rainfall: "); Serial.println(rainfall);
  Serial.print("N: "); Serial.println(nitrogen);
  Serial.print("P: "); Serial.println(phosphorus);
  Serial.print("K: "); Serial.println(potassium);

  /* ---- SEND TO DATABASE ---- */
  sendToDatabase(temperature, humidity, ph_value, rainfall,
                 nitrogen, phosphorus, potassium);

  delay(10000); // send every 10 seconds
}

/* ================= SEND DATA ================= */
void sendToDatabase(float t, float h, float ph, float rain,
                    byte n, byte p, byte k) {

  HTTPClient http;

  String postData =
    "temperature=" + String(t) +
    "&humidity=" + String(h) +
    "&ph=" + String(ph) +
    "&rainfall=" + String(rain) +
    "&nitrogen=" + String(n) +
    "&phosphorus=" + String(p) +
    "&potassium=" + String(k);

  http.begin(serverURL);
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");

  int httpCode = http.POST(postData);
  String response = http.getString();

  Serial.print("HTTP Code: ");
  Serial.println(httpCode);
  Serial.print("Server Response: ");
  Serial.println(response);

  http.end();
}

/* ================= WIFI ================= */
void connectWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWiFi Connected");
  Serial.print("IP: ");
  Serial.println(WiFi.localIP());
}

/* ================= NPK FUNCTIONS ================= */
byte readNitrogen() {
  digitalWrite(DE, HIGH);
  digitalWrite(RE, HIGH);
  delay(10);

  mod.write(nitro, sizeof(nitro));
  digitalWrite(DE, LOW);
  digitalWrite(RE, LOW);

  for (byte i = 0; i < 7; i++) values[i] = mod.read();
  return values[4];
}

byte readPhosphorus() {
  digitalWrite(DE, HIGH);
  digitalWrite(RE, HIGH);
  delay(10);

  mod.write(phos, sizeof(phos));
  digitalWrite(DE, LOW);
  digitalWrite(RE, LOW);

  for (byte i = 0; i < 7; i++) values[i] = mod.read();
  return values[4];
}

byte readPotassium() {
  digitalWrite(DE, HIGH);
  digitalWrite(RE, HIGH);
  delay(10);

  mod.write(pota, sizeof(pota));
  digitalWrite(DE, LOW);
  digitalWrite(RE, LOW);

  for (byte i = 0; i < 7; i++) values[i] = mod.read();
  return values[4];
}
