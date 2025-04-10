<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] != 4) {
    header('Location: login.php');
    exit;
}
?>
<!DOCTYPE html>
<html>
<head><title>Staff Dashboard</title></head>
<body>
<h1>Staff Dashboard</h1>
<h2>Welcome, <?= htmlspecialchars($_SESSION['user_name']) ?></h2>
<a href="user_profile.php">Update Profile</a>
<a href="logout.php">Logout</a>
</body>
</html>
