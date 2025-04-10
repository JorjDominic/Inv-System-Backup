<?php
session_start();
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

require 'config/database.php';

$login_error = '';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = htmlspecialchars(trim($_POST['username']));  // Trim username input
    $password = trim($_POST['password']); 
    
    // Prepare the query to fetch the user data
    $stmt = $conn->prepare("SELECT * FROM Users WHERE Username = ?");
    $stmt->execute([$username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

  
    // Check if the user exists
    if (!$user) {
        // Log error and alert the user that the username doesn't exist
        error_log("Login failed: Username '$username' not found.");
        echo '<script>alert("Invalid username or password!"); window.location.href="index.php";</script>';
        exit;
    }

    // If the username exists, check if the password matches
    if (password_verify($password, $user['Password'])) {
        $_SESSION['user_id'] = $user['UserID'];
        $_SESSION['user_name'] = $user['Username'];
        $_SESSION['role'] = $user['RoleID'];

        // Redirect based on RoleID
        if ($user['RoleID'] == 1) {
            header('Location: owner_dashboard.php');
            exit;
        } elseif ($user['RoleID'] == 2) {
            header('Location: devdashboard.php');
            exit;
        } elseif ($user['RoleID'] == 3) {
            header('Location: cashierdashboard.php');
            exit;
        } elseif ($user['RoleID'] == 4) {
            header('Location: staff_dashboard.php');
            exit;
        } else {
            echo "No dashboard assigned for your role.";
        }
    } else {
        // If password does not match, log the issue and alert the user
        error_log("Login failed: Incorrect password for username '$username'.");
        echo '<script>alert("Invalid username or password!"); window.location.href="index.php";</script>';
        exit;
    }
}
?>
