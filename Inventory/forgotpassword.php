<?php
require 'config/database.php';

// PHPMailer
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;
require 'PHPMailer/src/PHPMailer.php';
require 'PHPMailer/src/SMTP.php';
require 'PHPMailer/src/Exception.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = strtolower(trim($_POST['email']));

    // Check if user exists with that email
    $stmt = $conn->prepare("SELECT * FROM Users WHERE Email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        $code = rand(100000, 999999); // Generate reset code

        // Store code in DB
        $update = $conn->prepare("UPDATE Users SET ResetCode = ? WHERE Email = ?");
        $update->execute([$code, $email]);

        // Send email
        $mail = new PHPMailer(true);
        try {
            $mail->isSMTP();
            $mail->Host       = 'smtp.gmail.com';
            $mail->SMTPAuth   = true;
            $mail->Username   = 'b6664253@gmail.com';           // Your Gmail
            $mail->Password   = 'wbbkxuoxrvguckjj';             // App Password (no spaces)
            $mail->SMTPSecure = 'tls';
            $mail->Port       = 587;

            $mail->setFrom('b6664253@gmail.com', "Adriana's Marketing");
            $mail->addAddress($email);
            $mail->isHTML(true);
            $mail->Subject = "Reset your password - Adriana's Marketing";
            $mail->Body = "
                <p>Hi there,</p>
                <p>You requested a password reset at <strong>Adriana's Marketing</strong>.</p>
                <p>Your code is:</p>
                <h2>$code</h2>
                <p>Click below to reset:</p>
                <p><a href='http://localhost/php/Inventory/resetpassword.php'>Reset Password</a></p>
                <p>If you didn’t request this, ignore this email.</p>
                <p style='font-size:14px;'>– Adriana's Marketing</p>
            ";
            $mail->AltBody = "Your code is $code. Visit http://localhost/php/Inventory/resetpassword.php to reset.";

            $mail->send();
            echo "<script>
                alert('✅ A reset code has been sent to $email');
                window.location.href = 'forgotpassword.php';
            </script>";

        } catch (Exception $e) {
            echo "<p style='color: red;'>❌ Email sending failed: " . $mail->ErrorInfo . "</p>";
        }
    } else {
        
    }
}
?>

<!DOCTYPE html>
<html>
<head><title>Forgot Password</title></head>
<link rel="stylesheet" href="css/forgotpass.css">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<body>
    <div class="forgot-div">
        <img src="logo.jpg" class="logo" alt="Adriana's Marketing Logo">
        
        <h3>Forgot Password</h3>
        
        <?php if ($_SERVER['REQUEST_METHOD'] === 'POST') : ?>
            <?php if ($user) : ?>
                <div class="response-message success">
                    ✅ A reset code has been sent to <strong><?= htmlspecialchars($email) ?></strong>.
                </div>
                <p><a href="resetpassword.php">Continue to reset password</a></p>
            <?php else : ?>
                <div class="response-message error">
                    ❌ No account found with that email address.
                </div>
            <?php endif; ?>
        <?php endif; ?>
        
        <form method="POST">
            <input type="email" name="email" placeholder="Enter your email" required>
            <button type="submit">Send Reset Code</button>
        </form>
        
        <div class="back-to-login">
            <a href="index.php">← Back to Login</a>
        </div>
    </div>
</body>
</html>

