<?php
$host = 'localhost';
$dbname = 'inventorydb';
$username = 'root';
$password = 'root';
try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username,
$password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Connection failed: " . $e->getMessage());
}
?>