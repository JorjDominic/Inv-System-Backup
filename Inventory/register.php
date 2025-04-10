<?php
require 'config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Sanitize and get input values
    $username   = htmlspecialchars(trim($_POST['username']));
    $firstname  = htmlspecialchars(trim($_POST['firstname']));
    $lastname   = htmlspecialchars(trim($_POST['lastname']));
    $email      = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL); // if you’ll use email later
    $phone      = htmlspecialchars(trim($_POST['phone']));
    $password = $_POST['regpassword'];
   
    $check = $conn->prepare("SELECT UserID FROM Users WHERE Username = ? OR Email = ?");
    $check->execute([$username, $email]);
    if ($check->rowCount() > 0) {
        echo '<script>alert("Username already exists, Please make another one!"); window.location.href="index.php#registerForm";</script>';
    }
    
    $stmt = $conn->prepare("SELECT UserID FROM Users WHERE Username = ?");
    $stmt->execute([$username]);
    if ($stmt->rowCount() > 0) {
        echo '<script>alert("Email is already used, Please use another one!"); window.location.href="index.php#registerForm";</script>';
    }

    $stmt = $conn->prepare("SELECT UserID FROM Users WHERE PhoneNumber = ?");
    $stmt->execute([$phone]);
    if ($stmt->rowCount() > 0) {
        echo '<script>alert("Number is already used, Please use another one!"); window.location.href="index.php#registerForm";</script>';
    }
    
    // Check if the password is empty or too short
    if (empty($password) || strlen($password) < 8) {
        echo '<script>alert("Password too short or empty!"); window.location.href="index.php";</script>';
        return; // Stop further processing
    }
 
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    try {
        // Prepare SQL to insert user
        $stmt = $conn->prepare("INSERT INTO Users (Username, Email, Password, FirstName, LastName, PhoneNumber)
        VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->execute([$username, $email, $hashedPassword, $firstname, $lastname, $phone]);

        echo '<script>alert("Registration Successful"); window.location.href="index.php";</script>';
    } catch (PDOException $e) {
        echo "Registration failed: " . $e->getMessage();
    }
}
?>