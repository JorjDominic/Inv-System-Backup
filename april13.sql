CREATE TABLE Roles (
    RoleID INT PRIMARY KEY AUTO_INCREMENT,
    RoleName VARCHAR(50) NOT NULL UNIQUE
);

-- Insertion of Values in Roles Table --------------------------
INSERT INTO Roles (RoleName) VALUES
('Owner'),
('Developer'),
('Cashier'),
('Staff');

-- Select Statement For Roles Table Checking --------------------------
SELECT* FROM Roles;

-- Creation of Users Table --------------------------
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(250) NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
	Email VARCHAR(100) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(15) NOT NULL UNIQUE,
    RoleID INT NOT NULL DEFAULT 4,
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID),
    ResetCode VARCHAR(10) DEFAULT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE audit_trail(
id INT AUTO_INCREMENT PRIMARY KEY,
username VARCHAR(100) NOT NULL,
action ENUM('login','logout','password Changed') NOT NULL,
timestamp DATETIME DEFAULT CURRENT_TIMESTAMP 
);

-- Select Statement For USers Table Checking --------------------------
SELECT* FROM Users;
SELECT * FROM audit_trail;

UPDATE Users
SET RoleID = 1 -- New role ID (e.g., 2 for OWNER )
WHERE Username = 'Gab132213';

DELETE from Users;
DROP Table Users;
DROP Table audit_trail;