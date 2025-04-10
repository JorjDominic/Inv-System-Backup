<?php
require 'config/database.php';
$alert = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Retrieve form data
    $email = strtolower(trim($_POST['email']));
    $code = trim($_POST['code']);
    $newPassword = trim($_POST['new_password']);  // Store the submitted password in a variable

    try {
        // Fetch the user matching email and reset code
        $stmt = $conn->prepare("SELECT * FROM Users WHERE Email = ? AND ResetCode = ?");
        $stmt->execute([$email, $code]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user) {
            // Invalid email or reset code
            $alert = 'Invalid email or reset code';
        } elseif (password_verify($newPassword, $user['Password'])) {
            // Check if the new password is the same as the old password
            $alert = 'New password cannot match current password';
        } else {
            // Hash the new password and update the user record
            $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT); // Use the new password here
            $conn->prepare("UPDATE Users SET Password = ?, ResetCode = NULL WHERE Email = ?")
                 ->execute([$hashedPassword, $email]);
            
            // Show success message and redirect to login
            echo '<script>alert("Password reset!"); window.location.href="index.php";</script>';
            exit();
        }
    } catch (PDOException $e) {
        // Handle any database errors
        $alert = 'System error - try again later';
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Reset Password</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="css/resetpass.css" rel="stylesheet">
</head>
<body>
    <div class="reset-box">
        <h2>Reset Password</h2>
        
        <?php if ($alert): ?>
            <script>alert("<?= addslashes($alert) ?>");</script>
        <?php endif; ?>

        <form method="POST">
            <input type="email" name="email" placeholder="Your Email" required>
            <input type="text" name="code" placeholder="Reset Code" required>
            <input type="password" name="new_password" placeholder="New Password (8+ characters)" required>
            <button type="submit">Reset Password</button>
        </form>

        <a href="index.php" class="back-link">← Back to Login</a>
    </div>

    <script>
        document.querySelector('form').addEventListener('submit', function(e) {
            const pw = document.querySelector('[name="new_password"]').value;
            if (pw.length < 8) {
                alert("Password must be at least 8 characters");
                e.preventDefault();
            }
        });
    </script>
</body>
</html>
