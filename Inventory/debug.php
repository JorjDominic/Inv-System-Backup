<?php
// Sample password that would be "entered" by the user during registration
$registrationPassword = 'a';  // Replace this with any password for testing

// Hash the password using password_hash()
$hashedPassword = password_hash($registrationPassword, PASSWORD_DEFAULT);

// Simulating the login process, where the user enters their password to login
$loginPassword = 'yourPassword123';  // This should be the password entered by the user during login

echo "<h3>Testing Password Hashing and Verification</h3>";

// Display the password and the generated hash for comparison
echo "Original Password: " . $registrationPassword . "<br>";
echo "Hashed Password: " . $hashedPassword . "<br><br>";

// Now, let's simulate password verification during login
if (password_verify($loginPassword, $hashedPassword)) {
    echo "Password is valid! Login successful.<br>";
} else {
    echo "Invalid password! Login failed.<br>";
}

// Debugging output to show if password_verify is working as expected
echo "<h3>Debugging password_verify()</h3>";
var_dump(password_verify($loginPassword, $hashedPassword));  // Show the result of password verification

?>
