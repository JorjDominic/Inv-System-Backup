<?php
session_start();

header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

if (!isset($_SESSION['user_id']) || $_SESSION['role'] != 2) {
    header('Location: index.php');
    exit;
}
session_regenerate_id(true);
?>
<!DOCTYPE html>
<html>
<head><title>Developer Dashboard</title></head>
<body>
<h1>Developer Dashboard</h1>
<h2>Welcome, <?= htmlspecialchars($_SESSION['user_name']) ?></h2>
<a href="user_profile.php">Update Profile</a>
<a href="logout.php">Logout</a>

</body>
</html>
