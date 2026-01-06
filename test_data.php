<?php

// ================= DATABASE CONFIG =================
$servername = "localhost";
$username   = "root";       // change if needed
$password   = "";           // change if needed
$dbname     = "iot_db";     // your database name

// ================= CONNECT =================
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Database Connection Failed: " . $conn->connect_error);
}

// ================= GET POST DATA =================
$temperature = $_POST['temperature'] ?? null;
$humidity    = $_POST['humidity'] ?? null;
$ph          = $_POST['ph'] ?? null;
$rainfall    = $_POST['rainfall'] ?? null;
$nitrogen    = $_POST['nitrogen'] ?? null;
$phosphorus  = $_POST['phosphorus'] ?? null;
$potassium   = $_POST['potassium'] ?? null;

// ================= VALIDATION =================
if (
    $temperature === null || $humidity === null || $ph === null ||
    $rainfall === null || $nitrogen === null ||
    $phosphorus === null || $potassium === null
) {
    echo "Missing Data";
    exit;
}

// ================= INSERT QUERY =================
$sql = "INSERT INTO sensor_data
        (temperature, humidity, ph, rainfall, nitrogen, phosphorus, potassium)
        VALUES (?, ?, ?, ?, ?, ?, ?)";

$stmt = $conn->prepare($sql);
$stmt->bind_param(
    "ddddiii",
    $temperature,
    $humidity,
    $ph,
    $rainfall,
    $nitrogen,
    $phosphorus,
    $potassium
);

// ================= EXECUTE =================
if ($stmt->execute()) {
    echo "Data Inserted Successfully";
} else {
    echo "Insert Failed: " . $stmt->error;
}

// ================= CLOSE =================
$stmt->close();
$conn->close();

?>
