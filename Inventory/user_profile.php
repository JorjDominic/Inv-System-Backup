<?php
session_start();
require 'config/database.php';



$userID = $_SESSION['user']['userID'];

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = trim($_POST['name']);
    $email = trim($_POST['email']);

    // Validate email
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $error = "Invalid email format.";
    } else {
        $stmt = $conn->prepare("UPDATE users SET name = ?, email = ? WHERE id = ?");
        $stmt->execute([$name, $email, $userID]);
        $success = "Profile updated successfully.";
    }
}

// Fetch current user data
$stmt = $conn->prepare("SELECT name, email FROM users WHERE id = ?");
$stmt->execute([$userID]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html>
<head>
    <title>Update Profile</title>
    <link rel="stylesheet" href="css/index.css"> <!-- Link to your main CSS -->
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(180deg, #A0D995 0%, #B8F2E6 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .profile-form {
            background: #fff;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 450px;
        }
        .profile-form h2 {
            text-align: center;
            color: #4a934a;
            margin-bottom: 1rem;
        }
        .profile-form input {
            width: 100%;
            padding: 0.75rem;
            margin-bottom: 1rem;
            border-radius: 8px;
            border: 1px solid #ccc;
        }
        .profile-form button {
            width: 100%;
            background: #4a934a;
            color: #fff;
            padding: 0.75rem;
            border: none;
            border-radius: 8px;
            cursor: pointer;
        }
        .profile-form .message {
            text-align: center;
            margin-bottom: 1rem;
            color: #4a934a;
        }
        .back-link {
            text-align: center;
            margin-top: 1rem;
        }
        .back-link a {
            color: #4a934a;
            text-decoration: none;
        }
        .back-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
<div class="profile-form">
    <h2>Update Profile</h2>

    <?php if (isset($error)) echo "<p class='message' style='color: red;'>$error</p>"; ?>
    <?php if (isset($success)) echo "<p class='message'>$success</p>"; ?>

    <form method="POST">
        <input type="text" name="name" value="<?= htmlspecialchars($user['name']) ?>" required>
        <input type="email" name="email" value="<?= htmlspecialchars($user['email']) ?>" required>
        <button type="submit">Update</button>
    </form>

    <div class="back-link">
        <a href="user_dashboard.php">← Back to Dashboard</a>
    </div>
</div>
</body>
</html>
