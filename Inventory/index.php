
<!DOCTYPE html>
<html>
<head>
    <title>Login & Register</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/index.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        function showForm(formId) {
            const loginForm = document.getElementById("loginForm");
            const registerForm = document.getElementById("registerForm");
            const loginMsg = document.getElementById("loginMessage");
            const registerMsg = document.getElementById("registerMessage");

            if (formId === "loginForm") {
                loginForm.style.display = "block";
                registerForm.style.display = "none";
                loginMsg.style.display = "block";
                registerMsg.style.display = "none";
            } else {
                loginForm.style.display = "none";
                registerForm.style.display = "block";
                loginMsg.style.display = "none";
                registerMsg.style.display = "block";
            }
        }

        function togglePassword() {
            const passwordInput = document.getElementById('password');
            const toggleIcon = document.querySelector('.password-toggle');
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                
            } else {
                passwordInput.type = 'password';
                
            }
        }
 

        // Client-Side Validation for Registration
        function validateForm() {
            var username = document.getElementById('username').value;
            var firstname = document.getElementById('firstname').value;
            var lastname = document.getElementById('lastname').value;
            var email = document.getElementById('email').value;
            var phone = document.getElementById('phone').value;
            

            // Validate Username: Alphanumeric and at least 3 characters
            var usernameRegex = /^[a-zA-Z0-9]{3,}$/;
            if (!usernameRegex.test(username)) {
                alert("Username must be alphanumeric and at least 3 characters long.");
                return false;
            }

            // Validate First Name and Last Name: Only letters
            var nameRegex = /^[a-zA-Z]+$/;
            if (!nameRegex.test(firstname) || !nameRegex.test(lastname)) {
                alert("First Name and Last Name should only contain letters.");
                return false;
            }

            // Validate Email: Proper email format
            var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                alert("Please enter a valid email address.");
                return false;
            }

            // Validate Phone Number: 11 digits
            var phoneRegex = /^[0-9]{11}$/;
            if (!phoneRegex.test(phone)) {
                alert("Phone number must be 11 digits.");
                return false;
            }



            // Submit the form via AJAX if validation passes
            submitForm(username, email, firstname, lastname, phone, password);
            return false; // Prevent form submission
        }

        // AJAX function to submit form
        function submitForm(username, email, firstname, lastname, phone, password) {
            $.ajax({
                url: 'register.php', // PHP script to process the form
                type: 'POST',
                data: {
                    username: username,
                    email: email,
                    firstname: firstname,
                    lastname: lastname,
                    phone: phone,
                    password: password
                },
                success: function(response) {
                    // If registration is successful, display success message
                    alert(response);
                    window.location.href = "index.php"; // Redirect to index (or another page)
                },
                error: function(xhr, status, error) {
                    // If there's an error, display error message
                    alert('Error: ' + error);
                }
            });
        }

    </script>
</head>
<body>
    

    <div class = "logindiv">
    <div class="login">
        <form id="loginForm" method="POST" action="login.php">
            <img src="logo.jpg" class="logo" alt="Adriana's Marketing Logo" class="logo">
            <h3>Login</h3>
            <input type="text" name="username" placeholder="Username" required><br>
            <div class="password-wrapper">
                <input type="password" id="password" name="password" placeholder="Password" required>
                <span class="password-toggle" onclick="togglePassword()"></span>
            </div>
            <p style="text-align: right;" class = "forgor">
                <a href="forgotpassword.php">Forgot Password?</a>
            </p>

            <p id="loginMessage">
                Don't have an account? <a href="#" onclick="showForm('registerForm')">Register here</a>
            </p>

            <button type="submit">Login</button>
        </form>
    </div>

    <!-- Register Form -->
    <div class="register">
        <form id="registerForm" method="POST" action="register.php" style="display: none;" onsubmit="return validateForm()">
            <h3>Register</h3>
            <input type="text" name="username" id="username" placeholder="Username" required><br>
            <input type="email" name="email" id="email" placeholder="Email" required><br>
            <input type="text" name="firstname" id="firstname" placeholder="First Name" required><br>
            <input type="text" name="lastname" id="lastname" placeholder="Last Name" required><br>
            <input type="text" name="phone" id="phone" placeholder="Phone Number" required><br>
            <input type="password" id="regpassword" name="regpassword" placeholder="Password" required>


            <p id="registerMessage">
                Already have an account? <a href="#" onclick="showForm('loginForm')">Go back to login</a>
            </p>

            <button type="submit">Register</button>
        </form>
    </div>


</div>

</body>
</html>


